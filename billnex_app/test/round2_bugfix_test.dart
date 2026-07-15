import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/models/supplier.dart';

/// Regression tests for the round-2 feature audit fixes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState seeded() {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));
    return s;
  }

  test('local backup timestamp persists across a restart (Store)', () async {
    SharedPreferences.setMockInitialValues({});
    final s1 = AppState(); // real Store (SharedPreferences)
    await s1.init();
    s1.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test'));
    s1.markBackedUp(1720000000000);
    await s1.flush();

    final s2 = AppState(); // fresh app instance = restart
    await s2.init();
    expect(s2.lastBackupMs, 1720000000000); // was null → "Never backed up"
  });

  test('restore does not immediately flag backup-due', () async {
    final s = seeded();
    s.addExpense(category: 'Rent', amount: 10, nowMs: 1);
    final snap = s.exportData(nowMs: 5000);
    final s2 = seeded();
    await s2.importData(snap);
    expect(s2.lastBackupMs, 5000); // restored → not "backup due"
  });

  test('renamed product still decrements stock when billed by new name', () {
    final s = seeded();
    final item = s.addStockItem(name: 'Aple', unit: 'pc', price: 20, qty: 10, gstRate: 0, nowMs: 1)!;
    s.editStockItem(item.sku, name: 'Apple', nowMs: 2); // rename; sku stays 'Aple'
    s.postCustomSale(lines: [(name: 'Apple', unit: 'pc', qty: 3, rate: 20, gstRate: 0)], paymentMode: 'Cash', nowMs: 3);
    expect(s.stockOf(item.sku), 7); // was 10 (rename broke the name→sku lookup)
  });

  test('oversell records the actual decrement so the movement ledger reconciles', () {
    final s = seeded();
    final item = s.addStockItem(name: 'Milk', unit: 'pc', price: 30, qty: 3, gstRate: 0, nowMs: 1)!;
    s.postCustomSale(lines: [(name: 'Milk', unit: 'pc', qty: 10, rate: 30, gstRate: 0)], paymentMode: 'Cash', nowMs: 2);
    expect(s.stockOf(item.sku), 0);
    final moved = s.movementsFor(item.sku).where((m) => m.ref.startsWith('#INV')).fold<double>(0, (a, m) => a + m.delta);
    expect(moved, -3); // recorded actual (−3), not the requested −10
  });

  test('a bill can only be returned once', () {
    final s = seeded();
    final item = s.addStockItem(name: 'Soap', unit: 'pc', price: 25, qty: 10, gstRate: 0, nowMs: 1)!;
    final sale = s.postCustomSale(lines: [(name: 'Soap', unit: 'pc', qty: 2, rate: 25, gstRate: 0)], paymentMode: 'Cash', nowMs: 2);
    expect(s.stockOf(item.sku), 8);
    final r1 = s.returnSale(sale, nowMs: 3);
    final r2 = s.returnSale(sale, nowMs: 4); // double-tap
    expect(r1.invoiceNo, r2.invoiceNo); // same credit note, not a second one
    expect(s.stockOf(item.sku), 10); // restocked once (not 12)
  });

  test('supplier over-payment is capped at the amount owed', () {
    final s = seeded();
    final sup = s.addSupplier(name: 'Metro', phone: '9000', nowMs: 1);
    s.recordPurchase(supplier: sup, lines: [const PurchaseLine('X', 10, 50)], supplierRef: 'REF-1', paid: false, nowMs: 2); // owe 500
    s.paySupplier(supplier: sup, amount: 800, mode: 'Cash', nowMs: 3); // overpay
    expect(s.payableOf(sup.id), 0); // not negative -300
  });
}
