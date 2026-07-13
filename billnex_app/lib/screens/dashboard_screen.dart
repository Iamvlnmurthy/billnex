import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import 'backup_screen.dart';
import 'nav.dart';

/// Owner dashboard — laid out to the Stitch `owner_dashboard` reference:
/// greeting → alert banners → Create New Bill CTA → Today's Summary
/// (hero sales card + 4 stat cards) → quick actions → Recent Activity.
class DashboardScreen extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const DashboardScreen({required this.state, required this.goTo, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final biz = state.business!;
    final owner = (state.profile?.owner ?? '').trim();
    final greetName = owner.isNotEmpty ? owner.split(' ').first : biz.name;
    final canBill = state.roleCanAccess('billing');
    final canInventory = state.roleCanAccess('inventory');
    final canReports = state.roleCanAccess('reports');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Greeting ─────────────────────────────────────────────
                Text(
                  '${_greeting()}, $greetName!',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: bx.muted),
                ),
                const SizedBox(height: 1),
                Text('${state.shopName} Dashboard', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.15)),
                const SizedBox(height: 12),

                // ── Alert banners (only when actionable for this role) ───
                if (state.lowStockCount > 0 && canInventory)
                  _AlertBanner(
                    icon: Icons.warning_amber_rounded,
                    color: bx.warn,
                    bg: bx.warnBg,
                    text: '${state.lowStockCount} ${state.lowStockCount == 1 ? 'product' : 'products'} low in stock',
                    onTap: () => goTo(NavId.inventory),
                  ),
                if (state.backupDue) ...[
                  if (state.lowStockCount > 0 && canInventory) const SizedBox(height: 10),
                  _AlertBanner(
                    icon: Icons.cloud_off_rounded,
                    color: bx.danger,
                    bg: bx.dangerBg,
                    text: 'Backup due — protect your data',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Backup & Restore')),
                          body: BackupScreen(state: state),
                        ),
                      ),
                    ),
                  ),
                ],
                if ((state.lowStockCount > 0 && canInventory) || state.backupDue) const SizedBox(height: 12),

                // ── Primary CTA (only for roles that can bill) ───────────
                if (canBill) ...[
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () => goTo(NavId.billing),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Create New Bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Today's Summary ──────────────────────────────────────
                _SectionHead(title: "Today's Summary", action: canReports ? 'Details' : null, onAction: () => goTo(NavId.reports)),
                const SizedBox(height: 8),
                _HeroSales(state: state),
                const SizedBox(height: 8),
                _SummaryGrid(state: state, goTo: goTo),
                const SizedBox(height: 14),

                // ── Quick actions ────────────────────────────────────────
                _QuickActions(state: state, goTo: goTo),
                const SizedBox(height: 14),

                // ── Recent Activity ──────────────────────────────────────
                _SectionHead(title: 'Recent Activity', action: (state.billCount > 0 && state.roleCanAccess('sales')) ? 'View all' : null, onAction: () => goTo(NavId.sales)),
                const SizedBox(height: 8),
                _RecentActivity(state: state, goTo: goTo),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ───────────────────────────────────────────────────────────────────────
class _SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHead({required this.title, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                action!,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: bx.accent),
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String text;
  final VoidCallback onTap;
  const _AlertBanner({required this.icon, required this.color, required this.bg, required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: color),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

/// Hero card — today's total sales, mirrors the mockup's prominent panel.
class _HeroSales extends StatelessWidget {
  final AppState state;
  const _HeroSales({required this.state});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final live = state.billCount > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S SALES",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(child: Money(state.todaySales, style: BxText.valueHero.copyWith(fontSize: 26))),
                      const SizedBox(width: 10),
                      Text(
                        live ? '${state.billCount} bills' : 'no bills yet',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: live ? bx.pos : bx.faint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: bx.accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.payments_outlined, color: bx.accent, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four stat cards: Total Bills, Cash, UPI, Credit Sales.
class _SummaryGrid extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _SummaryGrid({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final mix = state.paymentMix();
    final cash = mix['Cash'] ?? 0;
    final upi = (mix['UPI'] ?? 0) + (mix['Card'] ?? 0);
    final credit = mix['Credit'] ?? 0;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 720 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 86,
          children: [
            _MiniStat('Total Bills', '${state.billCount}', color: bx.muted),
            _MiniStat('Cash Received', money(cash), color: bx.muted),
            _MiniStat('UPI / Card', money(upi), color: bx.muted),
            _MiniStat('Credit Sales', money(credit), color: credit > 0 ? bx.danger : bx.muted, onTap: state.isOn('creditLedger') ? () => goTo(NavId.customers) : null),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final VoidCallback? onTap;
  const _MiniStat(this.label, this.value, {required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Bx.radius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: bx.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null) Icon(Icons.chevron_right, size: 15, color: bx.faint),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: color == bx.danger ? bx.danger : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick-action tiles — Add Product, View Stock, Ledger, Day Closing.
class _QuickActions extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _QuickActions({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final ledgerOn = state.isOn('creditLedger');
    final canInventory = state.roleCanAccess('inventory');
    final canReports = state.roleCanAccess('reports');
    final canCustomers = state.roleCanAccess('customers');
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      if (canInventory) (icon: Icons.add_box_outlined, label: 'Add Product', onTap: () => goTo(NavId.inventory)),
      if (canInventory) (icon: Icons.inventory_2_outlined, label: 'View Stock', onTap: () => goTo(NavId.inventory)),
      if (ledgerOn && canCustomers) (icon: Icons.groups_outlined, label: 'Ledger', onTap: () => goTo(NavId.customers)),
      if (canReports) (icon: Icons.assessment_outlined, label: 'Day Closing', onTap: () => goTo(NavId.reports)),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(width: 12), Expanded(child: _QuickTile(actions[i].icon, actions[i].label, actions[i].onTap))],
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickTile(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Bx.radius),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(color: bx.accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(Bx.radius)),
            alignment: Alignment.center,
            child: Icon(icon, color: bx.accent, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Recent Activity — last few posted bills with PAID / PENDING chips.
class _RecentActivity extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _RecentActivity({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final recent = state.sales.take(3).toList();
    if (recent.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: EmptyState(
            illustration: 'empty-no-sales',
            illustrationSize: 96,
            title: 'No bills yet today',
            subtitle: 'Your posted bills will appear here. Tap “Create New Bill” to make your first sale.',
          ),
        ),
      );
    }
    final canSales = state.roleCanAccess('sales');
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < recent.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: bx.border)),
              ),
              child: _ActivityRow(sale: recent[i], onTap: canSales ? () => goTo(NavId.sales) : null),
            ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onTap;
  const _ActivityRow({required this.sale, this.onTap});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final pending = sale.paymentMode == 'Credit';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: (pending ? bx.warn : bx.pos).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
              child: Icon(pending ? Icons.schedule : Icons.receipt_long, size: 19, color: pending ? bx.warn : bx.pos),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bill ${sale.invoiceNo}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${sale.timeLabel} · ${money(sale.total)} · ${sale.paymentMode}', style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            _StatusChip(pending: pending),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool pending;
  const _StatusChip({required this.pending});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final c = pending ? bx.warn : bx.pos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
      child: Text(
        pending ? 'PENDING' : 'PAID',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: c),
      ),
    );
  }
}
