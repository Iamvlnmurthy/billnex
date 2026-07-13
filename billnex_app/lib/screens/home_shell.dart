import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/system.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'nav.dart';
import 'dashboard_screen.dart';
import 'quick_bill_screen.dart';
import 'menu_screen.dart';
import 'features_screen.dart';
import 'pos_screen.dart';
import 'sales_screen.dart';
import 'customers_screen.dart';
import 'inventory_screen.dart';
import 'purchasing_screen.dart';
import 'reports_screen.dart';
import 'appointments_screen.dart';
import 'backup_screen.dart';
import 'business_setup_screen.dart';
import '../models/business_profile.dart';
import 'templates_screen.dart';

class HomeShell extends StatefulWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?>? locale;
  final AuthService? auth;
  final int initialTab;
  const HomeShell({required this.state, required this.themeMode, this.locale, this.auth, this.initialTab = 0, super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  NavId _current = NavId.dash;

  @override
  void initState() {
    super.initState();
    final order = _navOrder();
    if (widget.initialTab >= 0 && widget.initialTab < order.length) {
      _current = order[widget.initialTab];
    }
    // Counter-heavy shops (Fast POS) open straight to Quick Bill.
    if (widget.initialTab == 0 && widget.state.isOn('fastPOS') && order.contains(NavId.quickbill)) {
      _current = NavId.quickbill;
    }
  }

  /// Tabs available for the current preset + role. Customers is gated by
  /// creditLedger; role gating per PRD §9.
  List<NavId> _navOrder() {
    final s = widget.state;
    final all = [
      NavId.dash,
      NavId.quickbill,
      NavId.billing,
      if (s.isOn('appointments')) NavId.appointments,
      NavId.sales,
      if (s.isOn('creditLedger')) NavId.customers,
      NavId.inventory,
      NavId.purchasing,
      NavId.reports,
      NavId.features,
      NavId.print,
      NavId.menu,
    ];
    return all.where((id) => s.roleCanAccess(id.name)).toList();
  }

  void _go(NavId id) => setState(() => _current = id);

  Widget _bodyFor(NavId id) {
    final s = widget.state;
    return switch (id) {
      NavId.dash => DashboardScreen(state: s, goTo: _go),
      NavId.quickbill => QuickBillScreen(state: s),
      NavId.billing => PosScreen(state: s),
      NavId.appointments => AppointmentsScreen(state: s),
      NavId.sales => SalesScreen(state: s),
      NavId.customers => CustomersScreen(state: s),
      NavId.inventory => InventoryScreen(state: s),
      NavId.purchasing => PurchasingScreen(state: s),
      NavId.reports => ReportsScreen(state: s),
      NavId.features => FeaturesScreen(state: s),
      NavId.print => TemplatesScreen(state: s),
      NavId.menu => MenuScreen(state: s, goTo: _go),
    };
  }

  /// The fixed bottom bar (Vyapar-style): up to three primary destinations the
  /// role can reach, then a Menu hub that holds everything else.
  List<NavId> _bottomTabs(List<NavId> order) {
    final pref = [NavId.quickbill, NavId.dash, NavId.inventory, NavId.sales].where(order.contains).take(3).toList();
    return [...pref, NavId.menu];
  }

  @override
  Widget build(BuildContext context) {
    final order = _navOrder();
    if (!order.contains(_current)) _current = NavId.dash;

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 720;
        final tabs = _bottomTabs(order);

        final dark = Theme.of(context).brightness == Brightness.dark;
        final bx = context.bx;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              gradient: dark
                  ? const LinearGradient(colors: [Color(0xFF071426), Color(0xFF0B1D32)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                  : const LinearGradient(colors: [Color(0xFFF8FBFF), Color(0xFFF1F6FD)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: Column(
              children: [
                _TopBar(state: widget.state, themeMode: widget.themeMode, auth: widget.auth, locale: widget.locale),
                _TrustBar(state: widget.state),
                Expanded(
                  child: Row(
                    children: [
                      if (wide) _Rail(order: order, current: _current, onTap: _go),
                      Expanded(child: _bodyFor(_current)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(top: BorderSide(color: bx.border)),
                    boxShadow: const [BoxShadow(color: Color(0x26020A14), blurRadius: 20, offset: Offset(0, -6))],
                  ),
                  child: NavigationBar(
                    selectedIndex: _mobileSelectedIndex(tabs),
                    onDestinationSelected: (i) => _go(tabs[i]),
                    height: 72,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      for (final id in tabs) NavigationDestination(icon: Icon(kNavSpecs[id]!.icon, size: 22), selectedIcon: Icon(kNavSpecs[id]!.activeIcon, size: 23), label: navLabel(context, id)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  int _mobileSelectedIndex(List<NavId> tabs) {
    final i = tabs.indexOf(_current);
    if (i >= 0) return i;
    // Viewing a screen reached via the hub → highlight the Menu tab.
    return tabs.indexOf(NavId.menu);
  }
}

/// Language switcher — sets the app locale and persists it.
Future<void> showLanguagePicker(BuildContext context, ValueNotifier<Locale?> locale) {
  const langs = [('English', null), ('हिंदी', 'hi'), ('తెలుగు', 'te')];
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(L.of(ctx).language, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
          for (final (name, code) in langs)
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(name),
              trailing: (locale.value?.languageCode == code) ? const Icon(Icons.check) : null,
              onTap: () {
                locale.value = code == null ? null : Locale(code);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  final AuthService? auth;
  final ValueNotifier<Locale?>? locale;
  const _TopBar({required this.state, required this.themeMode, this.auth, this.locale});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final narrow = MediaQuery.of(context).size.width < 460;
    if (narrow) return _mobileHeader(context, bx);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        border: Border(bottom: BorderSide(color: bx.border)),
        boxShadow: const [BoxShadow(color: Color(0x16020A14), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _logo(context, bx, compact: narrow),
            SizedBox(width: narrow ? 8 : 14),
            Expanded(
              child: InkWell(
                onTap: () => _openBusinessDetails(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bx.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: bx.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: bx.brand, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${state.shopName} · ${state.business!.edition}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more, size: 16, color: bx.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<Role>(
              tooltip: L.of(context).switchRole,
              onSelected: state.setRole,
              itemBuilder: (ctx) => [
                for (final r in Role.values)
                  PopupMenuItem(
                    value: r,
                    child: Row(
                      children: [
                        if (state.role == r) Icon(Icons.check, size: 16, color: bx.accent) else const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Text(r.label),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: narrow ? 8 : 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bx.surface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: bx.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 15, color: bx.muted),
                    if (!narrow) ...[const SizedBox(width: 6), Text(state.role.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))],
                    Icon(Icons.expand_more, size: 15, color: bx.muted),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: L.of(context).securityAudit,
              icon: const Icon(Icons.verified_user_outlined),
              onSelected: (v) {
                if (v == 'audit') _showAudit(context, state);
                if (v == 'pin' && auth != null) _managePin(context, auth!);
                if (v == 'backup') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Backup & Restore')),
                        body: BackupScreen(state: state),
                      ),
                    ),
                  );
                }
                if (v == 'profile' && state.bizKey != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BusinessSetupScreen(
                        state: state,
                        bizType: state.bizKey!,
                        existing: state.profile ?? BusinessProfile(bizType: state.bizKey!, shopName: state.shopName),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(dense: true, leading: Icon(Icons.store_outlined), title: Text('Business details')),
                ),
                const PopupMenuItem(
                  value: 'backup',
                  child: ListTile(dense: true, leading: Icon(Icons.backup_outlined), title: Text('Backup & Restore')),
                ),
                const PopupMenuItem(
                  value: 'audit',
                  child: ListTile(dense: true, leading: Icon(Icons.history), title: Text('Audit log')),
                ),
                if (auth != null)
                  PopupMenuItem(
                    value: 'pin',
                    child: ListTile(dense: true, leading: const Icon(Icons.pin_outlined), title: Text(L.of(ctx).enterPin)),
                  ),
              ],
            ),
            if (locale != null) IconButton(tooltip: L.of(context).language, onPressed: () => showLanguagePicker(context, locale!), icon: const Icon(Icons.translate)),
            ValueListenableBuilder(
              valueListenable: themeMode,
              builder: (context, mode, _) {
                final dark = Theme.of(context).brightness == Brightness.dark;
                return IconButton(
                  tooltip: L.of(context).toggleTheme,
                  onPressed: () => themeMode.value = dark ? ThemeMode.light : ThemeMode.dark,
                  icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileHeader(BuildContext context, BxColors bx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
        border: Border(bottom: BorderSide(color: bx.border)),
        boxShadow: const [BoxShadow(color: Color(0x1F020A14), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            PopupMenuButton<String>(
              tooltip: L.of(context).more,
              icon: const Icon(Icons.menu_rounded),
              onSelected: (value) => _handleMobileAction(context, value),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(dense: true, leading: const Icon(Icons.store_outlined), title: Text(state.shopName)),
                ),
                PopupMenuItem(
                  value: 'role',
                  child: ListTile(dense: true, leading: const Icon(Icons.badge_outlined), title: Text(L.of(ctx).switchRole)),
                ),
                PopupMenuItem(
                  value: 'backup',
                  child: ListTile(dense: true, leading: const Icon(Icons.backup_outlined), title: Text(L.of(ctx).backupRestoreTitle)),
                ),
                PopupMenuItem(
                  value: 'audit',
                  child: ListTile(dense: true, leading: const Icon(Icons.verified_user_outlined), title: Text(L.of(ctx).securityAudit)),
                ),
                if (auth != null)
                  const PopupMenuItem(
                    value: 'pin',
                    child: ListTile(dense: true, leading: Icon(Icons.pin_outlined), title: Text('App-lock PIN')),
                  ),
                if (locale != null)
                  PopupMenuItem(
                    value: 'language',
                    child: ListTile(dense: true, leading: const Icon(Icons.translate), title: Text(L.of(ctx).language)),
                  ),
                PopupMenuItem(
                  value: 'theme',
                  child: ListTile(dense: true, leading: const Icon(Icons.contrast_outlined), title: Text(L.of(ctx).toggleTheme)),
                ),
              ],
            ),
            _logo(context, bx),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: (state.online ? bx.trustOnline : bx.warn).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(state.online ? Icons.check_circle : Icons.cloud_off_outlined, size: 15, color: state.online ? bx.trustOnline : bx.warn),
                  const SizedBox(width: 5),
                  Text(
                    state.online ? L.of(context).online : L.of(context).offline,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: state.online ? bx.trustOnline : bx.warn),
                  ),
                ],
              ),
            ),
            IconButton(tooltip: L.of(context).securityAudit, onPressed: () => _showAudit(context, state), icon: const Icon(Icons.notifications_none_rounded)),
          ],
        ),
      ),
    );
  }

  void _handleMobileAction(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        _openBusinessDetails(context);
      case 'role':
        _showRolePicker(context);
      case 'backup':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(L.of(context).backupRestoreTitle)),
              body: BackupScreen(state: state),
            ),
          ),
        );
      case 'audit':
        _showAudit(context, state);
      case 'pin':
        if (auth != null) _managePin(context, auth!);
      case 'language':
        if (locale != null) showLanguagePicker(context, locale!);
      case 'theme':
        themeMode.value = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    }
  }

  void _showRolePicker(BuildContext context) {
    final bx = context.bx;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final role in Role.values)
              ListTile(
                leading: Icon(state.role == role ? Icons.check_circle : Icons.circle_outlined, color: state.role == role ? bx.accent : bx.muted),
                title: Text(role.label),
                onTap: () {
                  state.setRole(role);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Tapping the shop chip opens Business details for editing — it must NOT
  /// switch/clear the business (that used to bounce back to onboarding and
  /// look like a data reset).
  void _openBusinessDetails(BuildContext context) {
    if (state.bizKey == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BusinessSetupScreen(
          state: state,
          bizType: state.bizKey!,
          existing: state.profile ?? BusinessProfile(bizType: state.bizKey!, shopName: state.shopName),
        ),
      ),
    );
  }

  Future<void> _managePin(BuildContext context, AuthService auth) async {
    final hasPin = await auth.hasPin();
    if (!context.mounted) return;
    final controller = TextEditingController();
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(hasPin ? 'Change app-lock PIN' : 'Set app-lock PIN', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('A 4-digit PIN locks BillNex on launch. Stored hashed in the device keystore.', style: TextStyle(fontSize: 12.5)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(labelText: '4-digit PIN', border: OutlineInputBorder(), counterText: ''),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  if (controller.text.length == 4) {
                    await auth.setPin(controller.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(hasPin ? 'Update PIN' : 'Enable app-lock'),
              ),
              if (hasPin)
                TextButton(
                  onPressed: () async {
                    await auth.clearPin();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Remove PIN'),
                ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _showAudit(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final bx = ctx.bx;
        final log = state.auditLog;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Audit log', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                if (log.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Text('No audited actions yet', style: TextStyle(color: bx.muted)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: log.length,
                      separatorBuilder: (_, i) => Divider(height: 1, color: bx.border),
                      itemBuilder: (ctx, i) => ListTile(
                        dense: true,
                        leading: Icon(Icons.history, size: 18, color: bx.muted),
                        title: Text(log[i].action, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        subtitle: Text('${log[i].actor} · ${log[i].ref} · ${log[i].timeLabel}', style: const TextStyle(fontSize: 11.5)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _logo(BuildContext context, BxColors bx, {bool compact = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bx.brand2, bx.brand], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 17),
      ),
      if (!compact) ...[
        const SizedBox(width: 9),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Bill',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
              ),
              TextSpan(
                text: 'Nex',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: bx.accent, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _TrustBar extends StatelessWidget {
  final AppState state;
  const _TrustBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    Widget seg(String label, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: TextStyle(fontSize: 12.5, color: bx.muted)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: bx.surface2,
        border: Border(bottom: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // online/offline toggle
            InkWell(
              onTap: () => state.setOnline(!state.online),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: (state.online ? bx.trustOnline : bx.warn).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: state.online ? bx.trustOnline : bx.warn, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      state.online ? L.of(context).online : L.of(context).offline,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: state.online ? bx.trustOnline : bx.warn),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            seg(L.of(context).queue, '${state.queueCount}'),
            if (state.queueCount > 0) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: state.syncNow,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 40)),
                child: Text(L.of(context).syncNow, style: const TextStyle(fontSize: 12.5)),
              ),
            ],
            const SizedBox(width: 16),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Backup & Restore')),
                    body: BackupScreen(state: state),
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.backupDue) ...[Icon(Icons.warning_amber_rounded, size: 13, color: bx.warn), const SizedBox(width: 4)],
                    Text('${L.of(context).backup} ', style: TextStyle(fontSize: 12.5, color: bx.muted)),
                    Text(
                      state.backupDue ? L.of(context).backupDue : (state.lastBackupMs == null ? L.of(context).backupNone : L.of(context).backupSaved),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: state.backupDue ? bx.warn : null),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            seg(L.of(context).activeFeatures, '${state.activeCount}'),
          ],
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final List<NavId> order;
  final NavId current;
  final void Function(NavId) onTap;
  const _Rail({required this.order, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final id in order)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _RailBtn(spec: kNavSpecs[id]!, label: navLabel(context, id), on: current == id, onTap: () => onTap(id)),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailBtn extends StatelessWidget {
  final NavSpec spec;
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _RailBtn({required this.spec, required this.label, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: on ? bx.accent.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(on ? spec.activeIcon : spec.icon, size: 22, color: on ? bx.accent : bx.muted),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: on ? bx.accent : bx.muted),
            ),
          ],
        ),
      ),
    );
  }
}
