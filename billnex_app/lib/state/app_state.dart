import 'package:flutter/foundation.dart';
import '../data/catalog.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';
import '../models/expense.dart';
import '../models/saved_doc.dart';
import '../models/business_profile.dart';
import '../services/store.dart';
import '../services/persistence.dart';
import '../services/buffered_store.dart';
import '../services/sync_service.dart';
import '../services/billing.dart';

class CartLine {
  final String sku;
  final String name;
  final String unit;
  final double price;
  final double gstRate;
  double qty; // supports weighed/loose goods (e.g. 0.5 kg)
  double lineDiscount; // ₹ off this line
  CartLine({required this.sku, required this.name, required this.unit, required this.price, this.gstRate = 5, this.qty = 1, this.lineDiscount = 0});
  double get amount => price * qty;
  double get net => (amount - lineDiscount).clamp(0, double.infinity);
  factory CartLine.of(StockItem it, [double qty = 1]) => CartLine(sku: it.sku, name: it.name, unit: it.unit, price: it.price, gstRate: it.gstRate, qty: qty);
}

/// Central app state — the "Foundation" spine: preset engine + feature flags +
/// cart + template selection + posted-sales history, persisted via [Store].
///
/// Uses [ChangeNotifier] (no extra state-mgmt dependency). Swap for Riverpod
/// when wiring the backend without changing the widget contracts.
class AppState extends ChangeNotifier {
  /// Persistence engine — injectable (defaults to [Store]); a Drift/SQLite or
  /// remote backend can be passed in without changing any business logic.
  final BufferedStore _store;
  final SyncService _sync;
  AppState({Persistence? persistence, SyncService? sync}) : _store = BufferedStore(persistence ?? Store()), _sync = sync ?? const NoopSyncService();

  /// Await all pending disk writes. Call on app pause/detach so an in-flight
  /// save (e.g. a just-posted sale) is durable before the process can be killed.
  Future<void> flush() => _store.flush();

  /// Surfaces the last persistence write error, if any (null when healthy).
  Object? get lastWriteError => _store.lastError;

  // ---- lifecycle ----
  bool _ready = false;
  bool get ready => _ready;
  int _seq = 2047;
  int _rcptSeq = 500;
  int _purSeq = 300;
  final List<Sale> _sales = [];
  List<Sale> get sales => List.unmodifiable(_sales.reversed);

  // ---- suppliers & purchasing ----
  final List<Supplier> _suppliers = [];
  final List<Purchase> _purchases = [];
  final List<PayableEntry> _payables = [];
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<Purchase> get purchases => List.unmodifiable(_purchases.reversed);
  double payableOf(String supplierId) => _payables.where((e) => e.supplierId == supplierId).fold(0.0, (a, e) => a + e.delta);
  double get totalPayable => _suppliers.fold(0.0, (a, s) => a + payableOf(s.id));
  List<PayableEntry> payableLedger(String supplierId) => _payables.where((e) => e.supplierId == supplierId).toList()..sort((a, b) => a.epochMs.compareTo(b.epochMs));
  List<Purchase> purchasesFor(String supplierId) => _purchases.where((p) => p.supplierId == supplierId).toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));

  /// Duplicate-invoice guard (PRD BNX-0183).
  bool isDuplicatePurchase(String supplierId, String supplierRef) =>
      supplierRef.trim().isNotEmpty && _purchases.any((p) => p.supplierId == supplierId && p.supplierRef.toLowerCase() == supplierRef.trim().toLowerCase());

  final List<Customer> _customers = [];
  final List<LedgerEntry> _ledger = [];
  List<Customer> get customers => List.unmodifiable(_customers);

  // ---- roles, sync, audit ----
  Role _role = Role.owner;
  Role get role => _role;
  void setRole(Role r) {
    _role = r;
    notifyListeners();
  }

  /// Which nav destinations the current role may see (PRD §9).
  bool roleCanAccess(String navId) {
    switch (_role) {
      case Role.owner:
        return true;
      case Role.manager:
        return navId != 'features'; // no plan/entitlement config
      case Role.cashier:
        return {'dash', 'quickbill', 'billing', 'sales', 'customers', 'menu'}.contains(navId);
      case Role.accountant:
        return {'dash', 'sales', 'customers', 'purchasing', 'reports', 'menu'}.contains(navId);
    }
  }

  /// Cost/margin visibility is owner/manager/accountant only (BNX-0277).
  bool get canSeeCost => _role != Role.cashier;

  bool _online = true;
  bool get online => _online;
  final List<OutboxEvent> _outbox = [];
  int get queueCount => _outbox.where((e) => !e.synced).length;
  final List<AuditEvent> _audit = [];
  List<AuditEvent> get auditLog => _audit.reversed.toList();

  void setOnline(bool v) {
    _online = v;
    if (v) _flushOutbox();
    notifyListeners();
  }

  void _enqueue(String kind, String ref, int nowMs) {
    _outbox.add(OutboxEvent(idemKey: '$kind-$ref-$nowMs', kind: kind, ref: ref, epochMs: nowMs));
    if (_online) _flushOutbox();
    _store.saveOutbox(_outbox);
  }

  /// Flush the queue. With a configured [SyncService] the unsynced events are
  /// POSTed to the backend (idempotent — replays dropped by idem key) and marked
  /// synced only on success; otherwise they are marked synced locally.
  Future<void> syncNow() async {
    final pending = _outbox.where((e) => !e.synced).toList();
    if (_sync.isConfigured && pending.isNotEmpty) {
      try {
        await _sync.push(pending);
      } catch (_) {
        return; // stay queued; a later sync retries safely (idempotent)
      }
    }
    _flushOutbox();
    notifyListeners();
  }

  void _flushOutbox() {
    for (final e in _outbox) {
      e.synced = true;
    }
    _store.saveOutbox(_outbox);
  }

  void _audit0(String action, String ref, int nowMs) {
    _audit.add(AuditEvent(epochMs: nowMs, actor: _role.label, action: action, ref: ref));
    _store.saveAudit(_audit);
  }

  // ---- vertical: appointments (salon/clinic) ----
  final List<Appointment> _appts = [];
  List<Appointment> get appointments => _appts.toList()..sort((a, b) => a.epochMs.compareTo(b.epochMs));

  // ── Expenses (feed the P&L) ──
  final List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses.toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));
  double get totalExpenses => _expenses.fold(0.0, (a, e) => a + e.amount);

  Expense addExpense({required String category, required double amount, String note = '', String mode = 'Cash', int nowMs = 0}) {
    final e = Expense(id: 'E${nowMs == 0 ? _expenses.length + 1 : nowMs}', epochMs: nowMs, category: category.trim().isEmpty ? 'Other' : category.trim(), amount: amount, note: note.trim(), mode: mode);
    _expenses.add(e);
    _store.saveExpenses(_expenses);
    _audit0('Expense · ${e.category} ${amount.round()}', e.id, nowMs);
    notifyListeners();
    return e;
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _store.saveExpenses(_expenses);
    notifyListeners();
  }

  /// Expense totals grouped by category, largest first.
  List<({String category, double amount})> expensesByCategory() {
    final m = <String, double>{};
    for (final e in _expenses) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    final rows = m.entries.map((e) => (category: e.key, amount: e.value)).toList();
    rows.sort((a, b) => b.amount.compareTo(a.amount));
    return rows;
  }

  String expenseCsv() {
    final b = StringBuffer('Date,Category,Amount,Mode,Note\n');
    for (final e in expenses) {
      b.writeln('${e.dateLabel},${e.category},${e.amount.toStringAsFixed(2)},${e.mode},"${e.note}"');
    }
    return b.toString();
  }

  // ── Saved documents: Estimates / Quotations & Sale Orders ──
  final List<SavedDoc> _docs = [];
  List<SavedDoc> get savedDocs => _docs.toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));
  List<SavedDoc> docsOfType(DocType type) => savedDocs.where((d) => d.type == type).toList();

  String _nextDocNumber(DocType type) {
    final prefix = type == DocType.estimate ? 'EST' : 'ORD';
    var max = 0;
    for (final d in _docs.where((d) => d.type == type)) {
      final n = int.tryParse(d.number.replaceAll('#', '').replaceAll('$prefix-', '')) ?? 0;
      if (n > max) max = n;
    }
    return '#$prefix-${max + 1}';
  }

  /// Save the current ad-hoc lines as an Estimate or Sale Order (does NOT touch
  /// stock or the khata — that only happens on conversion to an invoice).
  SavedDoc saveDoc({
    required DocType type,
    required List<({String name, String unit, double qty, double rate, double gstRate})> lines,
    double billDiscount = 0,
    bool roundOff = true,
    bool taxInclusive = true,
    Customer? customer,
    double otherCharges = 0,
    String chargesLabel = '',
    String? transportNote,
    int nowMs = 0,
  }) {
    final totals = computeBill(
      lines: lines.map((l) => BillInput(price: l.rate, qty: l.qty, gstRate: l.gstRate)).toList(),
      taxInclusive: taxInclusive,
      billDiscount: billDiscount,
      roundToUnit: roundOff,
    );
    final saleLines = lines.map((l) {
      final key = l.name.trim();
      final item = _stock[key];
      return SaleLine(key.isEmpty ? 'Item' : key, l.qty, l.rate, gstRate: l.gstRate, sku: key, hsn: item?.hsn ?? '', cost: item?.cost ?? 0);
    }).toList();
    final doc = SavedDoc(
      id: 'D${nowMs == 0 ? _docs.length + 1 : nowMs}',
      type: type,
      number: _nextDocNumber(type),
      epochMs: nowMs,
      customerId: customer?.id,
      customerName: customer?.name ?? 'Walk-in',
      lines: saleLines,
      subtotal: totals.taxable,
      gst: totals.tax,
      total: totals.total + otherCharges,
      discount: totals.discountTotal,
      roundOff: totals.roundOff,
      taxInclusive: taxInclusive,
      otherCharges: otherCharges,
      chargesLabel: chargesLabel,
      transportNote: (transportNote ?? '').trim().isEmpty ? null : transportNote!.trim(),
      businessName: shopName,
      sellerGstin: _profile?.gstin,
      sellerPhone: _profile?.phone,
      sellerAddress: _profile?.address,
    );
    _docs.add(doc);
    _store.saveDocs(_docs);
    _audit0('${type == DocType.estimate ? 'Estimate' : 'Order'} saved · ${doc.number}', doc.number, nowMs);
    notifyListeners();
    return doc;
  }

  void deleteDoc(String id) {
    _docs.removeWhere((d) => d.id == id);
    _store.saveDocs(_docs);
    notifyListeners();
  }

  /// Convert a saved document into a posted invoice: this is the point where
  /// stock is decremented and (for credit) the khata is updated. The document
  /// is removed once converted.
  Sale convertDoc(SavedDoc doc, {required String paymentMode, Customer? customer, int nowMs = 0}) {
    final lines = doc.lines.map((sl) => (name: sl.name, unit: 'pc', qty: sl.qty, rate: sl.price, gstRate: sl.gstRate)).toList();
    final sale = postCustomSale(
      lines: lines,
      paymentMode: paymentMode,
      billDiscount: doc.discount,
      taxInclusive: doc.taxInclusive,
      customer: customer,
      otherCharges: doc.otherCharges,
      chargesLabel: doc.chargesLabel,
      transportNote: doc.transportNote,
      nowMs: nowMs,
    );
    deleteDoc(doc.id);
    return sale;
  }
  int get upcomingAppts => _appts.where((a) => a.status == ApptStatus.booked).length;

  Appointment addAppointment({required String customer, required String service, required String staff, required int slotMs, int nowMs = 0}) {
    final a = Appointment(id: 'A${nowMs == 0 ? _appts.length + 1 : nowMs}', customer: customer, service: service, staff: staff, epochMs: slotMs);
    _appts.add(a);
    _store.saveAppointments(_appts);
    _audit0('Appointment booked · $customer', a.id, nowMs);
    notifyListeners();
    return a;
  }

  void setApptStatus(Appointment a, ApptStatus s) {
    a.status = s;
    _store.saveAppointments(_appts);
    notifyListeners();
  }

  // ---- inventory ----
  final Map<String, StockItem> _stock = {};
  final List<StockMovement> _moves = [];
  List<StockItem> get stockItems => _stock.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  List<StockItem> get lowStockItems => stockItems.where((i) => i.low).toList();
  int get lowStockCount => _stock.values.where((i) => i.low).length;

  /// A "buy these" reorder list: low-stock items with the shortfall to their
  /// reorder level and a suggested order qty (tops back up to 2× reorder level).
  /// Sorted most-urgent (biggest shortfall) first.
  List<({String name, String unit, double qty, double reorder, double suggested})> reorderList() {
    final rows = lowStockItems.map((i) {
      final target = i.reorderLevel <= 0 ? 1.0 : i.reorderLevel * 2;
      final suggested = (target - i.qty).clamp(1, double.infinity).toDouble();
      return (name: i.name, unit: i.unit, qty: i.qty, reorder: i.reorderLevel, suggested: suggested);
    }).toList();
    rows.sort((a, b) => (b.reorder - b.qty).compareTo(a.reorder - a.qty));
    return rows;
  }

  /// Reorder list as CSV (Item, Unit, In stock, Reorder at, Suggested order).
  String reorderCsv() {
    final b = StringBuffer('Item,Unit,In stock,Reorder at,Suggested order\n');
    for (final r in reorderList()) {
      b.writeln('"${r.name}",${r.unit},${qtyLabel(r.qty)},${qtyLabel(r.reorder)},${qtyLabel(r.suggested)}');
    }
    return b.toString();
  }

  /// A plaintext purchase list to send a supplier on WhatsApp.
  String reorderWhatsAppText() {
    final rows = reorderList();
    if (rows.isEmpty) return '$shopName — stock is healthy, nothing to reorder.';
    final b = StringBuffer('$shopName — reorder list:\n');
    for (final r in rows) {
      b.writeln('• ${r.name}: ${qtyLabel(r.suggested)} ${r.unit} (have ${qtyLabel(r.qty)})');
    }
    return b.toString().trimRight();
  }
  double stockOf(String sku) => _stock[sku]?.qty ?? 0;
  List<StockMovement> movementsFor(String sku) => _moves.where((m) => m.sku == sku).toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));

  /// Restore persisted session (preset, flags, templates, sales) at startup.
  /// Loads one persisted section, tolerating a corrupt blob: on any failure the
  /// section is skipped (booting with defaults) instead of aborting startup.
  Future<void> _load(Future<void> Function() section) async {
    try {
      await section();
    } catch (_) {
      /* corrupt/partial data for this section — skip so the app still opens */
    }
  }

  Future<void> init() async {
    await _load(() async {
      final biz = await _store.loadBiz();
      if (biz != null && kBusinessTypes.any((b) => b.key == biz)) {
        _bizKey = biz;
        final savedFlags = await _store.loadFlags();
        _flags
          ..clear()
          ..addEntries(kCapabilities.map((c) => MapEntry(c.key, savedFlags[c.key] ?? false)));
        _template = await _store.loadTemplate() ?? defaultTemplateFor(biz);
        _posTemplate = await _store.loadPosTemplate() ?? defaultPosTemplateFor(biz);
      }
    });
    await _load(() async => _seq = await _store.loadSeq());
    await _load(() async => _rcptSeq = await _store.loadRcptSeq());
    await _load(() async => _purSeq = await _store.loadPurSeq());
    await _load(() async => _sales.addAll(await _store.loadSales()));
    await _load(() async => _customers.addAll(await _store.loadCustomers()));
    await _load(() async => _ledger.addAll(await _store.loadLedger()));
    await _load(() async => _suppliers.addAll(await _store.loadSuppliers()));
    await _load(() async => _purchases.addAll(await _store.loadPurchases()));
    await _load(() async => _payables.addAll(await _store.loadPayables()));
    await _load(() async => _outbox.addAll(await _store.loadOutbox()));
    await _load(() async => _audit.addAll(await _store.loadAudit()));
    await _load(() async => _appts.addAll(await _store.loadAppointments()));
    await _load(() async => _expenses.addAll(await _store.loadExpenses()));
    await _load(() async => _docs.addAll(await _store.loadDocs()));
    await _load(() async => _profile = await _store.loadProfile());
    await _load(() async {
      final savedStock = await _store.loadStock();
      if (savedStock != null) {
        _stock.addEntries(savedStock.map((s) => MapEntry(s.sku, s)));
        _moves.addAll(await _store.loadMoves());
      }
    });
    // Real installs start with an EMPTY catalogue — no demo data. Demo items are
    // only seeded via seedDemo() (?demo=1) for previews.
    _ready = true;
    notifyListeners();
  }

  // ---- selected business / preset + real profile ----
  String? _bizKey;
  String? get bizKey => _bizKey;
  BusinessType? get business => _bizKey == null ? null : businessByKey(_bizKey!);
  bool get onboarded => _bizKey != null;

  BusinessProfile? _profile;
  BusinessProfile? get profile => _profile;

  /// The shop's own name for UI/invoices (falls back to the type name).
  String get shopName => (_profile?.shopName.trim().isNotEmpty ?? false) ? _profile!.shopName : (business?.name ?? 'My Business');
  String? get gstin => _profile?.gstin;

  /// Complete first-run setup: apply the preset AND save the real profile.
  void setupBusiness(BusinessProfile p) {
    applyPreset(p.bizType);
    _profile = p;
    _store.saveProfile(p);
    notifyListeners();
  }

  /// Save profile edits. If the business type changed (e.g. the merchant picks
  /// a real trade after starting on the generic store), re-align the feature
  /// flags to the new preset — WITHOUT touching inventory, customers, sales or
  /// any other data.
  void updateProfile(BusinessProfile p) {
    final typeChanged = _bizKey != p.bizType;
    _profile = p;
    _bizKey = p.bizType;
    if (typeChanged) {
      final biz = businessByKey(p.bizType);
      _flags
        ..clear()
        ..addEntries(kCapabilities.map((c) => MapEntry(c.key, biz.on.contains(c.key))));
      _store.saveFlags(_flags);
      _store.saveBiz(p.bizType);
    }
    _store.saveProfile(p);
    notifyListeners();
  }

  /// A "standard store" default for merchants who skip business-type selection.
  /// Generic retail config; the type can be aligned later from Business details.
  void setupGenericStore() {
    setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'My Store'));
  }

  // ---- feature flags ----
  final Map<String, bool> _flags = {};
  bool isOn(String capKey) => _flags[capKey] ?? false;
  int get activeCount => _flags.values.where((v) => v).length;

  bool isLocked(String capKey) {
    final cap = capabilityByKey(capKey);
    if (!cap.pro) return false;
    return !(business?.on.contains(capKey) ?? false);
  }

  bool isPreset(String capKey) => business?.on.contains(capKey) ?? false;
  int enabledInCategory(String catKey) => kCapabilities.where((c) => c.category == catKey && isOn(c.key)).length;
  int totalInCategory(String catKey) => kCapabilities.where((c) => c.category == catKey).length;

  // ---- template selection ----
  String _template = 'classic';
  String get template => _template;
  String _posTemplate = 'thermal80';
  String get posTemplate => _posTemplate;

  // ---- POS-selected customer (transient) ----
  Customer? _selectedCustomer;
  Customer? get selectedCustomer => _selectedCustomer;
  void selectCustomer(Customer? c) {
    _selectedCustomer = c;
    notifyListeners();
  }

  // ---- cart ----
  final List<CartLine> _cart = [];
  List<CartLine> get cart => List.unmodifiable(_cart);
  double _billDiscount = 0;
  double get billDiscount => _billDiscount;
  void setBillDiscount(double v) {
    _billDiscount = v < 0 ? 0 : v;
    notifyListeners();
  }

  void setLineDiscount(int i, double v) {
    _cart[i].lineDiscount = v < 0 ? 0 : v;
    notifyListeners();
  }

  bool get taxInclusive => _profile?.taxInclusive ?? true;

  /// The correct, fully-computed bill (per-item GST, discounts, round-off).
  BillTotals get bill => computeBill(
    lines: _cart.map((l) => BillInput(price: l.price, qty: l.qty, gstRate: l.gstRate, lineDiscount: l.lineDiscount)).toList(),
    taxInclusive: taxInclusive,
    billDiscount: _billDiscount,
  );

  double get subtotal => bill.taxable;
  double get gst => bill.tax;
  double get total => bill.total;
  double get cartQty => _cart.fold(0.0, (a, l) => a + l.qty);

  // -----------------------------------------------------------------------
  // Preset engine
  // -----------------------------------------------------------------------
  void applyPreset(String bizKey) {
    _bizKey = bizKey;
    final biz = businessByKey(bizKey);
    _flags
      ..clear()
      ..addEntries(kCapabilities.map((c) => MapEntry(c.key, biz.on.contains(c.key))));
    _template = defaultTemplateFor(bizKey);
    _posTemplate = defaultPosTemplateFor(bizKey);
    _cart.clear();
    // Start empty — the merchant adds their own products.
    _stock.clear();
    _moves.clear();
    _store.saveStock(const []);
    _store.saveMoves(const []);
    _persistSession();
    notifyListeners();
  }

  /// Seed a demo catalogue (previews/demos only, via seedDemo).
  void _seedStock(String bizKey, int nowMs) {
    _stock.clear();
    _moves.clear();
    final prods = productsFor(bizKey);
    final withBatch = isOn('batchExpiry');
    for (var i = 0; i < prods.length; i++) {
      final p = prods[i];
      final qty = ((i * 13 + 8) % 42) + 3.0; // deterministic spread, some low
      final item = StockItem(sku: p.name, name: p.name, unit: p.unit, price: p.price, cost: (p.price * 0.78).roundToDouble(), qty: qty);
      if (withBatch && i < 4) {
        item.batches.add(Batch('B${1000 + i}', nowMs + Duration(days: 30 + i * 40).inMilliseconds, qty));
      }
      _stock[item.sku] = item;
      _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.opening, delta: qty, ref: 'OPENING'));
    }
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
  }

  /// True if a product with this (trimmed) name already exists — the SKU key.
  bool productExists(String name) => _stock.containsKey(name.trim());

  /// True if a barcode is already assigned to a different product.
  bool barcodeInUse(String code, {String? exceptSku}) => code.trim().isNotEmpty && _stock.values.any((i) => i.barcode == code.trim() && i.sku != exceptSku);

  /// Adds a product. Returns null (adding nothing) if the name is already taken,
  /// so the caller can warn instead of silently overwriting the original item.
  StockItem? addStockItem({
    required String name,
    required String unit,
    required double price,
    double cost = 0,
    double qty = 0,
    double reorder = 10,
    double gstRate = 5,
    String? barcode,
    String? category,
    String? hsn,
    bool stockTracked = true,
    int nowMs = 0,
  }) {
    final key = name.trim();
    if (_stock.containsKey(key)) return null; // never overwrite an existing SKU
    final item = StockItem(
      sku: key,
      name: key,
      unit: unit,
      price: price,
      cost: cost,
      qty: qty,
      reorderLevel: reorder,
      gstRate: gstRate,
      barcode: barcode,
      category: category,
      hsn: hsn,
      stockTracked: stockTracked,
    );
    _stock[item.sku] = item;
    if (qty != 0) _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.opening, delta: qty, ref: 'OPENING'));
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
    notifyListeners();
    return item;
  }

  /// Edit a product's master fields (name/price/unit/cost/reorder). Quantity is
  /// only changed via adjustments so the ledger stays truthful.
  void editStockItem(
    String sku, {
    String? name,
    String? unit,
    double? price,
    double? cost,
    double? reorder,
    double? gstRate,
    String? barcode,
    String? category,
    String? hsn,
    bool? stockTracked,
    int nowMs = 0,
  }) {
    final item = _stock[sku];
    if (item == null) return;
    if (name != null && name.trim().isNotEmpty) item.name = name.trim();
    if (unit != null && unit.trim().isNotEmpty) item.unit = unit.trim();
    if (price != null) item.price = price;
    if (cost != null) item.cost = cost;
    if (reorder != null) item.reorderLevel = reorder;
    if (gstRate != null) item.gstRate = gstRate;
    if (barcode != null) item.barcode = barcode.trim().isEmpty ? null : barcode.trim();
    if (category != null) item.category = category.trim().isEmpty ? null : category.trim();
    if (hsn != null) item.hsn = hsn.trim().isEmpty ? null : hsn.trim();
    if (stockTracked != null) item.stockTracked = stockTracked;
    _store.saveStock(_stock.values.toList());
    _audit0('Product edited · ${item.name}', sku, nowMs);
    notifyListeners();
  }

  /// Remove a product from the catalogue (its past sales/movements remain).
  void deleteStockItem(String sku, {int nowMs = 0}) {
    final item = _stock.remove(sku);
    if (item == null) return;
    _store.saveStock(_stock.values.toList());
    _audit0('Product removed · ${item.name}', sku, nowMs);
    notifyListeners();
  }

  /// Manual stock adjustment (BNX-0147) — audited via a movement.
  void adjustStock({required String sku, required double delta, required String reason, MoveKind kind = MoveKind.adjustment, int nowMs = 0}) {
    final item = _stock[sku];
    if (item == null) return;
    // Never drive on-hand negative; a reduction is capped at what's in stock.
    final applied = (item.qty + delta) < 0 ? -item.qty : delta;
    item.qty += applied;
    _moves.add(StockMovement(sku: sku, epochMs: nowMs, kind: kind, delta: applied, ref: 'ADJ', reason: reason));
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
    _enqueue('adjustment', sku, nowMs);
    _audit0('Stock ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)} · $sku', reason, nowMs);
    notifyListeners();
  }

  // ---- feature toggles ----
  void setFlag(String capKey, bool value) {
    if (isLocked(capKey)) return;
    _flags[capKey] = value;
    _store.saveFlags(_flags);
    notifyListeners();
  }

  void toggleCategory(String catKey) {
    final caps = kCapabilities.where((c) => c.category == catKey && !isLocked(c.key)).toList();
    final allOn = caps.every((c) => isOn(c.key));
    for (final c in caps) {
      _flags[c.key] = !allOn;
    }
    _store.saveFlags(_flags);
    notifyListeners();
  }

  // ---- templates ----
  void setTemplate(String id) {
    _template = id;
    _store.saveTemplate(id);
    notifyListeners();
  }

  void setPosTemplate(String id) {
    _posTemplate = id;
    _store.savePosTemplate(id);
    notifyListeners();
  }

  // ---- cart ops ----
  /// Available-to-sell for a stock-tracked item = on-hand minus what's already
  /// in the cart. `double.infinity` for services/untracked items.
  double _available(StockItem item) {
    if (!item.stockTracked) return double.infinity;
    final inCart = _cart.where((l) => l.sku == item.sku).fold(0.0, (a, l) => a + l.qty);
    return item.qty - inCart;
  }

  /// Adds one unit. Returns false (and adds nothing) when a tracked item has no
  /// stock left, so the POS can warn instead of driving stock negative.
  bool addProduct(StockItem item) {
    if (item.stockTracked && _available(item) < 1) return false;
    final existing = _cart.where((l) => l.sku == item.sku).firstOrNull;
    if (existing != null) {
      existing.qty += 1;
    } else {
      _cart.add(CartLine.of(item));
    }
    notifyListeners();
    return true;
  }

  /// Sets an exact (possibly decimal) quantity on a cart line — for weighed
  /// goods. Clamps to available stock for tracked items; removes at 0.
  void setQty(int i, double qty) {
    final line = _cart[i];
    final item = _stock[line.sku];
    var q = qty;
    if (item != null && item.stockTracked) {
      final otherInCart = _cart.where((l) => l != line && l.sku == line.sku).fold(0.0, (a, l) => a + l.qty);
      q = q.clamp(0, (item.qty - otherInCart).clamp(0, double.infinity));
    }
    if (q <= 0) {
      _cart.removeAt(i);
    } else {
      line.qty = q;
    }
    notifyListeners();
  }

  /// Add by scanned/typed barcode. Returns the item name, or null if unknown.
  String? addByCode(String code) {
    final c = code.trim();
    if (c.isEmpty) return null;
    final item = _stock.values.where((i) => i.barcode == c || i.sku.toLowerCase() == c.toLowerCase()).firstOrNull;
    if (item == null) return null;
    addProduct(item);
    return item.name;
  }

  void inc(int i) {
    final line = _cart[i];
    final item = _stock[line.sku];
    if (item != null && item.stockTracked && _available(item) < 1) return; // no stock left
    line.qty += 1;
    notifyListeners();
  }

  void dec(int i) {
    _cart[i].qty -= 1;
    if (_cart[i].qty <= 0) _cart.removeAt(i);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _billDiscount = 0;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Posting: turns the cart into an immutable Sale with a unique invoice no.
  // -----------------------------------------------------------------------
  Sale postSale({required String paymentMode, int nowMs = 0, Customer? customer}) {
    _seq += 1;
    final invoiceNo = '#INV-$_seq';
    final b = bill;
    final sale = Sale(
      invoiceNo: invoiceNo,
      epochMs: nowMs,
      businessName: shopName,
      templateId: _template,
      lines: _cart.map((l) => SaleLine(l.name, l.qty, l.price, gstRate: l.gstRate, discount: l.lineDiscount, sku: l.sku, hsn: _stock[l.sku]?.hsn ?? '', cost: _stock[l.sku]?.cost ?? 0)).toList(),
      subtotal: b.taxable,
      gst: b.tax,
      total: b.total,
      discount: b.discountTotal,
      roundOff: b.roundOff,
      taxInclusive: taxInclusive,
      paymentMode: paymentMode,
      sellerGstin: _profile?.gstin,
      sellerPhone: _profile?.phone,
      sellerAddress: _profile?.address,
    );
    _sales.add(sale);
    // Decrement stock from the ledger for each line (BNX-0137).
    var stockTouched = false;
    for (final l in _cart) {
      final item = _stock[l.sku];
      if (item != null && item.stockTracked) {
        item.qty = (item.qty - l.qty).clamp(0, double.infinity); // never negative
        _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.sale, delta: -l.qty, ref: invoiceNo));
        stockTouched = true;
      }
    }
    if (stockTouched) {
      _store.saveStock(_stock.values.toList());
      _store.saveMoves(_moves);
    }
    // Credit sale posts to the customer's ledger as a debit (BNX-0128).
    if (paymentMode == 'Credit' && customer != null) {
      _ledger.add(LedgerEntry(customerId: customer.id, epochMs: nowMs, kind: LedgerKind.creditSale, ref: invoiceNo, debit: sale.total));
      _store.saveLedger(_ledger);
    }
    _cart.clear();
    _billDiscount = 0;
    _selectedCustomer = null;
    _store.saveSeq(_seq);
    _store.saveSales(_sales);
    _enqueue('sale', invoiceNo, nowMs);
    _audit0('Sale posted · $paymentMode ${sale.total.round()}', invoiceNo, nowMs);
    notifyListeners();
    return sale;
  }

  // -----------------------------------------------------------------------
  // Quick Bill: post a sale from ad-hoc custom lines (no catalogue needed).
  // -----------------------------------------------------------------------
  Sale postCustomSale({
    required List<({String name, String unit, double qty, double rate, double gstRate})> lines,
    required String paymentMode,
    double billDiscount = 0,
    bool roundOff = true,
    bool taxInclusive = true,
    Customer? customer,
    double otherCharges = 0,
    String chargesLabel = '',
    String? transportNote,
    int nowMs = 0,
  }) {
    _seq += 1;
    final invoiceNo = '#INV-$_seq';
    final totals = computeBill(
      lines: lines.map((l) => BillInput(price: l.rate, qty: l.qty, gstRate: l.gstRate)).toList(),
      taxInclusive: taxInclusive,
      billDiscount: billDiscount,
      roundToUnit: roundOff,
    );
    final saleLines = lines.map((l) {
      final key = l.name.trim();
      final item = _stock[key];
      return SaleLine(key.isEmpty ? 'Item' : key, l.qty, l.rate, gstRate: l.gstRate, sku: key, hsn: item?.hsn ?? '', cost: item?.cost ?? 0);
    }).toList();
    final sale = Sale(
      invoiceNo: invoiceNo,
      epochMs: nowMs,
      businessName: shopName,
      templateId: _template,
      lines: saleLines,
      subtotal: totals.taxable,
      gst: totals.tax,
      total: totals.total + otherCharges, // non-taxable add-on folded into the grand total
      discount: totals.discountTotal,
      roundOff: totals.roundOff,
      taxInclusive: taxInclusive,
      paymentMode: paymentMode,
      sellerGstin: _profile?.gstin,
      sellerPhone: _profile?.phone,
      sellerAddress: _profile?.address,
      otherCharges: otherCharges,
      chargesLabel: chargesLabel,
      transportNote: (transportNote ?? '').trim().isEmpty ? null : transportNote!.trim(),
    );
    _sales.add(sale);
    // Decrement stock only where a line matches an existing tracked SKU by name.
    var stockTouched = false;
    for (final l in lines) {
      final item = _stock[l.name.trim()];
      if (item != null && item.stockTracked) {
        item.qty = (item.qty - l.qty).clamp(0, double.infinity);
        _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.sale, delta: -l.qty, ref: invoiceNo));
        stockTouched = true;
      }
    }
    if (stockTouched) {
      _store.saveStock(_stock.values.toList());
      _store.saveMoves(_moves);
    }
    if (paymentMode == 'Credit' && customer != null) {
      _ledger.add(LedgerEntry(customerId: customer.id, epochMs: nowMs, kind: LedgerKind.creditSale, ref: invoiceNo, debit: sale.total));
      _store.saveLedger(_ledger);
    }
    _store.saveSeq(_seq);
    _store.saveSales(_sales);
    _enqueue('sale', invoiceNo, nowMs);
    _audit0('Quick bill · $paymentMode ${sale.total.round()}', invoiceNo, nowMs);
    notifyListeners();
    return sale;
  }

  /// How often each item name has been billed — ranks suggestions/frequents.
  Map<String, int> _nameFrequency() {
    final m = <String, int>{};
    for (final s in _sales) {
      for (final l in s.lines) {
        if (l.name.trim().isNotEmpty && l.name != 'Item') m[l.name] = (m[l.name] ?? 0) + 1;
      }
    }
    return m;
  }

  /// Maps a free-text stock unit ('kg', 'Piece', 'Litre'…) to a Quick Bill
  /// base unit (kg / L / pc) so a picked catalogue item gets the right presets.
  static String baseUnitOf(String rawUnit) {
    final u = rawUnit.toLowerCase();
    if (u.contains('kg') || u == 'g' || u == 'gm' || u.contains('gram')) return 'kg';
    if (u.contains('ml') || u.contains('lit') || u == 'l' || u == 'ltr') return 'L';
    return 'pc';
  }

  /// Combined Quick Bill catalogue: every real inventory item + every learned
  /// name from posted bills, each with its last rate, unit, and stock.
  Map<String, ({double rate, String unit, bool inStock, double stock})> _quickCatalogue() {
    final m = <String, ({double rate, String unit, bool inStock, double stock})>{};
    for (final it in _stock.values) {
      m[it.name] = (rate: it.price, unit: baseUnitOf(it.unit), inStock: it.stockTracked, stock: it.qty);
    }
    for (final s in _sales) {
      for (final l in s.lines) {
        if (l.name.trim().isEmpty || l.name == 'Item') continue;
        final ex = m[l.name];
        m[l.name] = (rate: l.price, unit: ex?.unit ?? 'pc', inStock: ex?.inStock ?? false, stock: ex?.stock ?? 0);
      }
    }
    return m;
  }

  /// Suggestions matching [prefix] — searches the whole inventory + learned
  /// names. Prefix matches rank first, then most-billed, then alphabetical.
  List<({String name, double rate, String unit, bool inStock, double stock})> quickSuggest(String prefix, {int limit = 8}) {
    final q = prefix.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final cat = _quickCatalogue();
    final freq = _nameFrequency();
    final rows = cat.entries.where((e) => e.key.toLowerCase().contains(q)).map((e) => (name: e.key, rate: e.value.rate, unit: e.value.unit, inStock: e.value.inStock, stock: e.value.stock)).toList();
    rows.sort((a, b) {
      final ap = a.name.toLowerCase().startsWith(q) ? 0 : 1;
      final bp = b.name.toLowerCase().startsWith(q) ? 0 : 1;
      if (ap != bp) return ap - bp;
      final f = (freq[b.name] ?? 0).compareTo(freq[a.name] ?? 0);
      if (f != 0) return f;
      return a.name.compareTo(b.name);
    });
    return rows.take(limit).toList();
  }

  /// The shop's most-billed items for the one-tap frequent strip.
  List<({String name, double rate, String unit})> frequentItems({int limit = 12}) {
    final cat = _quickCatalogue();
    final freq = _nameFrequency();
    final names = cat.keys.toList()..sort((a, b) => (freq[b] ?? 0).compareTo(freq[a] ?? 0));
    return names.where((n) => (freq[n] ?? 0) > 0).take(limit).map((n) => (name: n, rate: cat[n]!.rate, unit: cat[n]!.unit)).toList();
  }

  double get todaySales => _sales.fold(0, (a, s) => a + s.total);
  int get billCount => _sales.length;

  /// Whether a bill has already been returned (guards double credit notes).
  /// Uses the credit note's recorded source invoice so it works even for
  /// services / items that create no stock movement.
  bool isReturned(String invoiceNo) => _sales.any((s) => s.isReturn && s.sourceInvoice == invoiceNo);

  /// Sale Return / Credit Note (BNX returns) — reverses a posted bill: restocks
  /// every line and records a negative-total credit note so reports net out.
  /// Cash/UPI returns are a refund; for a credit bill, adjust the khata too.
  Sale returnSale(Sale original, {int nowMs = 0}) {
    _seq += 1;
    final no = '#RET-$_seq';
    final ret = Sale(
      invoiceNo: no,
      epochMs: nowMs,
      businessName: shopName,
      templateId: _template,
      // Negative quantities so item-sales, HSN and COGS reports net the
      // returned goods OUT instead of adding them again.
      lines: [for (final l in original.lines) SaleLine(l.name, -l.qty, l.price, gstRate: l.gstRate, discount: -l.discount, sku: l.sku, hsn: l.hsn, cost: l.cost)],
      subtotal: -original.subtotal,
      gst: -original.gst,
      total: -original.total,
      discount: -original.discount,
      roundOff: -original.roundOff,
      taxInclusive: original.taxInclusive,
      paymentMode: 'Return',
      sellerGstin: _profile?.gstin,
      sellerPhone: _profile?.phone,
      sellerAddress: _profile?.address,
      sourceInvoice: original.invoiceNo,
    );
    _sales.add(ret);
    var stockTouched = false;
    for (final l in original.lines) {
      final item = _stock[l.sku]; // by SKU, robust when SKU != display name
      if (item != null && item.stockTracked) {
        item.qty += l.qty; // put it back on the shelf
        _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.adjustment, delta: l.qty, ref: no, reason: 'Return ${original.invoiceNo}'));
        stockTouched = true;
      }
    }
    if (stockTouched) {
      _store.saveStock(_stock.values.toList());
      _store.saveMoves(_moves);
    }
    _store.saveSeq(_seq);
    _store.saveSales(_sales);
    _enqueue('return', no, nowMs);
    _audit0('Return · ${original.invoiceNo} ${original.total.round()}', no, nowMs);
    notifyListeners();
    return ret;
  }

  // -----------------------------------------------------------------------
  // Reports (computed from posted data)
  // -----------------------------------------------------------------------
  double get salesGross => _sales.fold(0.0, (a, s) => a + s.subtotal);
  double get gstCollected => _sales.fold(0.0, (a, s) => a + s.gst);
  double get salesNet => _sales.fold(0.0, (a, s) => a + s.total);
  double get avgBill => _sales.isEmpty ? 0 : salesNet / _sales.length;
  double get itemsSold => _sales.fold(0.0, (a, s) => a + s.itemCount);

  /// Payment-mode breakdown (PRD BNX-0299).
  Map<String, double> paymentMix() {
    final m = <String, double>{};
    for (final s in _sales) {
      m[s.paymentMode] = (m[s.paymentMode] ?? 0) + s.total;
    }
    return m;
  }

  /// Item-wise sales, best sellers first (PRD BNX-0280).
  List<({String name, double qty, double value})> itemSales() {
    final qty = <String, double>{};
    final val = <String, double>{};
    for (final s in _sales) {
      for (final l in s.lines) {
        qty[l.name] = (qty[l.name] ?? 0) + l.qty;
        val[l.name] = (val[l.name] ?? 0) + l.amount;
      }
    }
    final rows = qty.keys.map((k) => (name: k, qty: qty[k]!, value: val[k]!)).toList();
    rows.sort((a, b) => b.value.compareTo(a.value));
    return rows;
  }

  double get stockValueAtCost => _stock.values.fold(0.0, (a, i) => a + i.qty * i.cost);

  /// GSTR-ready Sale Summary by HSN (BNX GST reports). Groups every sold line
  /// by its HSN/SAC (looked up from the catalogue; '—' when unknown) and rate.
  List<({String hsn, double rate, double qty, double taxable, double tax})> hsnSummary() {
    final m = <String, ({double qty, double taxable, double tax})>{};
    for (final s in _sales) {
      for (final l in s.lines) {
        final hsn = l.hsn.isNotEmpty ? l.hsn : '—'; // snapshot at post time
        final key = '$hsn|${l.gstRate}';
        final gross = l.amount - l.discount;
        final taxable = s.taxInclusive ? gross / (1 + l.gstRate / 100) : gross;
        final tax = s.taxInclusive ? gross - taxable : gross * l.gstRate / 100;
        final ex = m[key];
        m[key] = (qty: (ex?.qty ?? 0) + l.qty, taxable: (ex?.taxable ?? 0) + taxable, tax: (ex?.tax ?? 0) + tax);
      }
    }
    final rows = m.entries.map((e) {
      final parts = e.key.split('|');
      return (hsn: parts[0], rate: double.parse(parts[1]), qty: e.value.qty, taxable: _r2(e.value.taxable), tax: _r2(e.value.tax));
    }).toList();
    rows.sort((a, b) => b.taxable.compareTo(a.taxable));
    return rows;
  }

  static double _r2(double v) => (v * 100).round() / 100;

  /// Cost of goods sold — catalogue cost × quantity for every sold line.
  double get cogs {
    var c = 0.0;
    for (final s in _sales) {
      for (final l in s.lines) {
        c += l.cost * l.qty; // cost snapshot at post time
      }
    }
    return _r2(c);
  }

  /// Simple Profit & Loss (BNX reports): taxable sales − COGS = gross profit.
  ({double sales, double cogs, double grossProfit, double expenses, double netProfit, double gst}) profitAndLoss() {
    final sales = salesGross; // net taxable of all bills
    final cost = cogs;
    final gross = _r2(sales - cost);
    final exp = totalExpenses;
    return (sales: sales, cogs: cost, grossProfit: gross, expenses: exp, netProfit: _r2(gross - exp), gst: gstCollected);
  }

  /// Day Book — every posted transaction in time order (BNX day book). Sales &
  /// collections are money-in; purchases & supplier payments are money-out.
  List<({int epochMs, String type, String ref, String party, double inAmt, double outAmt})> dayBook() {
    final rows = <({int epochMs, String type, String ref, String party, double inAmt, double outAmt})>[];
    for (final s in _sales) {
      if (s.isReturn) {
        // Refund of cash out to the customer (total is negative).
        rows.add((epochMs: s.epochMs, type: 'Return (refund)', ref: s.invoiceNo, party: s.sourceInvoice ?? '', inAmt: 0, outAmt: -s.total));
      } else {
        rows.add((epochMs: s.epochMs, type: s.paymentMode == 'Credit' ? 'Credit sale' : 'Sale', ref: s.invoiceNo, party: s.paymentMode, inAmt: s.paymentMode == 'Credit' ? 0 : s.total, outAmt: 0));
      }
    }
    for (final e in _ledger.where((e) => e.kind == LedgerKind.collection)) {
      final name = _customers.where((c) => c.id == e.customerId).map((c) => c.name).firstOrNull ?? 'Customer';
      rows.add((epochMs: e.epochMs, type: 'Collection', ref: e.ref, party: name, inAmt: e.credit, outAmt: 0));
    }
    for (final p in _purchases) {
      rows.add((epochMs: p.epochMs, type: 'Purchase', ref: p.purchaseNo, party: _suppliers.where((s) => s.id == p.supplierId).map((s) => s.name).firstOrNull ?? 'Supplier', inAmt: 0, outAmt: p.total));
    }
    rows.sort((a, b) => b.epochMs.compareTo(a.epochMs));
    return rows;
  }

  /// Day Book as CSV text (BNX-0311 export).
  String dayBookCsv() {
    final b = StringBuffer('Date,Type,Ref,Party,In,Out\n');
    for (final r in dayBook()) {
      final d = DateTime.fromMillisecondsSinceEpoch(r.epochMs);
      final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      b.writeln('$date,${r.type},${r.ref},"${r.party}",${r.inAmt.toStringAsFixed(2)},${r.outAmt.toStringAsFixed(2)}');
    }
    return b.toString();
  }

  /// HSN summary as CSV text (for GST filing).
  String hsnCsv() {
    final b = StringBuffer('HSN/SAC,GST %,Qty,Taxable,Tax\n');
    for (final r in hsnSummary()) {
      b.writeln('${r.hsn},${r.rate.toStringAsFixed(0)},${r.qty},${r.taxable.toStringAsFixed(2)},${r.tax.toStringAsFixed(2)}');
    }
    return b.toString();
  }

  /// GSTR-1 rate-wise outward-supply summary. No buyer GSTIN is captured per
  /// sale, so all supplies are treated as B2C (Others). Sales returns (credit
  /// notes) net off. Intra-state → CGST + SGST at half the rate each.
  List<({double rate, double taxable, double cgst, double sgst, int invoices})> gstr1Summary() {
    final m = <double, ({double taxable, double tax, Set<String> inv})>{};
    for (final s in _sales) {
      final sign = s.isReturn ? -1.0 : 1.0;
      for (final l in s.lines) {
        final gross = l.amount - l.discount;
        final taxable = s.taxInclusive ? gross / (1 + l.gstRate / 100) : gross;
        final tax = s.taxInclusive ? gross - taxable : gross * l.gstRate / 100;
        final ex = m[l.gstRate];
        final inv = ex?.inv ?? <String>{};
        inv.add(s.invoiceNo);
        m[l.gstRate] = (taxable: (ex?.taxable ?? 0) + taxable * sign, tax: (ex?.tax ?? 0) + tax * sign, inv: inv);
      }
    }
    final rows = m.entries
        .map((e) => (rate: e.key, taxable: _r2(e.value.taxable), cgst: _r2(e.value.tax / 2), sgst: _r2(e.value.tax / 2), invoices: e.value.inv.length))
        .toList();
    rows.sort((a, b) => a.rate.compareTo(b.rate));
    return rows;
  }

  /// GSTR-1 summary as CSV text (rate-wise B2C outward supplies).
  String gstr1Csv() {
    final b = StringBuffer('GST %,Taxable Value,CGST,SGST,Total Tax,Invoices\n');
    for (final r in gstr1Summary()) {
      b.writeln('${r.rate.toStringAsFixed(0)},${r.taxable.toStringAsFixed(2)},${r.cgst.toStringAsFixed(2)},${r.sgst.toStringAsFixed(2)},${(r.cgst + r.sgst).toStringAsFixed(2)},${r.invoices}');
    }
    return b.toString();
  }

  // -----------------------------------------------------------------------
  // Customers & credit ledger
  // -----------------------------------------------------------------------
  Customer addCustomer({required String name, required String mobile, String? gstin, double creditLimit = 0, bool consent = false, int nowMs = 0}) {
    final c = Customer(
      id: 'C${nowMs == 0 ? _customers.length + 1 : nowMs}',
      name: name.trim(),
      mobile: mobile.trim(),
      gstin: (gstin?.trim().isEmpty ?? true) ? null : gstin!.trim(),
      creditLimit: creditLimit,
      consent: consent,
    );
    _customers.add(c);
    _store.saveCustomers(_customers);
    notifyListeners();
    return c;
  }

  // -----------------------------------------------------------------------
  // Suppliers & purchasing
  // -----------------------------------------------------------------------
  Supplier addSupplier({required String name, String phone = '', String? gstin, int creditDays = 0, int nowMs = 0}) {
    final s = Supplier(
      id: 'S${nowMs == 0 ? _suppliers.length + 1 : nowMs}',
      name: name.trim(),
      phone: phone.trim(),
      gstin: (gstin?.trim().isEmpty ?? true) ? null : gstin!.trim(),
      creditDays: creditDays,
    );
    _suppliers.add(s);
    _store.saveSuppliers(_suppliers);
    notifyListeners();
    return s;
  }

  /// GST on a purchase computed per line from each item's own slab (falls back
  /// to 5% for a not-yet-catalogued SKU), rounded to whole rupees.
  double purchaseTax(List<PurchaseLine> lines) {
    var tax = 0.0;
    for (final l in lines) {
      final rate = _stock[l.sku]?.gstRate ?? 5;
      tax += l.amount * rate / 100;
    }
    return tax.roundToDouble();
  }

  double purchaseTotal(List<PurchaseLine> lines) => lines.fold<double>(0, (a, l) => a + l.amount) + purchaseTax(lines);

  /// Record a purchase: increases stock (movement per line) and creates a
  /// payable if not paid immediately (PRD BNX-0177/0178).
  Purchase recordPurchase({required Supplier supplier, required List<PurchaseLine> lines, required String supplierRef, required bool paid, int nowMs = 0}) {
    _purSeq += 1;
    final subtotal = lines.fold<double>(0, (a, l) => a + l.amount);
    final gst = purchaseTax(lines);
    final total = subtotal + gst;
    final purchaseNo = '#PUR-$_purSeq';
    final purchase = Purchase(purchaseNo: purchaseNo, epochMs: nowMs, supplierId: supplier.id, supplierRef: supplierRef.trim(), lines: lines, subtotal: subtotal, gst: gst, total: total, paid: paid);
    _purchases.add(purchase);
    // stock-in
    for (final l in lines) {
      final item = _stock[l.sku];
      if (item != null) {
        item.qty += l.qty;
        item.cost = l.rate; // last purchase rate
        _moves.add(StockMovement(sku: l.sku, epochMs: nowMs, kind: MoveKind.purchase, delta: l.qty, ref: purchaseNo));
      } else {
        final ni = StockItem(sku: l.sku, name: l.sku, unit: 'Piece', price: (l.rate * 1.25).roundToDouble(), cost: l.rate, qty: l.qty);
        _stock[ni.sku] = ni;
        _moves.add(StockMovement(sku: l.sku, epochMs: nowMs, kind: MoveKind.purchase, delta: l.qty, ref: purchaseNo));
      }
    }
    // payable
    _payables.add(PayableEntry(supplierId: supplier.id, epochMs: nowMs, ref: purchaseNo, debit: total));
    if (paid) {
      _payables.add(PayableEntry(supplierId: supplier.id, epochMs: nowMs, ref: purchaseNo, credit: total, mode: 'Cash'));
    }
    _store.savePurSeq(_purSeq);
    _store.savePurchases(_purchases);
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
    _store.savePayables(_payables);
    _enqueue('purchase', purchaseNo, nowMs);
    _audit0('Purchase · ${supplier.name} ${total.round()}', purchaseNo, nowMs);
    notifyListeners();
    return purchase;
  }

  PayableEntry paySupplier({required Supplier supplier, required double amount, required String mode, int nowMs = 0}) {
    final entry = PayableEntry(supplierId: supplier.id, epochMs: nowMs, ref: '#SPAY-$nowMs', credit: amount, mode: mode);
    _payables.add(entry);
    _store.savePayables(_payables);
    notifyListeners();
    return entry;
  }

  List<LedgerEntry> ledgerFor(String customerId) => _ledger.where((e) => e.customerId == customerId).toList()..sort((a, b) => a.epochMs.compareTo(b.epochMs));

  double balanceOf(String customerId) => _ledger.where((e) => e.customerId == customerId).fold(0.0, (a, e) => a + e.delta);

  double get totalReceivable => _customers.fold(0.0, (a, c) => a + balanceOf(c.id));
  int get overdueCount => _customers.where((c) => balanceOf(c.id) > 0).length;

  bool overLimit(Customer c, double addAmount) => c.creditLimit > 0 && (balanceOf(c.id) + addAmount) > c.creditLimit;

  /// Record a payment against a customer's outstanding (BNX-0129). The amount
  /// is capped at the current balance so a collection can't push it negative.
  /// [against] optionally ties the payment to a specific invoice so that bill's
  /// balance-due goes down (invoice-level khata, Vyapar-style Payment-In).
  LedgerEntry collect({required Customer customer, required double amount, required String mode, String? against, int nowMs = 0}) {
    _rcptSeq += 1;
    final capped = amount.clamp(0, balanceOf(customer.id)).toDouble();
    final entry = LedgerEntry(customerId: customer.id, epochMs: nowMs, kind: LedgerKind.collection, ref: '#RCPT-$_rcptSeq', credit: capped, mode: mode, against: against);
    _ledger.add(entry);
    _store.saveLedger(_ledger);
    _store.saveRcptSeq(_rcptSeq);
    _enqueue('collection', entry.ref, nowMs);
    _audit0('Collection · ${customer.name} ${amount.round()}${against != null ? ' · $against' : ''}', entry.ref, nowMs);
    notifyListeners();
    return entry;
  }

  Customer? customerById(String id) {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// The credit-sale ledger entry for an invoice, if it was sold on credit.
  LedgerEntry? _creditSaleFor(String invoiceNo) {
    for (final e in _ledger) {
      if (e.kind == LedgerKind.creditSale && e.ref == invoiceNo) return e;
    }
    return null;
  }

  /// Outstanding balance on a single invoice: the credit-sale amount minus any
  /// payments recorded against it. Cash/UPI bills (no credit entry) return 0.
  double invoiceBalance(String invoiceNo) {
    final sale = _creditSaleFor(invoiceNo);
    if (sale == null) return 0;
    final paid = _ledger.where((e) => e.kind == LedgerKind.collection && e.against == invoiceNo).fold<double>(0, (a, e) => a + e.credit);
    return (sale.debit - paid).clamp(0, double.infinity).toDouble();
  }

  /// The customer an invoice was billed to on credit (for Payment-In), if any.
  Customer? customerForInvoice(String invoiceNo) {
    final e = _creditSaleFor(invoiceNo);
    return e == null ? null : customerById(e.customerId);
  }

  /// Seed a few posted bills + credit customers (previews/demos only).
  void seedDemo(int nowMs) {
    if (_bizKey == null || _sales.isNotEmpty) return;
    _seedStock(_bizKey!, nowMs); // demo catalogue (preset starts empty in real use)
    _profile ??= BusinessProfile(bizType: _bizKey!, shopName: business!.name, phone: '98480 00000', gstin: '36ABCDE1234F1Z5', address: 'Main Road, Hyderabad');
    final prods = productsFor(_bizKey!);
    final modes = ['Cash', 'UPI', 'Cash'];
    for (var i = 0; i < 3 && i < prods.length; i++) {
      _cart.clear();
      _cart.add(CartLine.of(_stock[prods[i].name]!, 2));
      if (i + 1 < prods.length) _cart.add(CartLine.of(_stock[prods[i + 1].name]!));
      postSale(paymentMode: modes[i], nowMs: nowMs - i * 3600000);
    }
    if (isOn('creditLedger')) {
      final names = ['Anita Sharma', 'Ravi Kumar', 'Sunrise Traders'];
      final mobiles = ['98480 11111', '90000 22222', '91234 55555'];
      for (var i = 0; i < 3 && i < prods.length; i++) {
        final cust = addCustomer(name: names[i], mobile: mobiles[i], creditLimit: 5000, consent: true, nowMs: nowMs + i);
        _cart.clear();
        _cart.add(CartLine.of(_stock[prods[i].name]!, i + 1));
        postSale(paymentMode: 'Credit', nowMs: nowMs - i * 7200000, customer: cust);
        if (i == 2) collect(customer: cust, amount: prods[i].price, mode: 'UPI', nowMs: nowMs);
      }
    }
    if (isOn('appointments')) {
      addAppointment(customer: 'Priya Nair', service: 'Hair Spa', staff: 'Meena', slotMs: nowMs + 3600000, nowMs: nowMs + 1);
      addAppointment(customer: 'Karan Rao', service: 'Beard Trim', staff: 'Imran', slotMs: nowMs + 7200000, nowMs: nowMs + 2);
      addAppointment(customer: 'Fatima S', service: 'Facial - Gold', staff: 'Meena', slotMs: nowMs + 10800000, nowMs: nowMs + 3);
    }
    // demo suppliers + purchases
    final supNames = ['Metro Distributors', 'Sri Wholesale'];
    for (var i = 0; i < 2 && i < prods.length; i++) {
      final sup = addSupplier(name: supNames[i], phone: '900011${i}0${i}0', gstin: '36AAAAA000${i}A1Z5', creditDays: 30, nowMs: nowMs + 100 + i);
      recordPurchase(
        supplier: sup,
        lines: [PurchaseLine(prods[i].name, 20, (prods[i].price * 0.75).roundToDouble()), if (i + 2 < prods.length) PurchaseLine(prods[i + 2].name, 15, (prods[i + 2].price * 0.75).roundToDouble())],
        supplierRef: 'SUP-${1000 + i}',
        paid: i == 0,
        nowMs: nowMs - i * 5400000,
      );
    }
  }

  void _persistSession() {
    _store.saveBiz(_bizKey);
    _store.saveFlags(_flags);
    _store.saveTemplate(_template);
    _store.savePosTemplate(_posTemplate);
  }

  // -----------------------------------------------------------------------
  // Backup & restore — a single portable snapshot of ALL merchant data.
  // Written to the device/PC or the merchant's own Google Drive (no server).
  // -----------------------------------------------------------------------
  static const backupVersion = 1;

  /// Complete snapshot of every entity + settings for this business.
  Map<String, dynamic> exportData({int nowMs = 0}) => {
    'app': 'BillNex',
    'backupVersion': backupVersion,
    'exportedAt': nowMs,
    'business': _bizKey,
    'edition': business?.edition,
    'profile': _profile?.toJson(),
    'flags': _flags,
    'template': _template,
    'posTemplate': _posTemplate,
    'seq': _seq,
    'rcptSeq': _rcptSeq,
    'purSeq': _purSeq,
    'sales': _sales.map((e) => e.toJson()).toList(),
    'customers': _customers.map((e) => e.toJson()).toList(),
    'ledger': _ledger.map((e) => e.toJson()).toList(),
    'stock': _stock.values.map((e) => e.toJson()).toList(),
    'moves': _moves.map((e) => e.toJson()).toList(),
    'suppliers': _suppliers.map((e) => e.toJson()).toList(),
    'purchases': _purchases.map((e) => e.toJson()).toList(),
    'payables': _payables.map((e) => e.toJson()).toList(),
    'appointments': _appts.map((e) => e.toJson()).toList(),
    'expenses': _expenses.map((e) => e.toJson()).toList(),
    'docs': _docs.map((e) => e.toJson()).toList(),
    'audit': _audit.map((e) => e.toJson()).toList(),
  };

  int? _lastBackupMs;
  int? get lastBackupMs => _lastBackupMs;
  void markBackedUp(int nowMs) {
    _lastBackupMs = nowMs;
    notifyListeners();
  }

  /// True when there is posted data not covered by the last backup — drives the
  /// gentle "back up your data" reminder (data-safety, no server).
  bool get backupDue => billCount > 0 && (_lastBackupMs == null || _sales.any((s) => s.epochMs > _lastBackupMs!));

  /// Replace all in-memory + persisted data with a backup snapshot (restore).
  /// Throws [FormatException] if the payload isn't a valid BillNex backup.
  ///
  /// The whole backup is parsed into locals FIRST, so a single malformed row
  /// aborts the restore before any live data is touched (no half-replaced
  /// state). A backup from a newer app version is also rejected up front.
  Future<void> importData(Map<String, dynamic> d) async {
    if (d['app'] != 'BillNex' || d['backupVersion'] == null) {
      throw const FormatException('Not a BillNex backup file');
    }
    final ver = (d['backupVersion'] as num?)?.toInt();
    if (ver == null || ver > backupVersion) {
      throw FormatException('Backup version $ver is newer than this app supports ($backupVersion). Update BillNex first.');
    }

    // ---- Parse EVERYTHING into locals before mutating any state ----
    List<Map<String, dynamic>> rows(String k) => ((d[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    final BusinessProfile? profile;
    final List<Sale> sales;
    final List<Customer> customers;
    final List<LedgerEntry> ledger;
    final List<StockItem> stock;
    final List<StockMovement> moves;
    final List<Supplier> suppliers;
    final List<Purchase> purchases;
    final List<PayableEntry> payables;
    final List<Appointment> appts;
    final List<Expense> expenses;
    final List<SavedDoc> docs;
    final List<AuditEvent> audit;
    try {
      profile = d['profile'] == null ? null : BusinessProfile.fromJson((d['profile'] as Map).cast<String, dynamic>());
      sales = rows('sales').map(Sale.fromJson).toList();
      customers = rows('customers').map(Customer.fromJson).toList();
      ledger = rows('ledger').map(LedgerEntry.fromJson).toList();
      stock = rows('stock').map(StockItem.fromJson).toList();
      moves = rows('moves').map(StockMovement.fromJson).toList();
      suppliers = rows('suppliers').map(Supplier.fromJson).toList();
      purchases = rows('purchases').map(Purchase.fromJson).toList();
      payables = rows('payables').map(PayableEntry.fromJson).toList();
      appts = rows('appointments').map(Appointment.fromJson).toList();
      expenses = rows('expenses').map(Expense.fromJson).toList();
      docs = rows('docs').map(SavedDoc.fromJson).toList();
      audit = rows('audit').map(AuditEvent.fromJson).toList();
    } catch (e) {
      throw FormatException('Backup is corrupt or incomplete — restore aborted, your data is unchanged ($e)');
    }

    // ---- All parsed OK: now apply atomically ----
    _bizKey = d['business'] as String?;
    _profile = profile;
    _store.saveProfile(_profile);
    _flags
      ..clear()
      ..addEntries(kCapabilities.map((c) => MapEntry(c.key, (d['flags']?[c.key]) == true)));
    _template = (d['template'] as String?) ?? 'classic';
    _posTemplate = (d['posTemplate'] as String?) ?? 'thermal80';
    _seq = (d['seq'] as num?)?.toInt() ?? _seq;
    _rcptSeq = (d['rcptSeq'] as num?)?.toInt() ?? _rcptSeq;
    _purSeq = (d['purSeq'] as num?)?.toInt() ?? _purSeq;

    _sales
      ..clear()
      ..addAll(sales);
    _customers
      ..clear()
      ..addAll(customers);
    _ledger
      ..clear()
      ..addAll(ledger);
    _stock
      ..clear()
      ..addEntries(stock.map((s) => MapEntry(s.sku, s)));
    _moves
      ..clear()
      ..addAll(moves);
    _suppliers
      ..clear()
      ..addAll(suppliers);
    _purchases
      ..clear()
      ..addAll(purchases);
    _payables
      ..clear()
      ..addAll(payables);
    _appts
      ..clear()
      ..addAll(appts);
    _expenses
      ..clear()
      ..addAll(expenses);
    _docs
      ..clear()
      ..addAll(docs);
    _audit
      ..clear()
      ..addAll(audit);

    // Persist the restored state.
    _persistSession();
    await _store.saveSeq(_seq);
    await _store.saveRcptSeq(_rcptSeq);
    await _store.savePurSeq(_purSeq);
    await _store.saveSales(_sales);
    await _store.saveCustomers(_customers);
    await _store.saveLedger(_ledger);
    await _store.saveStock(_stock.values.toList());
    await _store.saveMoves(_moves);
    await _store.saveSuppliers(_suppliers);
    await _store.savePurchases(_purchases);
    await _store.savePayables(_payables);
    await _store.saveAppointments(_appts);
    await _store.saveExpenses(_expenses);
    await _store.saveDocs(_docs);
    await _store.saveAudit(_audit);
    notifyListeners();
  }
}
