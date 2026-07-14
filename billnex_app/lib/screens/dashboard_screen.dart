import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../l10n/app_localizations.dart';
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
    final l = L.of(context);
    final biz = state.business!;
    final owner = (state.profile?.owner ?? '').trim();
    final greetName = owner.isNotEmpty ? owner.split(' ').first : biz.name;
    final canBill = state.roleCanAccess('billing');
    final canInventory = state.roleCanAccess('inventory');
    final canReports = state.roleCanAccess('reports');

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Greeting ─────────────────────────────────────────────
                Text(
                  '${_greeting(l)}, $greetName',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: bx.muted),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(child: Text('${state.shopName} ${l.dashboardWord}', style: BxText.pageTitle.copyWith(fontSize: 22))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bx.posBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: bx.pos.withValues(alpha: 0.24)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: bx.pos),
                          const SizedBox(width: 5),
                          Text(
                            state.online ? l.online : l.offline,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: state.online ? bx.pos : bx.warn),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Alert banners (only when actionable for this role) ───
                if (state.lowStockCount > 0 && canInventory)
                  _AlertBanner(icon: Icons.warning_amber_rounded, color: bx.warn, bg: bx.warnBg, text: l.lowStockBanner(state.lowStockCount), onTap: () => goTo(NavId.inventory)),
                if (state.backupDue) ...[
                  if (state.lowStockCount > 0 && canInventory) const SizedBox(height: 10),
                  _AlertBanner(
                    icon: Icons.cloud_off_rounded,
                    color: bx.danger,
                    bg: bx.dangerBg,
                    text: l.backupDueBanner,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text(l.backupRestoreTitle)),
                          body: BackupScreen(state: state),
                        ),
                      ),
                    ),
                  ),
                ],
                if ((state.lowStockCount > 0 && canInventory) || state.backupDue) const SizedBox(height: 12),

                // ── Today's Summary ──────────────────────────────────────
                _SectionHead(title: l.todaysSummary, action: canReports ? l.details : null, onAction: () => goTo(NavId.reports)),
                const SizedBox(height: 8),
                _HeroSales(state: state),
                const SizedBox(height: 8),
                _SummaryGrid(state: state, goTo: goTo),
                const SizedBox(height: 12),

                if (canBill) ...[
                  FilledButton.icon(
                    onPressed: () => goTo(NavId.billing),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text(l.createNewBill),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Quick actions ────────────────────────────────────────
                _QuickActions(state: state, goTo: goTo),
                const SizedBox(height: 12),

                // ── Recent Activity ──────────────────────────────────────
                _SectionHead(title: l.recentActivity, action: (state.billCount > 0 && state.roleCanAccess('sales')) ? l.viewAll : null, onAction: () => goTo(NavId.sales)),
                const SizedBox(height: 8),
                _RecentActivity(state: state, goTo: goTo),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greeting(L l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.greetMorning;
    if (h < 17) return l.greetAfternoon;
    return l.greetEvening;
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
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
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
    final l = L.of(context);
    final live = state.billCount > 0;
    final points = state.sales.take(8).map((sale) => sale.total.abs()).toList().reversed.toList();
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A2A51), Color(0xFF0B3B75)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3988FF).withValues(alpha: 0.42)),
        boxShadow: bx.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.todaysSales,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFC6D8F0)),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.auto_graph_rounded, size: 18, color: Color(0xFF69A4FF)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Money(
            state.todaySales,
            style: BxText.valueHero.copyWith(fontSize: 30, color: Colors.white),
            color: Colors.white,
          ),
          const SizedBox(height: 1),
          Text(
            live ? l.billsCount(state.billCount) : l.noBillsYet,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: live ? const Color(0xFF45E195) : const Color(0xFF9CB2CD)),
          ),
          // Sparkline only when there's real history — no empty band on a fresh store.
          if (points.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              width: double.infinity,
              child: CustomPaint(painter: _SalesSparkline(points, const Color(0xFF55A1FF))),
            ),
          ],
        ],
      ),
    );
  }
}

class _SalesSparkline extends CustomPainter {
  final List<double> values;
  final Color color;
  const _SalesSparkline(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final source = values.length > 1 ? values : const <double>[0, 0, 0, 0, 0];
    final high = source.reduce((a, b) => a > b ? a : b);
    final low = source.reduce((a, b) => a < b ? a : b);
    final span = (high - low).abs() < 0.01 ? 1.0 : high - low;
    final line = Path();
    for (var i = 0; i < source.length; i++) {
      final x = size.width * i / (source.length - 1);
      final y = size.height - 4 - ((source[i] - low) / span) * (size.height - 12);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0.01)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesSparkline oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}

/// Four stat cards: Total Bills, Cash, UPI, Credit Sales.
class _SummaryGrid extends StatelessWidget {
  final AppState state;
  final void Function(NavId) goTo;
  const _SummaryGrid({required this.state, required this.goTo});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 78,
          children: [
            _MiniStat(l.totalBills, '${state.billCount}', color: bx.muted),
            _MiniStat(l.cashReceived2, money(cash), color: bx.muted),
            _MiniStat(l.upiCard, money(upi), color: bx.muted),
            _MiniStat(l.creditSales, money(credit), color: credit > 0 ? bx.danger : bx.muted, onTap: state.isOn('creditLedger') ? () => goTo(NavId.customers) : null),
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
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: bx.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null) Icon(Icons.chevron_right, size: 15, color: bx.faint),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: color == bx.danger ? bx.danger : null),
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
    final l = L.of(context);
    final ledgerOn = state.isOn('creditLedger');
    final canInventory = state.roleCanAccess('inventory');
    final canReports = state.roleCanAccess('reports');
    final canCustomers = state.roleCanAccess('customers');
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      if (canInventory) (icon: Icons.add_box_outlined, label: l.addProduct, onTap: () => goTo(NavId.inventory)),
      if (canInventory) (icon: Icons.inventory_2_outlined, label: l.viewStock, onTap: () => goTo(NavId.inventory)),
      if (ledgerOn && canCustomers) (icon: Icons.groups_outlined, label: l.ledger, onTap: () => goTo(NavId.customers)),
      if (canReports) (icon: Icons.assessment_outlined, label: l.dayClosing, onTap: () => goTo(NavId.reports)),
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
    final l = L.of(context);
    final recent = state.sales.take(3).toList();
    if (recent.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: EmptyState(illustration: 'empty-no-sales', illustrationSize: 96, title: l.noBillsTodayTitle, subtitle: l.noBillsTodaySubtitle),
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
    final l = L.of(context);
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
                  Text(l.billNo(sale.invoiceNo), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
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
    final l = L.of(context);
    final c = pending ? bx.warn : bx.pos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
      child: Text(
        pending ? l.pending : l.paid,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: c),
      ),
    );
  }
}
