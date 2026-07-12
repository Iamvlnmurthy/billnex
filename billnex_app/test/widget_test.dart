import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/main.dart';
import 'package:billnex/services/store.dart';
import 'package:billnex/state/app_state.dart';
import 'package:billnex/data/catalog.dart';
import 'package:billnex/models/sale.dart';
import 'package:billnex/models/supplier.dart';
import 'package:billnex/models/system.dart';
import 'package:billnex/models/appointment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Onboarding shows business types; picking one applies a preset',
      (WidgetTester tester) async {
    final state = AppState();
    await state.init();
    await tester.pumpWidget(BillNexApp(
      state: state,
      themeMode: ValueNotifier(ThemeMode.light),
      store: Store(),
    ));
    await tester.pump();

    // Onboarding hero is present.
    final card = find.text('Kirana / General Store');
    expect(card, findsOneWidget);

    // Tap a business type -> preset applied -> shell shows dashboard greeting.
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.textContaining('Good evening'), findsOneWidget);
  });

  test('applyPreset auto-enables exactly the business capabilities', () {
    final s = AppState();
    s.applyPreset('pharmacy');
    final biz = businessByKey('pharmacy');
    for (final cap in kCapabilities) {
      expect(s.isOn(cap.key), biz.on.contains(cap.key),
          reason: '${cap.key} should match preset membership');
    }
    expect(s.activeCount, biz.on.length);
  });

  test('locked = pro capability not in preset; toggle is a no-op when locked', () {
    final s = AppState();
    s.applyPreset('kirana'); // kirana has no pro caps enabled
    expect(s.isLocked('eInvoice'), true); // pro + not in preset
    s.setFlag('eInvoice', true);
    expect(s.isOn('eInvoice'), false); // stayed off because locked
  });

  test('postSale creates an immutable numbered bill and clears the cart', () {
    final s = AppState();
    s.applyPreset('kirana');
    final p = productsFor('kirana');
    s.addProduct(p[0]);
    s.addProduct(p[0]); // qty 2
    s.addProduct(p[1]);
    expect(s.cartQty, 3);
    final expectedTotal = s.total;

    final sale = s.postSale(paymentMode: 'Cash', nowMs: 1720000000000);
    expect(sale.invoiceNo, startsWith('#INV-'));
    expect(sale.total, expectedTotal);
    expect(sale.itemCount, 3);
    expect(s.cart, isEmpty); // cart cleared after posting
    expect(s.billCount, 1);

    // second sale gets a new, higher invoice number
    s.addProduct(p[0]);
    final sale2 = s.postSale(paymentMode: 'UPI', nowMs: 1720000100000);
    expect(sale2.invoiceNo, isNot(sale.invoiceNo));
  });

  test('credit sale debits customer ledger; collection settles it', () {
    final s = AppState();
    s.applyPreset('kirana'); // has creditLedger
    final cust = s.addCustomer(name: 'Anita Sharma', mobile: '9848000000', creditLimit: 5000);
    final p = productsFor('kirana');
    s.addProduct(p[0]);
    s.addProduct(p[1]);
    final due = s.total;
    final sale = s.postSale(paymentMode: 'Credit', nowMs: 1720000000000, customer: cust);

    expect(sale.paymentMode, 'Credit');
    expect(s.balanceOf(cust.id), due); // ledger debited by invoice total
    expect(s.totalReceivable, due);
    expect(s.selectedCustomer, isNull); // cleared after posting

    // partial then full collection
    s.collect(customer: cust, amount: 100, mode: 'Cash', nowMs: 1720000100000);
    expect(s.balanceOf(cust.id), due - 100);
    s.collect(customer: cust, amount: due - 100, mode: 'UPI', nowMs: 1720000200000);
    expect(s.balanceOf(cust.id), 0);
    expect(s.ledgerFor(cust.id).length, 3); // 1 sale + 2 collections
  });

  test('credit limit detection', () {
    final s = AppState();
    s.applyPreset('kirana');
    final c = s.addCustomer(name: 'X', mobile: '1', creditLimit: 500);
    expect(s.overLimit(c, 400), false);
    expect(s.overLimit(c, 600), true);
  });

  test('stock seeds from preset and decrements on sale', () {
    final s = AppState();
    s.applyPreset('kirana');
    expect(s.stockItems, isNotEmpty);
    final item = s.stockItems.first;
    final before = s.stockOf(item.sku);
    s.addProduct(item.toProduct());
    s.addProduct(item.toProduct()); // qty 2
    s.postSale(paymentMode: 'Cash', nowMs: 1720000000000);
    expect(s.stockOf(item.sku), before - 2);
    // a sale movement was recorded
    expect(s.movementsFor(item.sku).any((m) => m.kind.name == 'sale'), true);
  });

  test('manual adjustment changes qty and low-stock count', () {
    final s = AppState();
    s.applyPreset('kirana');
    final it = s.stockItems.firstWhere((i) => !i.low);
    final q0 = s.stockOf(it.sku);
    s.adjustStock(sku: it.sku, delta: -(q0 - 2), reason: 'test', nowMs: 1);
    expect(s.stockOf(it.sku), 2);
    expect(s.lowStockItems.any((i) => i.sku == it.sku), true); // now below reorder 10
  });

  test('added product is sellable and persisted in stock', () {
    final s = AppState();
    s.applyPreset('kirana');
    final n = s.stockItems.length;
    s.addStockItem(name: 'New SKU', unit: 'Piece', price: 50, qty: 25, nowMs: 1);
    expect(s.stockItems.length, n + 1);
    expect(s.stockOf('New SKU'), 25);
  });

  test('purchase stocks-in and creates a payable; payment settles it', () {
    final s = AppState();
    s.applyPreset('kirana');
    final sup = s.addSupplier(name: 'Metro', phone: '9', nowMs: 1);
    final item = s.stockItems.first;
    final before = s.stockOf(item.sku);
    final pur = s.recordPurchase(
      supplier: sup,
      lines: [PurchaseLine(item.sku, 20, 30)],
      supplierRef: 'INV-1',
      paid: false,
      nowMs: 1720000000000,
    );
    expect(s.stockOf(item.sku), before + 20); // stocked-in
    expect(s.payableOf(sup.id), pur.total); // payable created
    expect(s.isDuplicatePurchase(sup.id, 'INV-1'), true); // duplicate guard
    s.paySupplier(supplier: sup, amount: pur.total, mode: 'Bank', nowMs: 1720000100000);
    expect(s.payableOf(sup.id), 0);
  });

  test('reports aggregate posted sales correctly', () {
    final s = AppState();
    s.applyPreset('kirana');
    final p = productsFor('kirana');
    s.addProduct(p[0]);
    s.addProduct(p[0]);
    s.postSale(paymentMode: 'Cash', nowMs: 1);
    s.addProduct(p[1]);
    s.postSale(paymentMode: 'UPI', nowMs: 2);

    expect(s.billCount, 2);
    expect(s.salesNet, s.salesGross + s.gstCollected);
    final mix = s.paymentMix();
    expect(mix.keys.toSet(), {'Cash', 'UPI'});
    final items = s.itemSales();
    expect(items.first.name, p[0].name); // best seller by value
    expect(items.first.qty, 2);
  });

  test('role gating restricts nav access', () {
    final s = AppState();
    s.applyPreset('kirana');
    s.setRole(Role.cashier);
    expect(s.roleCanAccess('billing'), true);
    expect(s.roleCanAccess('reports'), false); // cashier can't see reports
    expect(s.canSeeCost, false);
    s.setRole(Role.owner);
    expect(s.roleCanAccess('reports'), true);
    expect(s.canSeeCost, true);
  });

  test('offline queues writes; sync flushes idempotently', () {
    final s = AppState();
    s.applyPreset('kirana');
    s.setOnline(false);
    final p = productsFor('kirana');
    s.addProduct(p[0]);
    s.postSale(paymentMode: 'Cash', nowMs: 1);
    s.addProduct(p[1]);
    s.postSale(paymentMode: 'UPI', nowMs: 2);
    expect(s.queueCount, greaterThanOrEqualTo(2)); // unsynced while offline
    s.setOnline(true); // triggers flush
    expect(s.queueCount, 0);
    // audit recorded both sales
    expect(s.auditLog.length, greaterThanOrEqualTo(2));
  });

  test('appointments vertical pack gated by flag', () {
    final s = AppState();
    s.applyPreset('salon'); // has appointments
    expect(s.isOn('appointments'), true);
    final a = s.addAppointment(customer: 'Priya', service: 'Spa', staff: 'Meena', slotMs: 100, nowMs: 1);
    expect(s.upcomingAppts, 1);
    s.setApptStatus(a, ApptStatus.done);
    expect(s.upcomingAppts, 0);

    final k = AppState();
    k.applyPreset('kirana'); // no appointments
    expect(k.isOn('appointments'), false);
  });

  test('Sale JSON round-trips', () {
    const sale = Sale(
      invoiceNo: '#INV-9', epochMs: 1720000000000, businessName: 'Test Shop',
      templateId: 'classic', lines: [SaleLine('A', 2, 50)],
      subtotal: 100, gst: 5, total: 105, paymentMode: 'Cash',
    );
    final back = Sale.fromJson(sale.toJson());
    expect(back.invoiceNo, sale.invoiceNo);
    expect(back.total, sale.total);
    expect(back.lines.single.amount, 100);
  });
}
