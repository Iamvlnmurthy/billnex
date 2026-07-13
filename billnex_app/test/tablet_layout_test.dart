import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/theme/app_theme.dart';
import 'package:billnex/l10n/app_localizations.dart';
import 'package:billnex/widgets/empty_state.dart';

import 'package:billnex/screens/sales_screen.dart';
import 'package:billnex/screens/inventory_screen.dart';
import 'package:billnex/screens/purchasing_screen.dart';
import 'package:billnex/screens/appointments_screen.dart';

/// Seeds a store the same way smoke_test.dart does.
AppState _seeded() {
  final s = AppState(persistence: InMemoryPersistence());
  s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test Kirana', gstin: '36ABCDE1234F1Z5', phone: '9848000000'));
  s.seedDemo(1720000000000); // stock + sales + customers + suppliers
  // Give appointments something to render on the tablet master list.
  s.addAppointment(customer: 'Asha', service: 'Haircut', staff: 'Ravi', slotMs: 1720000000000, nowMs: 1720000000000);
  return s;
}

/// Pumps a screen at a tablet viewport (≈1024×768 logical at dpr 2).
Future<void> _pumpTablet(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(2048, 1536);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      theme: AppTheme.light(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final screens = <String, Widget Function(AppState)>{
    'Inventory': (s) => InventoryScreen(state: s),
    'Purchasing': (s) => PurchasingScreen(state: s),
    'Sales': (s) => SalesScreen(state: s),
    'Appointments': (s) => AppointmentsScreen(state: s),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} shows master-detail with no overflow on tablet', (t) async {
      await _pumpTablet(t, entry.value(_seeded()));
      // No layout/paint exceptions (overflow throws in tests).
      expect(t.takeException(), isNull);
      // Master-detail Row is present with the empty-detail placeholder visible.
      expect(find.byType(EmptyState), findsWidgets);
      expect(find.text(L.of(t.element(find.byType(Scaffold).first)).selectItemTitle), findsOneWidget);
    });

    testWidgets('${entry.key} selecting a row fills the detail pane on tablet', (t) async {
      await _pumpTablet(t, entry.value(_seeded()));
      // Tap the first list row — an InkWell inside the first (list) Card, which
      // avoids matching the search/filter controls above the list.
      final firstRow = find.descendant(of: find.byType(Card).first, matching: find.byType(InkWell)).first;
      await t.tap(firstRow);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      // Placeholder should be gone once a selection is made.
      expect(find.text(L.of(t.element(find.byType(Scaffold).first)).selectItemTitle), findsNothing);
    });
  }
}
