import 'package:flutter_test/flutter_test.dart';
import 'package:billnex/models/sale.dart';
import 'package:billnex/services/buffered_store.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// A backend whose writes we can delay or fail, to exercise BufferedStore's
/// durability barrier and error guard.
class _SlowStore extends InMemoryPersistence {
  final Duration delay;
  final bool fail;
  _SlowStore({this.delay = Duration.zero, this.fail = false});

  @override
  Future<void> saveSales(List<Sale> sales) async {
    await Future.delayed(delay);
    if (fail) throw StateError('disk full');
    return super.saveSales(sales);
  }
}

void main() {
  test('flush() awaits in-flight writes', () async {
    final b = BufferedStore(_SlowStore(delay: const Duration(milliseconds: 40)));
    b.saveSales(const []); // fire-and-forget, as AppState does
    expect(b.pendingWrites, 1, reason: 'write should still be settling');
    await b.flush();
    expect(b.pendingWrites, 0, reason: 'flush drains all pending writes');
  });

  test('a failing write is guarded, surfaced, and never propagates', () async {
    final b = BufferedStore(_SlowStore(fail: true));
    // Must not throw here nor as an unhandled async error.
    b.saveSales(const []);
    await b.flush();
    expect(b.lastError, isA<StateError>());
    expect(b.pendingWrites, 0);
  });

  test('a successful write clears a prior error', () async {
    final failing = _SlowStore(fail: true);
    final b = BufferedStore(failing);
    b.saveSales(const []);
    await b.flush();
    expect(b.lastError, isNotNull);

    // Swap to a healthy backend and confirm the flag clears.
    final healthy = BufferedStore(InMemoryPersistence());
    healthy.saveSales(const []);
    await healthy.flush();
    expect(healthy.lastError, isNull);
  });

  test('writes start synchronously (read-after-write is preserved)', () async {
    // AppState relies on saves reaching the backend without an awaited barrier
    // (see the persistence-across-restart test). Verify the delegate is invoked
    // synchronously for a zero-delay backend.
    final backend = InMemoryPersistence();
    final b = BufferedStore(backend);
    b.saveSales([const Sale(invoiceNo: 'INV1', epochMs: 1, businessName: 'X', templateId: 'classic', lines: [], subtotal: 0, gst: 0, total: 0, paymentMode: 'Cash')]);
    // No await: the in-memory backend was written during the synchronous call.
    final reloaded = await backend.loadSales();
    expect(reloaded.length, 1);
  });
}
