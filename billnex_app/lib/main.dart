import 'dart:async';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'data/catalog.dart';
import 'models/system.dart';
import 'state/app_state.dart';
import 'services/store.dart';
import 'services/auth_service.dart';
import 'services/error_reporter.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/setup_wizard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/lock_screen.dart';

void main() {
  // Run inside a guarded zone so uncaught async errors are reported, not lost.
  const reporter = ConsoleErrorReporter(); // swap for Crashlytics/Sentry adapter
  runZonedGuarded(() => _bootstrap(), (error, stack) => reporter.report(error, stack, context: 'zone'));
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandling(const ConsoleErrorReporter());
  final state = AppState();
  final store = Store();
  final savedTheme = await store.loadTheme();
  final themeMode = ValueNotifier<ThemeMode>(switch (savedTheme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  });
  final savedLang = await store.loadLang();
  final locale = ValueNotifier<Locale?>(savedLang == null ? null : Locale(savedLang));
  await state.init();

  // Deep-link support (also drives previews): ?biz=restaurant&tab=1&theme=dark
  final q = Uri.base.queryParameters;
  final bizParam = q['biz'];
  if (bizParam != null && kBusinessKeys.contains(bizParam)) {
    state.applyPreset(bizParam);
  }
  if (q['theme'] == 'dark') themeMode.value = ThemeMode.dark;
  if (q['theme'] == 'light') themeMode.value = ThemeMode.light;
  if (q['demo'] == '1') state.seedDemo(DateTime.now().millisecondsSinceEpoch);
  if (q['role'] != null) {
    state.setRole(Role.values.firstWhere((r) => r.name == q['role'], orElse: () => Role.owner));
  }
  if (q['offline'] == '1') state.setOnline(false);
  if (q['lang'] != null) locale.value = Locale(q['lang']!); // preview/deep-link
  final initialTab = int.tryParse(q['tab'] ?? '') ?? 0;

  final auth = AuthService();
  // A keystore read must never brick launch — degrade to unlocked on failure.
  var locked = false;
  try {
    locked = await auth.hasPin();
  } catch (_) {
    locked = false;
  }
  if (q['lock'] == '1') locked = true; // preview/demo hook

  runApp(BillNexApp(state: state, themeMode: themeMode, locale: locale, store: store, auth: auth, startLocked: locked, initialTab: initialTab));
}

class BillNexApp extends StatefulWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?> locale;
  final Store store;
  final AuthService auth;
  final bool startLocked;
  final int initialTab;
  const BillNexApp({required this.state, required this.themeMode, required this.locale, required this.store, required this.auth, this.startLocked = false, this.initialTab = 0, super.key});
  @override
  State<BillNexApp> createState() => _BillNexAppState();
}

class _BillNexAppState extends State<BillNexApp> with WidgetsBindingObserver {
  late final AppState _state = widget.state;
  late final ValueNotifier<ThemeMode> _themeMode = widget.themeMode;
  late final ValueNotifier<Locale?> _locale = widget.locale;
  late bool _locked = widget.startLocked;
  bool _splashSeen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeMode.addListener(_persistTheme);
    _locale.addListener(_persistLocale);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    // Backgrounded/closing → drain pending disk writes so a just-posted sale is
    // durable before the OS can kill the process. Best-effort; never throws.
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden || s == AppLifecycleState.detached) {
      _state.flush();
    }
  }

  void _persistTheme() {
    widget.store.saveTheme(switch (_themeMode.value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  void _persistLocale() => widget.store.saveLang(_locale.value?.languageCode);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeMode.removeListener(_persistTheme);
    _locale.removeListener(_persistLocale);
    _state.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: _locale,
          builder: (context, locale, _) => MaterialApp(
            title: 'BillNex',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            locale: locale,
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            home: _locked
                ? LockScreen(auth: widget.auth, onUnlocked: () => setState(() => _locked = false))
                : AnimatedBuilder(
                    animation: _state,
                    builder: (context, _) {
                      if (!_state.onboarded && !_splashSeen) {
                        return SplashScreen(onGetStarted: () => setState(() => _splashSeen = true));
                      }
                      if (!_state.onboarded) {
                        return SetupWizardScreen(
                          state: _state,
                          onDone: () {
                            if (mounted) setState(() {});
                          },
                        );
                      }
                      return HomeShell(state: _state, themeMode: _themeMode, locale: _locale, auth: widget.auth, initialTab: widget.initialTab);
                    },
                  ),
          ),
        );
      },
    );
  }
}
