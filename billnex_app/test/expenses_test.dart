import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';

/// Expenses accumulate by category and subtract from gross to give net profit.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('expenses feed totals, categories and net profit', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));

    // A sale so gross profit is positive: sell 1 @ 100 (cost 0), gst 0.
    s.postCustomSale(lines: [(name: 'Rice', unit: 'kg', qty: 1, rate: 100, gstRate: 0)], paymentMode: 'Cash', roundOff: false, nowMs: 1);

    s.addExpense(category: 'Rent', amount: 30, nowMs: 2);
    s.addExpense(category: 'Transport', amount: 20, mode: 'UPI', nowMs: 3);
    s.addExpense(category: 'Rent', amount: 10, nowMs: 4);

    expect(s.totalExpenses, 60);

    final byCat = s.expensesByCategory();
    expect(byCat.first.category, 'Rent'); // largest first
    expect(byCat.first.amount, 40);

    final pl = s.profitAndLoss();
    expect(pl.grossProfit, 100);
    expect(pl.expenses, 60);
    expect(pl.netProfit, 40); // 100 - 60

    s.deleteExpense(s.expenses.firstWhere((e) => e.category == 'Transport').id);
    expect(s.totalExpenses, 40);
  });
}
