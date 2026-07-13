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
import 'package:billnex/screens/reports_screen.dart';
import 'package:billnex/screens/features_screen.dart';
import 'package:billnex/screens/templates_screen.dart';
import 'package:billnex/screens/appointments_screen.dart';
import 'package:billnex/screens/menu_screen.dart';
import 'package:billnex/screens/onboarding_screen.dart';
import 'package:billnex/screens/business_setup_screen.dart';
import 'package:billnex/screens/backup_screen.dart';

/// Wraps a screen with the real theme + localizations so context.bx / L.of work,
/// then pumps it in every supported locale and both light/dark, asserting that
/// nothing threw during build/layout/paint (the widget-test equivalent of
/// "the page works and there are no console errors").
Future<void> _pump(WidgetTester tester, Widget screen, {Locale? locale, Brightness brightness = Brightness.light}) async {
  // Real phone viewport (Pixel-ish 390x844 logical) so scroll content doesn't
  // report false overflows and only genuine layout bugs surface.
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1170, 2532);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 350)); // settle animations/timers
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

  void noop(_) {}

  final screens = <String, Widget Function(AppState)>{
    'Dashboard': (s) => DashboardScreen(state: s, goTo: noop),
    'QuickBill': (s) => QuickBillScreen(state: s),
    'POS': (s) => PosScreen(state: s),
    'Sales': (s) => SalesScreen(state: s),
    'Customers': (s) => CustomersScreen(state: s),
    'Inventory': (s) => InventoryScreen(state: s),
    'Purchasing': (s) => PurchasingScreen(state: s),
    'Reports': (s) => ReportsScreen(state: s),
    'Features': (s) => FeaturesScreen(state: s),
    'Templates': (s) => TemplatesScreen(state: s),
    'Appointments': (s) => AppointmentsScreen(state: s),
    'Menu': (s) => MenuScreen(state: s, goTo: noop),
    'BusinessSetup': (s) => BusinessSetupScreen(state: s, bizType: 'kirana', existing: s.profile),
    'Backup': (s) => BackupScreen(state: s),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders with seeded data (en)', (t) async {
      await _pump(t, entry.value(_seeded()));
    });
    testWidgets('${entry.key} renders in Hindi', (t) async {
      await _pump(t, entry.value(_seeded()), locale: const Locale('hi'));
    });
    testWidgets('${entry.key} renders in dark mode', (t) async {
      await _pump(t, entry.value(_seeded()), brightness: Brightness.dark);
    });
  }

  testWidgets('Onboarding renders (fresh, all locales)', (t) async {
    for (final loc in [const Locale('en'), const Locale('hi'), const Locale('te')]) {
      await _pump(
        t,
        OnboardingScreen(state: AppState(persistence: InMemoryPersistence())),
        locale: loc,
      );
    }
  });

  testWidgets('every screen renders on an EMPTY (fresh) store', (t) async {
    for (final build in screens.values) {
      final s = AppState(persistence: InMemoryPersistence());
      s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Empty Shop'));
      await _pump(t, build(s));
    }
  });
}
