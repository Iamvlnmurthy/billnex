import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/theme/app_theme.dart';
import 'package:billnex/l10n/app_localizations.dart';

import 'package:billnex/screens/dashboard_screen.dart';
import 'package:billnex/screens/quick_bill_screen.dart';
import 'package:billnex/screens/pos_screen.dart';
import 'package:billnex/screens/sales_screen.dart';
import 'package:billnex/screens/customers_screen.dart';
import 'package:billnex/screens/inventory_screen.dart';
import 'package:billnex/screens/purchasing_screen.dart';
import 'package:billnex/screens/appointments_screen.dart';
import 'package:billnex/screens/business_setup_screen.dart';

/// Wide-viewport coverage: the list screens switch to a master-detail layout at
/// >=720dp and Business Setup pairs its short fields on tablets. These pump the
/// responsive screens at a landscape tablet and a landscape phone (the two
/// widths that were only ever exercised on-device) and assert no layout throws.
Future<void> _pumpAt(WidgetTester tester, Widget screen, Size logical, {Locale? locale}) async {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      theme: AppTheme.light(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 350));
  expect(tester.takeException(), isNull);
}

AppState _seeded() {
  final s = AppState(persistence: InMemoryPersistence());
  s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test Kirana', gstin: '36ABCDE1234F1Z5', phone: '9848000000'));
  s.seedDemo(1720000000000); // stock + sales + customers + suppliers
  return s;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final responsive = <String, Widget Function(AppState)>{
    'Dashboard': (s) => DashboardScreen(state: s, goTo: (_) {}),
    'QuickBill': (s) => QuickBillScreen(state: s),
    'POS': (s) => PosScreen(state: s),
    'Sales': (s) => SalesScreen(state: s),
    'Customers': (s) => CustomersScreen(state: s),
    'Inventory': (s) => InventoryScreen(state: s),
    'Purchasing': (s) => PurchasingScreen(state: s),
    'Appointments': (s) => AppointmentsScreen(state: s),
    'BusinessSetup': (s) => BusinessSetupScreen(state: s, bizType: 'kirana', existing: s.profile),
  };

  // Landscape tablet (master-detail territory) and landscape phone (the widest
  // short viewport). Both English and Telugu — Telugu is the longest-word locale.
  final viewports = <String, Size>{
    'tablet-landscape': const Size(1280, 800),
    'tablet-portrait': const Size(800, 1280),
    'phone-landscape': const Size(780, 360),
  };

  for (final vp in viewports.entries) {
    for (final scr in responsive.entries) {
      for (final loc in const [Locale('en'), Locale('te')]) {
        testWidgets('${scr.key} lays out at ${vp.key} (${loc.languageCode})', (tester) async {
          await _pumpAt(tester, scr.value(_seeded()), vp.value, locale: loc);
        });
      }
    }
  }
}
