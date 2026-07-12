import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';

/// Persistence seam for the whole app.
///
/// [AppState] depends on this interface, never on a concrete backend, so the
/// storage engine is swappable without touching business logic:
///   - [Store]         — shared_preferences (default; works on every platform)
///   - `DriftStore`    — Drift/SQLite (native; drop-in, P2 on-device)
///   - `RemoteStore`   — REST/Supabase adapter (P5, wraps a local cache)
///
/// Every method is async so a networked implementation fits the same contract.
abstract interface class Persistence {
  Future<String?> loadBiz();
  Future<void> saveBiz(String? key);

  Future<Map<String, bool>> loadFlags();
  Future<void> saveFlags(Map<String, bool> flags);

  Future<String?> loadTemplate();
  Future<void> saveTemplate(String id);
  Future<String?> loadPosTemplate();
  Future<void> savePosTemplate(String id);

  Future<int> loadSeq();
  Future<void> saveSeq(int n);
  Future<int> loadRcptSeq();
  Future<void> saveRcptSeq(int n);
  Future<int> loadPurSeq();
  Future<void> savePurSeq(int n);

  Future<String?> loadTheme();
  Future<void> saveTheme(String mode);

  Future<List<Sale>> loadSales();
  Future<void> saveSales(List<Sale> sales);

  Future<List<Customer>> loadCustomers();
  Future<void> saveCustomers(List<Customer> list);

  Future<List<LedgerEntry>> loadLedger();
  Future<void> saveLedger(List<LedgerEntry> list);

  /// Returns null when stock has never been seeded (vs. an empty list).
  Future<List<StockItem>?> loadStock();
  Future<void> saveStock(List<StockItem> list);

  Future<List<StockMovement>> loadMoves();
  Future<void> saveMoves(List<StockMovement> list);

  Future<List<Supplier>> loadSuppliers();
  Future<void> saveSuppliers(List<Supplier> list);

  Future<List<Purchase>> loadPurchases();
  Future<void> savePurchases(List<Purchase> list);

  Future<List<PayableEntry>> loadPayables();
  Future<void> savePayables(List<PayableEntry> list);

  Future<List<OutboxEvent>> loadOutbox();
  Future<void> saveOutbox(List<OutboxEvent> list);

  Future<List<AuditEvent>> loadAudit();
  Future<void> saveAudit(List<AuditEvent> list);

  Future<List<Appointment>> loadAppointments();
  Future<void> saveAppointments(List<Appointment> list);

  Future<void> reset();
}
