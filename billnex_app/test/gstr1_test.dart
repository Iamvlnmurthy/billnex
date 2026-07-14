import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// GSTR-1 rate-wise (B2C) aggregation: taxable + CGST/SGST per GST rate,
/// tax-inclusive pricing, with returns netting off.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState seeded() {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test Kirana', taxInclusive: true));
    return s;
  }

  test('rate-wise taxable and CGST/SGST split', () {
    final s = seeded();
    // ₹105 incl @5% → taxable 100, tax 5 (cgst 2.5 / sgst 2.5)
    s.postCustomSale(lines: [(name: 'Rice', unit: 'kg', qty: 1, rate: 105, gstRate: 5)], paymentMode: 'Cash', taxInclusive: true, roundOff: false, nowMs: 1);
    // ₹118 incl @18% → taxable 100, tax 18 (cgst 9 / sgst 9)
    s.postCustomSale(lines: [(name: 'Soap', unit: 'pc', qty: 1, rate: 118, gstRate: 18)], paymentMode: 'UPI', taxInclusive: true, roundOff: false, nowMs: 2);

    final g = s.gstr1Summary();
    expect(g.length, 2);

    final r5 = g.firstWhere((r) => r.rate == 5);
    expect(r5.taxable, closeTo(100, 0.01));
    expect(r5.cgst, closeTo(2.5, 0.01));
    expect(r5.sgst, closeTo(2.5, 0.01));
    expect(r5.invoices, 1);

    final r18 = g.firstWhere((r) => r.rate == 18);
    expect(r18.taxable, closeTo(100, 0.01));
    expect(r18.cgst, closeTo(9, 0.01));

    // CSV has a header + two rate rows.
    expect(s.gstr1Csv().trim().split('\n').length, 3);
  });
}
