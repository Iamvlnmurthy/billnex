import 'package:flutter/material.dart';
import '../models/business_profile.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'backup_screen.dart';
import 'business_setup_screen.dart';
import 'nav.dart';

/// The grouped "Menu" hub (Vyapar-style) — the home for everything that isn't
/// one of the four bottom tabs. Keeps the bottom bar calm and learnable.
class MenuScreen extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const MenuScreen({required this.state, required this.goTo, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;

    // Only show destinations the current role can actually open.
    bool can(NavId id) => state.roleCanAccess(id.name);

    final business = <_Entry>[
      _Entry(NavId.billing, 'Billing counter', Icons.point_of_sale_outlined),
      _Entry(NavId.sales, 'Sales & invoices', Icons.receipt_long_outlined),
      if (state.isOn('creditLedger')) _Entry(NavId.customers, 'Customers & khata', Icons.groups_outlined),
      if (state.isOn('appointments')) _Entry(NavId.appointments, 'Appointments', Icons.event_outlined),
    ].where((e) => can(e.id!)).toList();

    final stockGroup = <_Entry>[
      _Entry(NavId.inventory, 'Items & stock', Icons.inventory_2_outlined),
      _Entry(NavId.purchasing, 'Purchases & suppliers', Icons.local_shipping_outlined),
    ].where((e) => can(e.id!)).toList();

    final insights = <_Entry>[_Entry(NavId.reports, 'Reports & analytics', Icons.bar_chart_outlined)].where((e) => can(e.id!)).toList();

    final setup = <_Entry>[
      if (can(NavId.features)) _Entry(NavId.features, 'Features & toggles', Icons.tune_outlined),
      if (can(NavId.print)) _Entry(NavId.print, 'Print templates', Icons.print_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        const Text('Menu', style: BxText.pageTitle),
        const SizedBox(height: 4),
        Text('${state.shopName} · everything in one place', style: BxText.body.copyWith(color: bx.muted)),
        const SizedBox(height: 20),
        if (business.isNotEmpty) _group(context, 'MY BUSINESS', business),
        if (stockGroup.isNotEmpty) _group(context, 'INVENTORY & PURCHASES', stockGroup),
        if (insights.isNotEmpty) _group(context, 'REPORTS', insights),
        _group(context, 'SETUP', [
          ...setup,
          _Entry.action('Business details', Icons.store_outlined, () => _openBusiness(context)),
          _Entry.action('Backup & restore', Icons.backup_outlined, () => _openBackup(context)),
        ]),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<_Entry> entries) {
    final bx = context.bx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: BxText.meta.copyWith(color: bx.faint)),
        ),
        Card(
          child: Column(children: [for (int i = 0; i < entries.length; i++) _row(context, entries[i], first: i == 0)]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _row(BuildContext context, _Entry e, {required bool first}) {
    final bx = context.bx;
    return InkWell(
      onTap: e.onTap ?? () => goTo(e.id!),
      child: Container(
        decoration: BoxDecoration(
          border: first ? null : Border(top: BorderSide(color: bx.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: Icon(e.icon, size: 20, color: bx.brand),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(e.label, style: BxText.cardTitle)),
            Icon(Icons.chevron_right, size: 20, color: bx.faint),
          ],
        ),
      ),
    );
  }

  void _openBusiness(BuildContext context) {
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

  void _openBackup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Backup & Restore')),
          body: BackupScreen(state: state),
        ),
      ),
    );
  }
}

class _Entry {
  final NavId? id;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  _Entry(this.id, this.label, this.icon) : onTap = null;
  _Entry.action(this.label, this.icon, this.onTap) : id = null;
}
