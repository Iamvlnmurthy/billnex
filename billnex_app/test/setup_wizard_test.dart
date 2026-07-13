import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:billnex/l10n/app_localizations.dart';
import 'package:billnex/models/business_profile.dart';
import 'package:billnex/screens/setup_wizard_screen.dart';
import 'package:billnex/services/google_auth_service.dart';
import 'package:billnex/services/in_memory_persistence.dart';
import 'package:billnex/state/app_state.dart';
import 'package:billnex/theme/app_theme.dart';

/// Pumps the wizard at a phone size under a given locale.
Future<void> _pumpWizard(WidgetTester tester, {required Locale locale, required AppState state, GoogleAuthService? auth, VoidCallback? onDone}) async {
  tester.view.physicalSize = const Size(1080, 2160);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      theme: AppTheme.light(),
      home: SetupWizardScreen(state: state, googleAuth: auth ?? const StubGoogleAuthService(), onDone: onDone ?? () {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders without exceptions in English', (tester) async {
    final state = AppState(persistence: InMemoryPersistence());
    await state.init();
    await _pumpWizard(tester, locale: const Locale('en'), state: state);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exceptions in Hindi', (tester) async {
    final state = AppState(persistence: InMemoryPersistence());
    await state.init();
    await _pumpWizard(tester, locale: const Locale('hi'), state: state);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stub Google sign-in does not crash the wizard (treated as unavailable)', (tester) async {
    final state = AppState(persistence: InMemoryPersistence());
    await state.init();
    await _pumpWizard(tester, locale: const Locale('en'), state: state);

    // Tapping "Continue with Google" against the stub must surface a gentle
    // snackbar and advance — never throw.
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining("isn't configured"), findsOneWidget);
  });

  test('the wizard finish path leaves a fresh AppState onboarded (chosen type)', () {
    final s = AppState(persistence: InMemoryPersistence());
    expect(s.onboarded, false);
    // Mirrors the wizard's _ensureOnboarded() when a type was chosen.
    s.setupBusiness(const BusinessProfile(bizType: 'pharmacy', shopName: 'City Medicals'));
    expect(s.onboarded, true);
    expect(s.bizKey, 'pharmacy');
    expect(s.shopName, 'City Medicals');
  });

  test('the wizard finish path onboards even when business is skipped (generic store)', () {
    final s = AppState(persistence: InMemoryPersistence());
    // Mirrors the wizard's _ensureOnboarded() when the business step was skipped.
    s.setupGenericStore();
    expect(s.onboarded, true);
    expect(s.bizKey, 'kirana');
  });

  test('sample catalogue load adds products on top of the applied preset', () {
    final s = AppState(persistence: InMemoryPersistence());
    s.setupBusiness(const BusinessProfile(bizType: 'kirana', shopName: 'My Store'));
    expect(s.stockItems, isEmpty);
    final base = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    // Directly exercise the same addStockItem contract the wizard uses.
    s.addStockItem(name: 'Toor Dal', unit: 'kg', price: 145, nowMs: base + i++);
    s.addStockItem(name: 'Sugar', unit: 'kg', price: 44, nowMs: base + i++);
    expect(s.stockItems.length, 2);
    expect(s.onboarded, true);
  });

  testWidgets('stub signIn throws GoogleAuthUnavailable so callers can treat Google as optional', (tester) async {
    const stub = StubGoogleAuthService();
    await expectLater(stub.signIn(), throwsA(isA<GoogleAuthUnavailable>()));
    await stub.signOut(); // no-op, must not throw
  });
}
