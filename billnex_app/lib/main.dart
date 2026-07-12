import 'package:flutter/material.dart';
import 'data/catalog.dart';
import 'models/system.dart';
import 'state/app_state.dart';
import 'services/store.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  final store = Store();
  final savedTheme = await store.loadTheme();
  final themeMode = ValueNotifier<ThemeMode>(switch (savedTheme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  });
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

  runApp(BillNexApp(state: state, themeMode: themeMode, store: store, auth: auth, startLocked: locked, initialTab: initialTab));
}

class BillNexApp extends StatefulWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  final Store store;
  final AuthService auth;
  final bool startLocked;
  final int initialTab;
  const BillNexApp({required this.state, required this.themeMode, required this.store, required this.auth, this.startLocked = false, this.initialTab = 0, super.key});
  @override
  State<BillNexApp> createState() => _BillNexAppState();
}

class _BillNexAppState extends State<BillNexApp> {
  late final AppState _state = widget.state;
  late final ValueNotifier<ThemeMode> _themeMode = widget.themeMode;
  late bool _locked = widget.startLocked;

  @override
  void initState() {
    super.initState();
    _themeMode.addListener(_persistTheme);
  }

  void _persistTheme() {
    widget.store.saveTheme(switch (_themeMode.value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  @override
  void dispose() {
    _themeMode.removeListener(_persistTheme);
    _state.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'BillNex',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: _locked
              ? LockScreen(auth: widget.auth, onUnlocked: () => setState(() => _locked = false))
              : AnimatedBuilder(
                  animation: _state,
                  builder: (context, _) {
                    if (!_state.onboarded) {
                      return Scaffold(
                        body: SafeArea(
                          child: Column(children: [
                            _MiniTopBar(themeMode: _themeMode),
                            Expanded(child: OnboardingScreen(state: _state)),
                          ]),
                        ),
                      );
                    }
                    return HomeShell(state: _state, themeMode: _themeMode, auth: widget.auth, initialTab: widget.initialTab);
                  },
                ),
        );
      },
    );
  }
}

class _MiniTopBar extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeMode;
  const _MiniTopBar({required this.themeMode});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 0),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [bx.brand, bx.brand2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: const Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        const SizedBox(width: 9),
        Text.rich(TextSpan(children: [
          const TextSpan(text: 'Bill', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
          TextSpan(text: 'Nex', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: bx.accent, letterSpacing: -0.5)),
        ])),
        const Spacer(),
        IconButton(
          tooltip: 'Toggle theme',
          onPressed: () {
            final dark = Theme.of(context).brightness == Brightness.dark;
            themeMode.value = dark ? ThemeMode.light : ThemeMode.dark;
          },
          icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        ),
      ]),
    );
  }
}
