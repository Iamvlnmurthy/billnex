import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ReportsScreen extends StatelessWidget {
  final AppState state;
  const ReportsScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final mix = state.paymentMix();
    final items = state.itemSales();
    final mixTotal = mix.values.fold<double>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                'Reports & Analytics',
                'Everything below is computed live from posted transactions.',
                trailing: FilledButton.icon(
                  onPressed: () => PdfService.run(
                    context,
                    () => PdfService.shareReport(
                      businessName: state.shopName,
                      summary: {
                        'Gross sales': money(state.salesGross),
                        'GST collected': money(state.gstCollected),
                        'Net sales': money(state.salesNet),
                        'Bills': '${state.billCount}',
                        'Avg bill': money(state.avgBill),
                        'Receivable': money(state.totalReceivable),
                        'Payable': money(state.totalPayable),
                        'Stock @ cost': money(state.stockValueAtCost),
                      },
                      paymentMix: mix,
                      items: items,
                    ),
                    failure: "Couldn't export the report",
                  ),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('Export PDF'),
                ),
              ),
              // KPI grid
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 720 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 96,
                    children: [
                      _kpi(bx, 'Net sales', money(state.salesNet)),
                      _kpi(bx, 'GST collected', money(state.gstCollected)),
                      _kpi(bx, 'Bills', '${state.billCount}'),
                      _kpi(bx, 'Avg bill', money(state.avgBill)),
                      _kpi(bx, 'Items sold', qtyLabel(state.itemsSold)),
                      _kpi(bx, 'Receivable', money(state.totalReceivable)),
                      _kpi(bx, 'Payable', money(state.totalPayable)),
                      _kpi(bx, 'Stock @ cost', money(state.stockValueAtCost)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Payment mix + top items
              LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth > 820;
                  final mixCard = _paymentMixCard(context, mix, mixTotal);
                  final itemsCard = _itemsCard(context, items);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: mixCard),
                        const SizedBox(width: 16),
                        Expanded(child: itemsCard),
                      ],
                    );
                  }
                  return Column(children: [mixCard, const SizedBox(height: 16), itemsCard]);
                },
              ),
              const SizedBox(height: 16),
              _plCard(context),
              const SizedBox(height: 16),
              _hsnCard(context),
              const SizedBox(height: 16),
              _dayBookCard(context),
            ],
          ),
        ),
      ],
    );
  }

  // ── Profit & Loss ──────────────────────────────────────────────────────
  Widget _plCard(BuildContext context) {
    final bx = context.bx;
    final pl = state.profitAndLoss();
    Widget row(String k, double v, {bool bold = false, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: TextStyle(fontSize: 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: bold ? null : bx.muted),
          ),
          Money(
            v,
            style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w700),
            color: color,
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Profit & Loss', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            row('Sales (taxable)', pl.sales),
            row('Cost of goods sold', -pl.cogs, color: bx.danger),
            Divider(color: bx.border, height: 18),
            row('Gross profit', pl.grossProfit, bold: true, color: pl.grossProfit >= 0 ? bx.pos : bx.danger),
            const SizedBox(height: 4),
            Text('GST collected ${money(pl.gst)} is a pass-through, not income.', style: TextStyle(fontSize: 11.5, color: bx.faint)),
          ],
        ),
      ),
    );
  }

  // ── Sale Summary by HSN ────────────────────────────────────────────────
  Widget _hsnCard(BuildContext context) {
    final bx = context.bx;
    final rows = state.hsnSummary();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Sale summary by HSN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                if (rows.isNotEmpty)
                  TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-HSN-summary.csv', state.hsnCsv()), icon: const Icon(Icons.download, size: 16), label: const Text('CSV')),
              ],
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text('No sales yet', style: TextStyle(color: bx.muted))
            else ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('HSN', style: BxText.meta.copyWith(color: bx.faint)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'GST',
                      textAlign: TextAlign.right,
                      style: BxText.meta.copyWith(color: bx.faint),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'TAXABLE',
                      textAlign: TextAlign.right,
                      style: BxText.meta.copyWith(color: bx.faint),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'TAX',
                      textAlign: TextAlign.right,
                      style: BxText.meta.copyWith(color: bx.faint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (final r in rows)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: bx.border)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(r.hsn, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${r.rate.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: bx.muted),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          money(r.taxable),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          money(r.tax),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Day Book ───────────────────────────────────────────────────────────
  Widget _dayBookCard(BuildContext context) {
    final bx = context.bx;
    final rows = state.dayBook();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Day book', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                if (rows.isNotEmpty)
                  TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-daybook.csv', state.dayBookCsv()), icon: const Icon(Icons.download, size: 16), label: const Text('CSV')),
              ],
            ),
            const SizedBox(height: 4),
            if (rows.isEmpty)
              Text('No transactions yet', style: TextStyle(color: bx.muted))
            else
              for (final r in rows.take(20))
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: bx.border)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r.type} · ${r.ref}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            Text(r.party, style: TextStyle(fontSize: 11.5, color: bx.muted)),
                          ],
                        ),
                      ),
                      if (r.inAmt > 0)
                        Money(
                          r.inAmt,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          color: bx.pos,
                        ),
                      if (r.outAmt > 0)
                        Money(
                          r.outAmt,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          color: bx.danger,
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, String fileName, String csv) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await FilePicker.platform.saveFile(dialogTitle: 'Save $fileName', fileName: fileName, bytes: Uint8List.fromList(utf8.encode(csv)));
      messenger.showSnackBar(SnackBar(content: Text(path == null ? 'Export cancelled' : 'Saved $fileName ✓')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Widget _kpi(BxColors bx, String k, String v) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            k,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bx.muted),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(v, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ),
        ],
      ),
    ),
  );

  Widget _paymentMixCard(BuildContext context, Map<String, double> mix, double total) {
    final bx = context.bx;
    final colors = {'Cash': bx.pos, 'UPI': bx.accent, 'Credit': bx.warn, 'Bank': bx.brand};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Payment mix', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (mix.isEmpty)
              Text('No sales yet', style: TextStyle(color: bx.muted))
            else
              ...mix.entries.map((e) {
                final frac = total == 0 ? 0.0 : e.value / total;
                final color = colors[e.key] ?? bx.brand;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text(money(e.value), style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          Text('${(frac * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, color: bx.muted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(value: frac, minHeight: 8, backgroundColor: bx.surface2, valueColor: AlwaysStoppedAnimation(color)),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _itemsCard(BuildContext context, List<({String name, double qty, double value})> items) {
    final bx = context.bx;
    final top = items.take(8).toList();
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Top items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('No sales yet', style: TextStyle(color: bx.muted)),
            )
          else
            for (int i = 0; i < top.length; i++)
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: bx.border)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: bx.faint),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        top[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${qtyLabel(top[i].qty)} sold', style: TextStyle(fontSize: 12, color: bx.muted)),
                    const SizedBox(width: 12),
                    Text(money(top[i].value), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
