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
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/services/auth_service.dart';
import 'package:billnex/services/integrations.dart';
import 'package:billnex/services/sync_service.dart';
import 'package:billnex/services/billing.dart';

/// Records pushes so we can assert the outbox was flushed to a backend.
class _FakeSync implements SyncService {
  int pushedCount = 0;
  @override
  bool get isConfigured => true;
  @override
  Future<SyncResult> push(List<OutboxEvent> events) async {
    pushedCount += events.length;
    return SyncResult(accepted: events.length);
  }
  @override
  Future<List<OutboxEvent>> pull({int sinceRev = 0}) async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('billing engine', () {
    test('tax-exclusive: GST added on top, CGST/SGST split', () {
      final b = computeBill(lines: const [BillInput(price: 100, qty: 2, gstRate: 18)], taxInclusive: false);
      expect(b.taxable, 200);
      expect(b.tax, 36);
      expect(b.cgst, 18);
      expect(b.sgst, 18);
      expect(b.total, 236);
    });
    test('tax-inclusive: price already includes GST', () {
      final b = computeBill(lines: const [BillInput(price: 118, qty: 1, gstRate: 18)], taxInclusive: true);
      expect(b.taxable, 100);
      expect(b.tax, 18);
      expect(b.total, 118);
    });
    test('mixed rates aggregate by rate', () {
      final b = computeBill(lines: const [
        BillInput(price: 100, qty: 1, gstRate: 5),
        BillInput(price: 100, qty: 1, gstRate: 12),
      ], taxInclusive: false);
      expect(b.byRate[5]!.tax, 5);
      expect(b.byRate[12]!.tax, 12);
      expect(b.tax, 17);
    });
    test('discounts reduce taxable; total is rounded', () {
      final b = computeBill(
        lines: const [BillInput(price: 100, qty: 1, gstRate: 18, lineDiscount: 10)],
        taxInclusive: false, billDiscount: 5);
      expect(b.taxable, 85);
      expect(b.discountTotal, 15);
      expect(b.total, b.total.roundToDouble());
      expect(b.roundOff.abs() <= 0.5, true);
    });
    test('empty bill is zero', () {
      expect(computeBill(lines: const [], taxInclusive: true).total, 0);
    });
  });

  testWidgets('Onboarding renders the business-type picker', (WidgetTester tester) async {
    final state = AppState();
    await state.init();
    await tester.pumpWidget(BillNexApp(
      state: state,
      themeMode: ValueNotifier(ThemeMode.light),
      locale: ValueNotifier(null),
      store: Store(),
      auth: AuthService(),
    ));
    await tester.pumpAndSettle(); // let the staggered card reveal timers finish
    expect(find.text('Kirana / General Store'), findsOneWidget);
    expect(find.textContaining('Pick your business'), findsOneWidget);
  });

  test('setupBusiness onboards with a real profile and empty catalogue', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Rajesh Kirana Store', gstin: '36ABCDE1234F1Z5', phone: '9848000000'));
    expect(s.onboarded, true);
    expect(s.shopName, 'Rajesh Kirana Store');
    expect(s.gstin, '36ABCDE1234F1Z5');
    expect(s.stockItems, isEmpty); // no fake demo data
    // a sale carries the seller's real GSTIN for correct reprints
    s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 10, nowMs: 1);
    s.addProduct(s.stockItems.first);
    final sale = s.postSale(paymentMode: 'Cash', nowMs: 2);
    expect(sale.businessName, 'Rajesh Kirana Store');
    expect(sale.sellerGstin, '36ABCDE1234F1Z5');
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
    final p = [s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 100, nowMs: 1), s.addStockItem(name: 'Oil', unit: 'L', price: 100, qty: 100, nowMs: 1)];
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
    final p = [s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 100, nowMs: 1), s.addStockItem(name: 'Oil', unit: 'L', price: 100, qty: 100, nowMs: 1)];
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

  test('catalogue starts empty; added product decrements on sale', () {
    final s = AppState();
    s.applyPreset('kirana');
    expect(s.stockItems, isEmpty); // real installs start with no products
    final item = s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 20, nowMs: 1);
    final before = s.stockOf(item.sku);
    s.addProduct(item);
    s.addProduct(item); // qty 2
    s.postSale(paymentMode: 'Cash', nowMs: 1720000000000);
    expect(s.stockOf(item.sku), before - 2);
    expect(s.movementsFor(item.sku).any((m) => m.kind.name == 'sale'), true);
  });

  test('manual adjustment changes qty and low-stock count', () {
    final s = AppState();
    s.applyPreset('kirana');
    final it = s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 20, nowMs: 1);
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
    final item = s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 5, nowMs: 1);
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
    final p = [s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 100, nowMs: 1), s.addStockItem(name: 'Oil', unit: 'L', price: 100, qty: 100, nowMs: 1)];
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
    final p = [s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 100, nowMs: 1), s.addStockItem(name: 'Oil', unit: 'L', price: 100, qty: 100, nowMs: 1)];
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

  test('state persists across restart via the Persistence seam', () async {
    final backend = InMemoryPersistence();

    // Session 1: set up a shop, post sales, add a credit customer.
    final s1 = AppState(persistence: backend);
    await s1.init();
    s1.applyPreset('kirana');
    final cust = s1.addCustomer(name: 'Anita', mobile: '9', creditLimit: 5000, nowMs: 1);
    final item = s1.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 20, nowMs: 1);
    final stockBefore = s1.stockOf(item.sku);
    s1.addProduct(item);
    s1.postSale(paymentMode: 'Credit', nowMs: 2, customer: cust);
    final bills = s1.billCount;
    final due = s1.balanceOf(cust.id);

    // Session 2: fresh AppState, same backend → state restored.
    final s2 = AppState(persistence: backend);
    await s2.init();
    expect(s2.onboarded, true);
    expect(s2.bizKey, 'kirana');
    expect(s2.billCount, bills);
    expect(s2.customers.length, 1);
    expect(s2.balanceOf(cust.id), due);
    expect(s2.stockOf(item.sku), stockBefore - 1); // stock decrement persisted
  });

  test('syncNow pushes unsynced events to a configured backend', () async {
    final fake = _FakeSync();
    final s = AppState(sync: fake);
    s.applyPreset('kirana');
    s.setOnline(false); // queue while offline
    s.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 100, nowMs: 1); s.addProduct(s.stockItems.first);
    s.postSale(paymentMode: 'Cash', nowMs: 1);
    expect(s.queueCount, greaterThanOrEqualTo(1));

    await s.syncNow(); // configured backend → pushes
    expect(fake.pushedCount, greaterThanOrEqualTo(1));
    expect(s.queueCount, 0); // marked synced after successful push
  });

  test('backup export/import restores all data on a fresh device', () async {
    // Shop A builds up data.
    final a = AppState(persistence: InMemoryPersistence());
    await a.init();
    a.applyPreset('kirana');
    final cust = a.addCustomer(name: 'Ravi', mobile: '9', creditLimit: 5000, nowMs: 1);
    a.addStockItem(name: 'Rice', unit: 'kg', price: 50, qty: 20, nowMs: 1);
    a.addProduct(a.stockItems.first);
    a.postSale(paymentMode: 'Credit', nowMs: 2, customer: cust);
    final blob = a.exportData(nowMs: 3);

    // A new install on another device restores from the file.
    final b = AppState(persistence: InMemoryPersistence());
    await b.init();
    await b.importData(blob);
    expect(b.bizKey, 'kirana');
    expect(b.billCount, a.billCount);
    expect(b.customers.length, 1);
    expect(b.balanceOf(cust.id), a.balanceOf(cust.id));
    expect(b.stockItems.length, a.stockItems.length);
  });

  test('importData rejects a non-BillNex file', () async {
    final s = AppState(persistence: InMemoryPersistence());
    await s.init();
    expect(() => s.importData({'app': 'SomethingElse'}), throwsFormatException);
  });

  test('UPI intent builds a valid pay deep link', () {
    final uri = Uri.parse(UpiService.buildIntent(
      payeeVpa: 'billnex@upi', payeeName: 'Kirana Store', amount: 1302.5, txnRef: 'INV-2048', note: 'Bill'));
    expect(uri.scheme, 'upi');
    expect(uri.queryParameters['pa'], 'billnex@upi');
    expect(uri.queryParameters['am'], '1302.50');
    expect(uri.queryParameters['cu'], 'INR');
    expect(uri.queryParameters['tr'], 'INV-2048');
  });

  test('WhatsApp link strips non-digits and encodes text', () {
    final link = WhatsAppService.invoiceLink(phone: '+91 98480 00000', message: 'Total ₹105');
    expect(link.startsWith('https://wa.me/919848000000?text='), true);
    expect(link.contains('%E2%82%B9'), true); // ₹ encoded
  });

  test('e-invoice payload has correct GST split and doc no', () {
    const sale = Sale(
      invoiceNo: '#INV-9', epochMs: 1720000000000, businessName: 'Shop',
      templateId: 'classic', lines: [SaleLine('A', 2, 50)],
      subtotal: 100, gst: 6, total: 106, paymentMode: 'Cash');
    final p = EInvoiceService.buildPayload(sale: sale, sellerGstin: '36ABCDE1234F1Z5', sellerLegalName: 'Shop', sellerStateCode: '36');
    expect(p['DocDtls']['No'], 'INV-9');
    expect(p['ValDtls']['CgstVal'], 3.0);
    expect(p['ValDtls']['SgstVal'], 3.0);
    expect(p['ValDtls']['TotInvVal'], 106);
    expect((p['ItemList'] as List).length, 1);
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
