import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billnex/state/app_state.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/theme/app_theme.dart';
import 'package:billnex/l10n/app_localizations.dart';
import 'package:billnex/screens/quick_bill_screen.dart';

/// Regression: on a small/short phone the restyled Quick Bill header truncated
/// its title and the empty "Current bill" hint overflowed onto the Amount card.
/// Pump it at compact viewports and assert no layout exception in every locale.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState seeded() {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'Test Kirana'));
    return s; // empty tally → exercises the "Current bill" empty-state card
  }

  Future<void> pumpAt(WidgetTester tester, Size logical, {Locale? locale}) async {
    const dpr = 3.0;
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
        home: Scaffold(body: QuickBillScreen(state: seeded())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
  }

  // Realistic small/compact phones (narrow width stresses the header; a short
  // height stresses the keypad/footer column) in EN, HI and TE.
  for (final size in const [Size(360, 720), Size(384, 760), Size(412, 732)]) {
    for (final loc in const [Locale('en'), Locale('hi'), Locale('te')]) {
      testWidgets('Quick Bill has no overflow at ${size.width.toInt()}x${size.height.toInt()} (${loc.languageCode})', (tester) async {
        await pumpAt(tester, size, locale: loc);
      });
    }
  }
}
