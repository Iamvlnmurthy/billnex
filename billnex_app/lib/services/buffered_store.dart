import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/supplier.dart';
import '../models/system.dart';
import '../models/appointment.dart';
import '../models/expense.dart';
import '../models/saved_doc.dart';
import '../models/business_profile.dart';
import 'persistence.dart';

/// Durability + error-guard decorator around any [Persistence].
///
/// Every mutation in [AppState] fires its `saveX(...)` without awaiting — the UI
/// must never block on disk. That is correct for latency but leaves two gaps
/// this wrapper closes:
///
///  1. **Silent write failures.** An un-awaited `Future` that throws (disk full,
///     platform-channel error) becomes an unhandled async error. Here each write
///     is `catchError`-guarded so a failed save degrades gracefully instead of
///     crashing the isolate — and the error is surfaced via [lastError] / a debug
///     log so it is observable rather than lost.
///  2. **No durability barrier.** Callers had no way to know when pending writes
///     had settled. [flush] awaits every in-flight write, so the app can drain
///     them on lifecycle pause/detach (see `main.dart`) — the window where a kill
///     could lose the just-posted sale.
///
/// Writes are started **synchronously** (the delegate's `saveX` is invoked
/// immediately, exactly as before), so read-after-write ordering and the
/// platform channel's FIFO are preserved — no behavioural change beyond the two
/// guarantees above. Loads pass straight through.
class BufferedStore implements Persistence {
  BufferedStore(this._d);

  final Persistence _d;
  final Set<Future<void>> _inflight = {};

  /// The most recent write error, if any (cleared on the next successful write).
  Object? lastError;

  /// Number of writes still settling — exposed for diagnostics/tests.
  int get pendingWrites => _inflight.length;

  /// Start [op], guard its error, and register it so [flush] can await it.
  Future<void> _track(Future<void> op) {
    // `op` has already begun (the delegate call ran synchronously up to its
    // first await), preserving prior timing. We only attach tracking + guarding.
    late final Future<void> guarded;
    guarded = op
        .then(
          (_) {
            lastError = null;
          },
          onError: (Object e, StackTrace st) {
            lastError = e;
            if (kDebugMode) debugPrint('BufferedStore write failed: $e');
          },
        )
        .whenComplete(() => _inflight.remove(guarded));
    _inflight.add(guarded);
    return guarded;
  }

  /// Await all in-flight writes. Safe to call repeatedly; resolves immediately
  /// when nothing is pending. New writes enqueued during the drain are included.
  Future<void> flush() async {
    while (_inflight.isNotEmpty) {
      await Future.wait(_inflight.toList());
    }
  }

  // ── Loads: straight passthrough ────────────────────────────────────────
  @override
  Future<String?> loadBiz() => _d.loadBiz();
  @override
  Future<BusinessProfile?> loadProfile() => _d.loadProfile();
  @override
  Future<Map<String, bool>> loadFlags() => _d.loadFlags();
  @override
  Future<String?> loadTemplate() => _d.loadTemplate();
  @override
  Future<String?> loadPosTemplate() => _d.loadPosTemplate();
  @override
  Future<int> loadSeq() => _d.loadSeq();
  @override
  Future<int> loadRcptSeq() => _d.loadRcptSeq();
  @override
  Future<int> loadPurSeq() => _d.loadPurSeq();
  @override
  Future<String?> loadTheme() => _d.loadTheme();
  @override
  Future<List<Sale>> loadSales() => _d.loadSales();
  @override
  Future<List<Customer>> loadCustomers() => _d.loadCustomers();
  @override
  Future<List<LedgerEntry>> loadLedger() => _d.loadLedger();
  @override
  Future<List<StockItem>?> loadStock() => _d.loadStock();
  @override
  Future<List<StockMovement>> loadMoves() => _d.loadMoves();
  @override
  Future<List<Supplier>> loadSuppliers() => _d.loadSuppliers();
  @override
  Future<List<Purchase>> loadPurchases() => _d.loadPurchases();
  @override
  Future<List<PayableEntry>> loadPayables() => _d.loadPayables();
  @override
  Future<List<OutboxEvent>> loadOutbox() => _d.loadOutbox();
  @override
  Future<List<AuditEvent>> loadAudit() => _d.loadAudit();
  @override
  Future<List<Appointment>> loadAppointments() => _d.loadAppointments();

  // ── Writes: started immediately, tracked + guarded ─────────────────────
  @override
  Future<void> saveBiz(String? key) => _track(_d.saveBiz(key));
  @override
  Future<void> saveProfile(BusinessProfile? profile) => _track(_d.saveProfile(profile));
  @override
  Future<void> saveFlags(Map<String, bool> flags) => _track(_d.saveFlags(flags));
  @override
  Future<void> saveTemplate(String id) => _track(_d.saveTemplate(id));
  @override
  Future<void> savePosTemplate(String id) => _track(_d.savePosTemplate(id));
  @override
  Future<void> saveSeq(int n) => _track(_d.saveSeq(n));
  @override
  Future<void> saveRcptSeq(int n) => _track(_d.saveRcptSeq(n));
  @override
  Future<void> savePurSeq(int n) => _track(_d.savePurSeq(n));
  @override
  Future<void> saveTheme(String mode) => _track(_d.saveTheme(mode));
  @override
  Future<void> saveSales(List<Sale> sales) => _track(_d.saveSales(sales));
  @override
  Future<void> saveCustomers(List<Customer> list) => _track(_d.saveCustomers(list));
  @override
  Future<void> saveLedger(List<LedgerEntry> list) => _track(_d.saveLedger(list));
  @override
  Future<void> saveStock(List<StockItem> list) => _track(_d.saveStock(list));
  @override
  Future<void> saveMoves(List<StockMovement> list) => _track(_d.saveMoves(list));
  @override
  Future<void> saveSuppliers(List<Supplier> list) => _track(_d.saveSuppliers(list));
  @override
  Future<void> savePurchases(List<Purchase> list) => _track(_d.savePurchases(list));
  @override
  Future<void> savePayables(List<PayableEntry> list) => _track(_d.savePayables(list));
  @override
  Future<void> saveOutbox(List<OutboxEvent> list) => _track(_d.saveOutbox(list));
  @override
  Future<void> saveAudit(List<AuditEvent> list) => _track(_d.saveAudit(list));
  @override
  Future<void> saveAppointments(List<Appointment> list) => _track(_d.saveAppointments(list));

  @override
  Future<List<Expense>> loadExpenses() => _d.loadExpenses();
  @override
  Future<void> saveExpenses(List<Expense> list) => _track(_d.saveExpenses(list));

  @override
  Future<int?> loadLastBackup() => _d.loadLastBackup();
  @override
  Future<void> saveLastBackup(int ms) => _track(_d.saveLastBackup(ms));

  @override
  Future<List<SavedDoc>> loadDocs() => _d.loadDocs();
  @override
  Future<void> saveDocs(List<SavedDoc> list) => _track(_d.saveDocs(list));
  @override
  Future<void> reset() => _track(_d.reset());
}
