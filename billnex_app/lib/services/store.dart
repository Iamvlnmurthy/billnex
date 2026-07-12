import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';
import 'persistence.dart';

/// SharedPreferences-backed [Persistence] (JSON blobs) — the default engine.
///
/// Works on every platform with no codegen. A Drift/SQLite or remote backend
/// can replace it by implementing [Persistence]; [AppState] is unaffected.
class Store implements Persistence {
  static const _kBiz = 'bx_biz';
  static const _kFlags = 'bx_flags';
  static const _kTemplate = 'bx_template';
  static const _kPosTemplate = 'bx_pos_template';
  static const _kSales = 'bx_sales';
  static const _kSeq = 'bx_seq';
  static const _kTheme = 'bx_theme';
  static const _kCustomers = 'bx_customers';
  static const _kLedger = 'bx_ledger';
  static const _kRcptSeq = 'bx_rcpt_seq';
  static const _kStock = 'bx_stock';
  static const _kMoves = 'bx_moves';
  static const _kSuppliers = 'bx_suppliers';
  static const _kPurchases = 'bx_purchases';
  static const _kPayables = 'bx_payables';
  static const _kPurSeq = 'bx_pur_seq';
  static const _kOutbox = 'bx_outbox';
  static const _kAudit = 'bx_audit';
  static const _kAppts = 'bx_appts';

  SharedPreferences? _p;
  Future<SharedPreferences> get _prefs async => _p ??= await SharedPreferences.getInstance();

  @override
  Future<String?> loadBiz() async => (await _prefs).getString(_kBiz);
  @override
  Future<void> saveBiz(String? key) async {
    final p = await _prefs;
    if (key == null) {
      await p.remove(_kBiz);
    } else {
      await p.setString(_kBiz, key);
    }
  }

  @override
  Future<Map<String, bool>> loadFlags() async {
    final raw = (await _prefs).getString(_kFlags);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v == true));
  }

  @override
  Future<void> saveFlags(Map<String, bool> flags) async =>
      (await _prefs).setString(_kFlags, jsonEncode(flags));

  @override
  Future<String?> loadTemplate() async => (await _prefs).getString(_kTemplate);
  @override
  Future<void> saveTemplate(String id) async => (await _prefs).setString(_kTemplate, id);

  @override
  Future<String?> loadPosTemplate() async => (await _prefs).getString(_kPosTemplate);
  @override
  Future<void> savePosTemplate(String id) async => (await _prefs).setString(_kPosTemplate, id);

  @override
  Future<int> loadSeq() async => (await _prefs).getInt(_kSeq) ?? 2047;
  @override
  Future<void> saveSeq(int n) async => (await _prefs).setInt(_kSeq, n);

  @override
  Future<List<Sale>> loadSales() async {
    final raw = (await _prefs).getString(_kSales);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveSales(List<Sale> sales) async =>
      (await _prefs).setString(_kSales, jsonEncode(sales.map((e) => e.toJson()).toList()));

  @override
  Future<String?> loadTheme() async => (await _prefs).getString(_kTheme);
  @override
  Future<void> saveTheme(String mode) async => (await _prefs).setString(_kTheme, mode);

  @override
  Future<int> loadRcptSeq() async => (await _prefs).getInt(_kRcptSeq) ?? 500;
  @override
  Future<void> saveRcptSeq(int n) async => (await _prefs).setInt(_kRcptSeq, n);

  @override
  Future<List<Customer>> loadCustomers() async {
    final raw = (await _prefs).getString(_kCustomers);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveCustomers(List<Customer> list) async =>
      (await _prefs).setString(_kCustomers, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<LedgerEntry>> loadLedger() async {
    final raw = (await _prefs).getString(_kLedger);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveLedger(List<LedgerEntry> list) async =>
      (await _prefs).setString(_kLedger, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<StockItem>?> loadStock() async {
    final raw = (await _prefs).getString(_kStock);
    if (raw == null) return null; // null = not seeded yet
    return (jsonDecode(raw) as List).map((e) => StockItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveStock(List<StockItem> list) async =>
      (await _prefs).setString(_kStock, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<StockMovement>> loadMoves() async {
    final raw = (await _prefs).getString(_kMoves);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => StockMovement.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveMoves(List<StockMovement> list) async =>
      (await _prefs).setString(_kMoves, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<int> loadPurSeq() async => (await _prefs).getInt(_kPurSeq) ?? 300;
  @override
  Future<void> savePurSeq(int n) async => (await _prefs).setInt(_kPurSeq, n);

  @override
  Future<List<Supplier>> loadSuppliers() async {
    final raw = (await _prefs).getString(_kSuppliers);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveSuppliers(List<Supplier> list) async =>
      (await _prefs).setString(_kSuppliers, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<Purchase>> loadPurchases() async {
    final raw = (await _prefs).getString(_kPurchases);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Purchase.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> savePurchases(List<Purchase> list) async =>
      (await _prefs).setString(_kPurchases, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<PayableEntry>> loadPayables() async {
    final raw = (await _prefs).getString(_kPayables);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => PayableEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> savePayables(List<PayableEntry> list) async =>
      (await _prefs).setString(_kPayables, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<OutboxEvent>> loadOutbox() async {
    final raw = (await _prefs).getString(_kOutbox);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => OutboxEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveOutbox(List<OutboxEvent> list) async =>
      (await _prefs).setString(_kOutbox, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<AuditEvent>> loadAudit() async {
    final raw = (await _prefs).getString(_kAudit);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => AuditEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveAudit(List<AuditEvent> list) async =>
      (await _prefs).setString(_kAudit, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<List<Appointment>> loadAppointments() async {
    final raw = (await _prefs).getString(_kAppts);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveAppointments(List<Appointment> list) async =>
      (await _prefs).setString(_kAppts, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  Future<void> reset() async {
    final p = await _prefs;
    for (final k in [_kBiz, _kFlags, _kTemplate, _kPosTemplate]) {
      await p.remove(k);
    }
  }
}
