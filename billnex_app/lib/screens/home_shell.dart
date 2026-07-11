import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/system.dart';
import '../theme/app_theme.dart';
import 'nav.dart';
import 'dashboard_screen.dart';
import 'features_screen.dart';
import 'pos_screen.dart';
import 'sales_screen.dart';
import 'customers_screen.dart';
import 'inventory_screen.dart';
import 'purchasing_screen.dart';
import 'reports_screen.dart';
import 'appointments_screen.dart';
import 'templates_screen.dart';

class HomeShell extends StatefulWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  final int initialTab;
  const HomeShell({required this.state, required this.themeMode, this.initialTab = 0, super.key});

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
  }

  /// Tabs available for the current preset + role. Customers is gated by
  /// creditLedger; role gating per PRD §9.
  List<NavId> _navOrder() {
    final s = widget.state;
    final all = [
      NavId.dash,
      NavId.billing,
      if (s.isOn('appointments')) NavId.appointments,
      NavId.sales,
      if (s.isOn('creditLedger')) NavId.customers,
      NavId.inventory,
      NavId.purchasing,
      NavId.reports,
      NavId.features,
      NavId.print,
    ];
    return all.where((id) => s.roleCanAccess(id.name)).toList();
  }

  void _go(NavId id) => setState(() => _current = id);

  Widget _bodyFor(NavId id) {
    final s = widget.state;
    return switch (id) {
      NavId.dash => DashboardScreen(state: s, goTo: _go),
      NavId.billing => PosScreen(state: s),
      NavId.appointments => AppointmentsScreen(state: s),
      NavId.sales => SalesScreen(state: s),
      NavId.customers => CustomersScreen(state: s),
      NavId.inventory => InventoryScreen(state: s),
      NavId.purchasing => PurchasingScreen(state: s),
      NavId.reports => ReportsScreen(state: s),
      NavId.features => FeaturesScreen(state: s),
      NavId.print => TemplatesScreen(state: s),
    };
  }

  @override
  Widget build(BuildContext context) {
    final order = _navOrder();
    if (!order.contains(_current)) _current = NavId.dash;

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 720;
      // Mobile bottom nav caps at 5; overflow goes to a "More" sheet.
      final showMore = !wide && order.length > 5;
      final primary = showMore ? order.take(4).toList() : order;
      final overflow = showMore ? order.skip(4).toList() : <NavId>[];

      return Scaffold(
        body: Column(children: [
          _TopBar(state: widget.state, themeMode: widget.themeMode),
          _TrustBar(state: widget.state),
          Expanded(
            child: Row(children: [
              if (wide) _Rail(order: order, current: _current, onTap: _go),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: _bodyFor(_current),
                ),
              ),
            ]),
          ),
        ]),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _mobileSelectedIndex(primary, overflow),
                onDestinationSelected: (i) {
                  if (showMore && i == primary.length) {
                    _openMore(context, overflow);
                  } else {
                    _go(primary[i]);
                  }
                },
                height: 66,
                destinations: [
                  for (final id in primary)
                    NavigationDestination(icon: Icon(kNavSpecs[id]!.icon), selectedIcon: Icon(kNavSpecs[id]!.activeIcon), label: kNavSpecs[id]!.label),
                  if (showMore) const NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
                ],
              ),
      );
    });
  }

  int _mobileSelectedIndex(List<NavId> primary, List<NavId> overflow) {
    final i = primary.indexOf(_current);
    if (i >= 0) return i;
    // current is in overflow -> highlight the "More" slot
    return primary.length;
  }

  void _openMore(BuildContext context, List<NavId> overflow) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final id in overflow)
            ListTile(
              leading: Icon(kNavSpecs[id]!.icon),
              title: Text(kNavSpecs[id]!.label),
              selected: _current == id,
              onTap: () {
                Navigator.pop(ctx);
                _go(id);
              },
            ),
        ]),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;
  const _TopBar({required this.state, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: bx.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          _logo(context, bx),
          const SizedBox(width: 14),
          Flexible(
            child: InkWell(
              onTap: state.switchBusiness,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bx.surface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: bx.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: bx.brand, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('${state.business!.name} · ${state.business!.edition}',
                        overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 16, color: bx.muted),
                ]),
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton<Role>(
            tooltip: 'Switch role',
            onSelected: state.setRole,
            itemBuilder: (ctx) => [for (final r in Role.values) PopupMenuItem(value: r, child: Row(children: [if (state.role == r) Icon(Icons.check, size: 16, color: bx.accent) else const SizedBox(width: 16), const SizedBox(width: 8), Text(r.label)]))],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: bx.surface2, borderRadius: BorderRadius.circular(999), border: Border.all(color: bx.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.badge_outlined, size: 15, color: bx.muted),
                const SizedBox(width: 6),
                Text(state.role.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                Icon(Icons.expand_more, size: 15, color: bx.muted),
              ]),
            ),
          ),
          IconButton(tooltip: 'Audit log', onPressed: () => _showAudit(context, state), icon: const Icon(Icons.verified_user_outlined)),
          ValueListenableBuilder(
            valueListenable: themeMode,
            builder: (context, mode, _) {
              final dark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                tooltip: 'Toggle theme',
                onPressed: () => themeMode.value = dark ? ThemeMode.light : ThemeMode.dark,
                icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              );
            },
          ),
        ]),
      ),
    );
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
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text('Audit log', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
              if (log.isEmpty)
                Padding(padding: const EdgeInsets.all(28), child: Center(child: Text('No audited actions yet', style: TextStyle(color: bx.muted))))
              else
                Flexible(child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: log.length,
                  separatorBuilder: (_, i) => Divider(height: 1, color: bx.border),
                  itemBuilder: (ctx, i) => ListTile(
                    dense: true,
                    leading: Icon(Icons.history, size: 18, color: bx.muted),
                    title: Text(log[i].action, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: Text('${log[i].actor} · ${log[i].ref} · ${log[i].timeLabel}', style: const TextStyle(fontSize: 11.5)),
                  ),
                )),
            ]),
          ),
        );
      },
    );
  }

  Widget _logo(BuildContext context, BxColors bx) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [bx.brand2, bx.brand], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 9),
        Text.rich(TextSpan(children: [
          const TextSpan(text: 'Bill', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
          TextSpan(text: 'Nex', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: bx.accent, letterSpacing: -0.5)),
        ])),
      ]);
}

class _TrustBar extends StatelessWidget {
  final AppState state;
  const _TrustBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    Widget seg(String label, String value) => Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$label ', style: TextStyle(fontSize: 12.5, color: bx.muted)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ]);
    return Container(
      decoration: BoxDecoration(
        color: bx.surface2,
        border: Border(bottom: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          // online/offline toggle
          InkWell(
            onTap: () => state.setOnline(!state.online),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: (state.online ? bx.trustOnline : bx.warn).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: state.online ? bx.trustOnline : bx.warn, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text(state.online ? 'Online' : 'Offline', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: state.online ? bx.trustOnline : bx.warn)),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          seg('Queue', '${state.queueCount}'),
          if (state.queueCount > 0) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: state.syncNow, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero), child: const Text('Sync now', style: TextStyle(fontSize: 12.5))),
          ],
          const SizedBox(width: 16),
          seg('Backup', '2 min ago'),
          const SizedBox(width: 16),
          seg('Active features', '${state.activeCount}'),
        ]),
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
        child: Column(children: [
          for (final id in order)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _RailBtn(spec: kNavSpecs[id]!, on: current == id, onTap: () => onTap(id)),
            ),
        ]),
      ),
    );
  }
}

class _RailBtn extends StatelessWidget {
  final NavSpec spec;
  final bool on;
  final VoidCallback onTap;
  const _RailBtn({required this.spec, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: on ? bx.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(on ? spec.activeIcon : spec.icon, size: 22, color: on ? bx.accent : bx.muted),
          const SizedBox(height: 5),
          Text(spec.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: on ? bx.accent : bx.muted)),
        ]),
      ),
    );
  }
}
