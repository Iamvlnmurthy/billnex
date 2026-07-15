import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/models/sale.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// Additional (non-taxable) charges fold into the grand total, are stored on the
/// Sale, and survive a JSON round-trip; taxable/GST are unchanged.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('delivery charge adds to total, not to taxable/GST', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test', taxInclusive: true));
    final sale = s.postCustomSale(
      lines: [(name: 'Rice', unit: 'kg', qty: 1, rate: 100, gstRate: 0)],
      paymentMode: 'Cash',
      roundOff: false,
      otherCharges: 30,
      chargesLabel: 'Delivery',
      transportNote: 'TS09 AB 1234',
      nowMs: 1,
    );
    expect(sale.subtotal, 100); // taxable unchanged
    expect(sale.gst, 0);
    expect(sale.otherCharges, 30);
    expect(sale.total, 130); // 100 + 30 delivery
    expect(sale.chargesLabel, 'Delivery');
    expect(sale.transportNote, 'TS09 AB 1234');

    final round = Sale.fromJson(sale.toJson());
    expect(round.otherCharges, 30);
    expect(round.chargesLabel, 'Delivery');
    expect(round.transportNote, 'TS09 AB 1234');
    expect(round.total, 130);
  });
}
