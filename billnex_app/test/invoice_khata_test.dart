import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// Invoice-level khata: a credit bill carries a balance-due that partial
/// Payment-Ins (collect against the invoice) whittle down to zero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState seeded() {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test Kirana'));
    return s;
  }

  test('partial payments reduce the invoice balance and the khata', () {
    final s = seeded();
    final cust = s.addCustomer(name: 'Ravi', mobile: '9848000000', creditLimit: 10000, nowMs: 1);
    final sale = s.postCustomSale(
      lines: [(name: 'Rice', unit: 'kg', qty: 1, rate: 100, gstRate: 0)],
      paymentMode: 'Credit',
      customer: cust,
      nowMs: 2,
    );

    expect(sale.total, 100);
    expect(s.invoiceBalance(sale.invoiceNo), 100);
    expect(s.balanceOf(cust.id), 100);
    expect(s.customerForInvoice(sale.invoiceNo)?.id, cust.id);

    // Partial Payment-In.
    s.collect(customer: cust, amount: 40, mode: 'Cash', against: sale.invoiceNo, nowMs: 3);
    expect(s.invoiceBalance(sale.invoiceNo), 60);
    expect(s.balanceOf(cust.id), 60);

    // Settle the rest.
    s.collect(customer: cust, amount: 60, mode: 'UPI', against: sale.invoiceNo, nowMs: 4);
    expect(s.invoiceBalance(sale.invoiceNo), 0);
    expect(s.balanceOf(cust.id), 0);
  });

  test('cash sale has zero invoice balance', () {
    final s = seeded();
    final sale = s.postCustomSale(
      lines: [(name: 'Soap', unit: 'pc', qty: 2, rate: 25, gstRate: 0)],
      paymentMode: 'Cash',
      nowMs: 2,
    );
    expect(s.invoiceBalance(sale.invoiceNo), 0);
    expect(s.customerForInvoice(sale.invoiceNo), isNull);
  });
}
