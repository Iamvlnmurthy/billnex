import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'nav.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const DashboardScreen({required this.state, required this.goTo, super.key});

  @override
  Widget build(BuildContext context) {
    final biz = state.business!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PageHeader('Good evening 👋', "Here's your ${biz.name.toLowerCase()} at a glance."),
            // stat row — reflects real posted sales this session
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth > 720 ? 4 : 2;
              final live = state.billCount > 0;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 116,
                children: [
                  _Stat('Sales', money(state.todaySales), live ? 'this session' : 'post a bill', true, Icons.trending_up),
                  _Stat('Bills', '${state.billCount}', live ? 'posted' : 'none yet', true, Icons.receipt_long_outlined),
                  _Stat('Credit due', money(state.totalReceivable),
                      state.overdueCount > 0 ? '${state.overdueCount} accounts' : 'no dues', state.totalReceivable == 0,
                      Icons.account_balance_wallet_outlined,
                      onTap: state.isOn('creditLedger') ? () => goTo(NavId.customers) : null),
                  _Stat('Low stock', '${state.lowStockCount} items',
                      state.lowStockCount > 0 ? 'reorder now' : 'all healthy', state.lowStockCount == 0,
                      Icons.inventory_2_outlined, onTap: () => goTo(NavId.inventory)),
                ],
              );
            }),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 820;
              final coverage = _CoverageCard(state: state, goTo: goTo);
              final preset = _PresetCard(state: state, goTo: goTo);
              if (wide) {
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: coverage),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: preset),
                ]);
              }
              return Column(children: [coverage, const SizedBox(height: 16), preset]);
            }),
          ]),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String k, v, d;
  final bool up;
  final IconData icon;
  final VoidCallback? onTap;
  const _Stat(this.k, this.v, this.d, this.up, this.icon, {this.onTap});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Bx.radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Icon(icon, size: 16, color: bx.muted),
              const SizedBox(width: 7),
              Flexible(child: Text(k, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: bx.muted), overflow: TextOverflow.ellipsis)),
              if (onTap != null) Icon(Icons.chevron_right, size: 16, color: bx.faint),
            ]),
            const SizedBox(height: 8),
            Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: up ? bx.pos : bx.danger)),
          ]),
        ),
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _CoverageCard({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Card(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Expanded(child: Text('Feature coverage by category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => goTo(NavId.features), child: const Text('Manage')),
          ]),
        ),
        for (final cat in kCategories)
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.border))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(cat.icon, size: 20, color: bx.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${state.enabledInCategory(cat.key)} of ${state.totalInCategory(cat.key)} enabled for this business',
                      style: TextStyle(fontSize: 12, color: bx.muted)),
                ]),
              ),
              Badge2('${state.enabledInCategory(cat.key)}/${state.totalInCategory(cat.key)}'),
            ]),
          ),
      ]),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _PresetCard({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final biz = state.business!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Preset applied', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${biz.edition} · auto-tuned for ${biz.tag.toLowerCase()}', style: TextStyle(fontSize: 13, color: bx.muted)),
          const SizedBox(height: 14),
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final c in biz.on.take(8))
              Pill(capabilityByKey(c).name.split(' ').take(2).join(' '), color: bx.pos, icon: Icons.check),
          ]),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => goTo(NavId.billing),
            icon: const Icon(Icons.point_of_sale_outlined, size: 18),
            label: const Text('Start billing'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
          ),
        ]),
      ),
    );
  }
}
