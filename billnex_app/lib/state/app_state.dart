import 'package:flutter/foundation.dart';
import '../data/catalog.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';
import '../services/store.dart';
import '../services/persistence.dart';
import '../services/sync_service.dart';

class CartLine {
  final Product product;
  int qty;
  CartLine(this.product, [this.qty = 1]);
  double get amount => product.price * qty;
}

/// Central app state — the "Foundation" spine: preset engine + feature flags +
/// cart + template selection + posted-sales history, persisted via [Store].
///
/// Uses [ChangeNotifier] (no extra state-mgmt dependency). Swap for Riverpod
/// when wiring the backend without changing the widget contracts.
class AppState extends ChangeNotifier {
  /// Persistence engine — injectable (defaults to [Store]); a Drift/SQLite or
  /// remote backend can be passed in without changing any business logic.
  final Persistence _store;
  final SyncService _sync;
  AppState({Persistence? persistence, SyncService? sync})
      : _store = persistence ?? Store(),
        _sync = sync ?? const NoopSyncService();

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
  List<PayableEntry> payableLedger(String supplierId) =>
      _payables.where((e) => e.supplierId == supplierId).toList()..sort((a, b) => a.epochMs.compareTo(b.epochMs));
  List<Purchase> purchasesFor(String supplierId) =>
      _purchases.where((p) => p.supplierId == supplierId).toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));

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
        return {'dash', 'billing', 'sales', 'customers'}.contains(navId);
      case Role.accountant:
        return {'dash', 'sales', 'customers', 'purchasing', 'reports'}.contains(navId);
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
  double stockOf(String sku) => _stock[sku]?.qty ?? 0;
  List<StockMovement> movementsFor(String sku) =>
      _moves.where((m) => m.sku == sku).toList()..sort((a, b) => b.epochMs.compareTo(a.epochMs));

  /// Restore persisted session (preset, flags, templates, sales) at startup.
  Future<void> init() async {
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
    _seq = await _store.loadSeq();
    _rcptSeq = await _store.loadRcptSeq();
    _purSeq = await _store.loadPurSeq();
    _sales.addAll(await _store.loadSales());
    _customers.addAll(await _store.loadCustomers());
    _ledger.addAll(await _store.loadLedger());
    _suppliers.addAll(await _store.loadSuppliers());
    _purchases.addAll(await _store.loadPurchases());
    _payables.addAll(await _store.loadPayables());
    _outbox.addAll(await _store.loadOutbox());
    _audit.addAll(await _store.loadAudit());
    _appts.addAll(await _store.loadAppointments());
    final savedStock = await _store.loadStock();
    if (savedStock != null) {
      _stock.addEntries(savedStock.map((s) => MapEntry(s.sku, s)));
      _moves.addAll(await _store.loadMoves());
    } else if (biz != null) {
      _seedStock(biz, 1720000000000);
    }
    _ready = true;
    notifyListeners();
  }

  // ---- selected business / preset ----
  String? _bizKey;
  String? get bizKey => _bizKey;
  BusinessType? get business => _bizKey == null ? null : businessByKey(_bizKey!);
  bool get onboarded => _bizKey != null;

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
  double get subtotal => _cart.fold(0, (a, l) => a + l.amount);
  double get gst => (subtotal * 0.05).roundToDouble();
  double get total => subtotal + gst;
  int get cartQty => _cart.fold(0, (a, l) => a + l.qty);

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
    _seedStock(bizKey, 1720000000000);
    _persistSession();
    notifyListeners();
  }

  /// Seed the stock ledger from the demo catalogue for a business.
  void _seedStock(String bizKey, int nowMs) {
    _stock.clear();
    _moves.clear();
    final prods = productsFor(bizKey);
    final withBatch = isOn('batchExpiry');
    for (var i = 0; i < prods.length; i++) {
      final p = prods[i];
      final qty = ((i * 13 + 8) % 42) + 3.0; // deterministic spread, some low
      final item = StockItem(
        sku: p.name,
        name: p.name,
        unit: p.unit,
        price: p.price,
        cost: (p.price * 0.78).roundToDouble(),
        qty: qty,
      );
      if (withBatch && i < 4) {
        item.batches.add(Batch('B${1000 + i}', nowMs + Duration(days: 30 + i * 40).inMilliseconds, qty));
      }
      _stock[item.sku] = item;
      _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.opening, delta: qty, ref: 'OPENING'));
    }
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
  }

  StockItem addStockItem({required String name, required String unit, required double price, double cost = 0, double qty = 0, double reorder = 10, int nowMs = 0}) {
    final item = StockItem(sku: name.trim(), name: name.trim(), unit: unit, price: price, cost: cost, qty: qty, reorderLevel: reorder);
    _stock[item.sku] = item;
    if (qty != 0) _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.opening, delta: qty, ref: 'OPENING'));
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
    notifyListeners();
    return item;
  }

  /// Manual stock adjustment (BNX-0147) — audited via a movement.
  void adjustStock({required String sku, required double delta, required String reason, MoveKind kind = MoveKind.adjustment, int nowMs = 0}) {
    final item = _stock[sku];
    if (item == null) return;
    item.qty += delta;
    _moves.add(StockMovement(sku: sku, epochMs: nowMs, kind: kind, delta: delta, ref: 'ADJ', reason: reason));
    _store.saveStock(_stock.values.toList());
    _store.saveMoves(_moves);
    _enqueue('adjustment', sku, nowMs);
    _audit0('Stock ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)} · $sku', reason, nowMs);
    notifyListeners();
  }

  void switchBusiness() {
    _bizKey = null;
    _cart.clear();
    _store.saveBiz(null);
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
  void addProduct(Product p) {
    final existing = _cart.where((l) => l.product.name == p.name).firstOrNull;
    if (existing != null) {
      existing.qty++;
    } else {
      _cart.add(CartLine(p));
    }
    notifyListeners();
  }

  void inc(int i) {
    _cart[i].qty++;
    notifyListeners();
  }

  void dec(int i) {
    _cart[i].qty--;
    if (_cart[i].qty <= 0) _cart.removeAt(i);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Posting: turns the cart into an immutable Sale with a unique invoice no.
  // -----------------------------------------------------------------------
  Sale postSale({required String paymentMode, int nowMs = 0, Customer? customer}) {
    _seq += 1;
    final invoiceNo = '#INV-$_seq';
    final sale = Sale(
      invoiceNo: invoiceNo,
      epochMs: nowMs,
      businessName: business!.name,
      templateId: _template,
      lines: _cart.map((l) => SaleLine(l.product.name, l.qty, l.product.price)).toList(),
      subtotal: subtotal,
      gst: gst,
      total: total,
      paymentMode: paymentMode,
    );
    _sales.add(sale);
    // Decrement stock from the ledger for each line (BNX-0137).
    var stockTouched = false;
    for (final l in _cart) {
      final item = _stock[l.product.name];
      if (item != null) {
        item.qty -= l.qty;
        _moves.add(StockMovement(sku: item.sku, epochMs: nowMs, kind: MoveKind.sale, delta: -l.qty.toDouble(), ref: invoiceNo));
        stockTouched = true;
      }
    }
    if (stockTouched) {
      _store.saveStock(_stock.values.toList());
      _store.saveMoves(_moves);
    }
    // Credit sale posts to the customer's ledger as a debit (BNX-0128).
    if (paymentMode == 'Credit' && customer != null) {
      _ledger.add(LedgerEntry(
        customerId: customer.id,
        epochMs: nowMs,
        kind: LedgerKind.creditSale,
        ref: invoiceNo,
        debit: sale.total,
      ));
      _store.saveLedger(_ledger);
    }
    _cart.clear();
    _selectedCustomer = null;
    _store.saveSeq(_seq);
    _store.saveSales(_sales);
    _enqueue('sale', invoiceNo, nowMs);
    _audit0('Sale posted · $paymentMode ${sale.total.round()}', invoiceNo, nowMs);
    notifyListeners();
    return sale;
  }

  double get todaySales => _sales.fold(0, (a, s) => a + s.total);
  int get billCount => _sales.length;

  // -----------------------------------------------------------------------
  // Reports (computed from posted data)
  // -----------------------------------------------------------------------
  double get salesGross => _sales.fold(0.0, (a, s) => a + s.subtotal);
  double get gstCollected => _sales.fold(0.0, (a, s) => a + s.gst);
  double get salesNet => _sales.fold(0.0, (a, s) => a + s.total);
  double get avgBill => _sales.isEmpty ? 0 : salesNet / _sales.length;
  int get itemsSold => _sales.fold(0, (a, s) => a + s.itemCount);

  /// Payment-mode breakdown (PRD BNX-0299).
  Map<String, double> paymentMix() {
    final m = <String, double>{};
    for (final s in _sales) {
      m[s.paymentMode] = (m[s.paymentMode] ?? 0) + s.total;
    }
    return m;
  }

  /// Item-wise sales, best sellers first (PRD BNX-0280).
  List<({String name, int qty, double value})> itemSales() {
    final qty = <String, int>{};
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
    final s = Supplier(id: 'S${nowMs == 0 ? _suppliers.length + 1 : nowMs}', name: name.trim(), phone: phone.trim(), gstin: (gstin?.trim().isEmpty ?? true) ? null : gstin!.trim(), creditDays: creditDays);
    _suppliers.add(s);
    _store.saveSuppliers(_suppliers);
    notifyListeners();
    return s;
  }

  /// Record a purchase: increases stock (movement per line) and creates a
  /// payable if not paid immediately (PRD BNX-0177/0178).
  Purchase recordPurchase({
    required Supplier supplier,
    required List<PurchaseLine> lines,
    required String supplierRef,
    required bool paid,
    int nowMs = 0,
  }) {
    _purSeq += 1;
    final subtotal = lines.fold<double>(0, (a, l) => a + l.amount);
    final gst = (subtotal * 0.05).roundToDouble();
    final total = subtotal + gst;
    final purchaseNo = '#PUR-$_purSeq';
    final purchase = Purchase(
      purchaseNo: purchaseNo, epochMs: nowMs, supplierId: supplier.id, supplierRef: supplierRef.trim(),
      lines: lines, subtotal: subtotal, gst: gst, total: total, paid: paid,
    );
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

  List<LedgerEntry> ledgerFor(String customerId) =>
      _ledger.where((e) => e.customerId == customerId).toList()..sort((a, b) => a.epochMs.compareTo(b.epochMs));

  double balanceOf(String customerId) =>
      _ledger.where((e) => e.customerId == customerId).fold(0.0, (a, e) => a + e.delta);

  double get totalReceivable => _customers.fold(0.0, (a, c) => a + balanceOf(c.id));
  int get overdueCount => _customers.where((c) => balanceOf(c.id) > 0).length;

  bool overLimit(Customer c, double addAmount) =>
      c.creditLimit > 0 && (balanceOf(c.id) + addAmount) > c.creditLimit;

  /// Record a payment against a customer's outstanding (BNX-0129).
  LedgerEntry collect({required Customer customer, required double amount, required String mode, int nowMs = 0}) {
    _rcptSeq += 1;
    final entry = LedgerEntry(
      customerId: customer.id,
      epochMs: nowMs,
      kind: LedgerKind.collection,
      ref: '#RCPT-$_rcptSeq',
      credit: amount,
      mode: mode,
    );
    _ledger.add(entry);
    _store.saveLedger(_ledger);
    _store.saveRcptSeq(_rcptSeq);
    _enqueue('collection', entry.ref, nowMs);
    _audit0('Collection · ${customer.name} ${amount.round()}', entry.ref, nowMs);
    notifyListeners();
    return entry;
  }

  /// Seed a few posted bills + credit customers (previews/demos only).
  void seedDemo(int nowMs) {
    if (_bizKey == null || _sales.isNotEmpty) return;
    final prods = productsFor(_bizKey!);
    final modes = ['Cash', 'UPI', 'Cash'];
    for (var i = 0; i < 3 && i < prods.length; i++) {
      _cart.clear();
      _cart.add(CartLine(prods[i], 2));
      if (i + 1 < prods.length) _cart.add(CartLine(prods[i + 1]));
      postSale(paymentMode: modes[i], nowMs: nowMs - i * 3600000);
    }
    if (isOn('creditLedger')) {
      final names = ['Anita Sharma', 'Ravi Kumar', 'Sunrise Traders'];
      final mobiles = ['98480 11111', '90000 22222', '91234 55555'];
      for (var i = 0; i < 3 && i < prods.length; i++) {
        final cust = addCustomer(name: names[i], mobile: mobiles[i], creditLimit: 5000, consent: true, nowMs: nowMs + i);
        _cart.clear();
        _cart.add(CartLine(prods[i], i + 1));
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
        'audit': _audit.map((e) => e.toJson()).toList(),
      };

  int? _lastBackupMs;
  int? get lastBackupMs => _lastBackupMs;
  void markBackedUp(int nowMs) {
    _lastBackupMs = nowMs;
    notifyListeners();
  }

  /// Replace all in-memory + persisted data with a backup snapshot (restore).
  /// Throws [FormatException] if the payload isn't a BillNex backup.
  Future<void> importData(Map<String, dynamic> d) async {
    if (d['app'] != 'BillNex' || d['backupVersion'] == null) {
      throw const FormatException('Not a BillNex backup file');
    }
    _bizKey = d['business'] as String?;
    _flags
      ..clear()
      ..addEntries(kCapabilities.map((c) => MapEntry(c.key, (d['flags']?[c.key]) == true)));
    _template = (d['template'] as String?) ?? 'classic';
    _posTemplate = (d['posTemplate'] as String?) ?? 'thermal80';
    _seq = (d['seq'] as num?)?.toInt() ?? _seq;
    _rcptSeq = (d['rcptSeq'] as num?)?.toInt() ?? _rcptSeq;
    _purSeq = (d['purSeq'] as num?)?.toInt() ?? _purSeq;

    List<Map<String, dynamic>> rows(String k) =>
        ((d[k] as List?) ?? const []).cast<Map<String, dynamic>>();

    _sales..clear()..addAll(rows('sales').map(Sale.fromJson));
    _customers..clear()..addAll(rows('customers').map(Customer.fromJson));
    _ledger..clear()..addAll(rows('ledger').map(LedgerEntry.fromJson));
    _stock..clear()..addEntries(rows('stock').map(StockItem.fromJson).map((s) => MapEntry(s.sku, s)));
    _moves..clear()..addAll(rows('moves').map(StockMovement.fromJson));
    _suppliers..clear()..addAll(rows('suppliers').map(Supplier.fromJson));
    _purchases..clear()..addAll(rows('purchases').map(Purchase.fromJson));
    _payables..clear()..addAll(rows('payables').map(PayableEntry.fromJson));
    _appts..clear()..addAll(rows('appointments').map(Appointment.fromJson));
    _audit..clear()..addAll(rows('audit').map(AuditEvent.fromJson));

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
    await _store.saveAudit(_audit);
    notifyListeners();
  }
}
