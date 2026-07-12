import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';
import '../models/business_profile.dart';
import 'persistence.dart';

/// In-memory [Persistence] — no disk, no platform channels. Used by tests and
/// as the reference implementation proving the storage seam is swappable.
class InMemoryPersistence implements Persistence {
  String? _biz;
  BusinessProfile? _profile;
  Map<String, bool> _flags = {};
  String? _template;
  String? _posTemplate;
  int _seq = 2047, _rcptSeq = 500, _purSeq = 300;
  String? _theme;
  List<Sale> _sales = [];
  List<Customer> _customers = [];
  List<LedgerEntry> _ledger = [];
  List<StockItem>? _stock;
  List<StockMovement> _moves = [];
  List<Supplier> _suppliers = [];
  List<Purchase> _purchases = [];
  List<PayableEntry> _payables = [];
  List<OutboxEvent> _outbox = [];
  List<AuditEvent> _audit = [];
  List<Appointment> _appts = [];

  @override
  Future<String?> loadBiz() async => _biz;
  @override
  Future<void> saveBiz(String? key) async => _biz = key;

  @override
  Future<BusinessProfile?> loadProfile() async => _profile;
  @override
  Future<void> saveProfile(BusinessProfile? profile) async => _profile = profile;

  @override
  Future<Map<String, bool>> loadFlags() async => Map.of(_flags);
  @override
  Future<void> saveFlags(Map<String, bool> flags) async => _flags = Map.of(flags);

  @override
  Future<String?> loadTemplate() async => _template;
  @override
  Future<void> saveTemplate(String id) async => _template = id;
  @override
  Future<String?> loadPosTemplate() async => _posTemplate;
  @override
  Future<void> savePosTemplate(String id) async => _posTemplate = id;

  @override
  Future<int> loadSeq() async => _seq;
  @override
  Future<void> saveSeq(int n) async => _seq = n;
  @override
  Future<int> loadRcptSeq() async => _rcptSeq;
  @override
  Future<void> saveRcptSeq(int n) async => _rcptSeq = n;
  @override
  Future<int> loadPurSeq() async => _purSeq;
  @override
  Future<void> savePurSeq(int n) async => _purSeq = n;

  @override
  Future<String?> loadTheme() async => _theme;
  @override
  Future<void> saveTheme(String mode) async => _theme = mode;

  // Round-trip through JSON so tests exercise (de)serialization too.
  @override
  Future<List<Sale>> loadSales() async => _sales.map((e) => Sale.fromJson(e.toJson())).toList();
  @override
  Future<void> saveSales(List<Sale> sales) async => _sales = List.of(sales);

  @override
  Future<List<Customer>> loadCustomers() async => _customers.map((e) => Customer.fromJson(e.toJson())).toList();
  @override
  Future<void> saveCustomers(List<Customer> list) async => _customers = List.of(list);

  @override
  Future<List<LedgerEntry>> loadLedger() async => _ledger.map((e) => LedgerEntry.fromJson(e.toJson())).toList();
  @override
  Future<void> saveLedger(List<LedgerEntry> list) async => _ledger = List.of(list);

  @override
  Future<List<StockItem>?> loadStock() async => _stock?.map((e) => StockItem.fromJson(e.toJson())).toList();
  @override
  Future<void> saveStock(List<StockItem> list) async => _stock = List.of(list);

  @override
  Future<List<StockMovement>> loadMoves() async => _moves.map((e) => StockMovement.fromJson(e.toJson())).toList();
  @override
  Future<void> saveMoves(List<StockMovement> list) async => _moves = List.of(list);

  @override
  Future<List<Supplier>> loadSuppliers() async => _suppliers.map((e) => Supplier.fromJson(e.toJson())).toList();
  @override
  Future<void> saveSuppliers(List<Supplier> list) async => _suppliers = List.of(list);

  @override
  Future<List<Purchase>> loadPurchases() async => _purchases.map((e) => Purchase.fromJson(e.toJson())).toList();
  @override
  Future<void> savePurchases(List<Purchase> list) async => _purchases = List.of(list);

  @override
  Future<List<PayableEntry>> loadPayables() async => _payables.map((e) => PayableEntry.fromJson(e.toJson())).toList();
  @override
  Future<void> savePayables(List<PayableEntry> list) async => _payables = List.of(list);

  @override
  Future<List<OutboxEvent>> loadOutbox() async => _outbox.map((e) => OutboxEvent.fromJson(e.toJson())).toList();
  @override
  Future<void> saveOutbox(List<OutboxEvent> list) async => _outbox = List.of(list);

  @override
  Future<List<AuditEvent>> loadAudit() async => _audit.map((e) => AuditEvent.fromJson(e.toJson())).toList();
  @override
  Future<void> saveAudit(List<AuditEvent> list) async => _audit = List.of(list);

  @override
  Future<List<Appointment>> loadAppointments() async => _appts.map((e) => Appointment.fromJson(e.toJson())).toList();
  @override
  Future<void> saveAppointments(List<Appointment> list) async => _appts = List.of(list);

  @override
  Future<void> reset() async {
    _biz = null;
    _flags = {};
    _template = null;
    _posTemplate = null;
  }
}
