import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/models/saved_doc.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// Estimates/orders save without touching stock, and converting one posts a real
/// invoice (decrementing stock) and removes the document.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save estimate does not post; convert posts an invoice and removes it', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));
    final item = s.addStockItem(name: 'Rice', unit: 'kg', price: 100, qty: 10, gstRate: 0, nowMs: 1)!;

    final doc = s.saveDoc(
      type: DocType.estimate,
      lines: [(name: item.name, unit: 'kg', qty: 2, rate: 100, gstRate: 0)],
      nowMs: 2,
    );
    expect(doc.number, '#EST-1');
    expect(s.docsOfType(DocType.estimate).length, 1);
    expect(s.billCount, 0); // no invoice posted
    expect(s.stockOf(item.sku), 10); // stock untouched

    final sale = s.convertDoc(doc, paymentMode: 'Cash', nowMs: 3);
    expect(sale.invoiceNo, startsWith('#INV-'));
    expect(sale.total, 200);
    expect(s.billCount, 1); // invoice now posted
    expect(s.stockOf(item.sku), 8); // 2 sold
    expect(s.docsOfType(DocType.estimate).isEmpty, true); // doc consumed
  });

  test('order numbers increment independently', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));
    final a = s.saveDoc(type: DocType.order, lines: [(name: 'X', unit: 'pc', qty: 1, rate: 50, gstRate: 0)], nowMs: 1);
    final b = s.saveDoc(type: DocType.order, lines: [(name: 'Y', unit: 'pc', qty: 1, rate: 50, gstRate: 0)], nowMs: 2);
    expect(a.number, '#ORD-1');
    expect(b.number, '#ORD-2');
  });

  test('doc numbers are not reused after the highest is converted', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));
    final d1 = s.saveDoc(type: DocType.estimate, lines: [(name: 'A', unit: 'pc', qty: 1, rate: 50, gstRate: 0)], nowMs: 1);
    final d2 = s.saveDoc(type: DocType.estimate, lines: [(name: 'B', unit: 'pc', qty: 1, rate: 50, gstRate: 0)], nowMs: 2);
    expect(d1.number, '#EST-1');
    expect(d2.number, '#EST-2');
    s.convertDoc(d2, paymentMode: 'Cash', nowMs: 3); // removes #EST-2
    final d3 = s.saveDoc(type: DocType.estimate, lines: [(name: 'C', unit: 'pc', qty: 1, rate: 50, gstRate: 0)], nowMs: 4);
    expect(d3.number, '#EST-3'); // was '#EST-2' again (number reuse)
  });
}
