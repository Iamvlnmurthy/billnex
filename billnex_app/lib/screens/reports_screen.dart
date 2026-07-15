import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  final AppState state;
  const ReportsScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final mix = state.paymentMix();
    final items = state.itemSales();
    final mixTotal = mix.values.fold<double>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                l.reportsTitle,
                l.reportsSubtitle,
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
                    failure: l.exportReportFail,
                  ),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(l.exportPdf),
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
                    mainAxisExtent: 104,
                    children: [
                      _kpi(bx, l.kpiNetSales, money(state.salesNet)),
                      _kpi(bx, l.kpiGstCollected, money(state.gstCollected)),
                      _kpi(bx, l.kpiBills, '${state.billCount}'),
                      _kpi(bx, l.kpiAvgBill, money(state.avgBill)),
                      _kpi(bx, l.kpiItemsSold, qtyLabel(state.itemsSold)),
                      _kpi(bx, l.kpiReceivable, money(state.totalReceivable)),
                      _kpi(bx, l.kpiPayable, money(state.totalPayable)),
                      _kpi(bx, l.kpiStockAtCost, money(state.stockValueAtCost)),
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
              _gstr1Card(context),
              const SizedBox(height: 16),
              _hsnCard(context),
              const SizedBox(height: 16),
              _lowStockCard(context),
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
    final l = L.of(context);
    final pl = state.profitAndLoss();
    Widget row(String k, double v, {bool bold = false, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(fontSize: 13.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: bold ? null : bx.muted),
            ),
          ),
          const SizedBox(width: 8),
          Money(
            v,
            style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w700),
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
            Text(l.profitLoss, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            row(l.plSalesTaxable, pl.sales),
            row(l.plCogs, -pl.cogs, color: bx.danger),
            Divider(color: bx.border, height: 18),
            row(l.plGrossProfit, pl.grossProfit, color: pl.grossProfit >= 0 ? bx.pos : bx.danger),
            if (pl.expenses > 0) row(l.plExpenses, -pl.expenses, color: bx.danger),
            Divider(color: bx.border, height: 18),
            row(l.plNetProfit, pl.netProfit, bold: true, color: pl.netProfit >= 0 ? bx.pos : bx.danger),
            const SizedBox(height: 4),
            Text(l.plGstNote(money(pl.gst)), style: TextStyle(fontSize: 11.5, color: bx.faint)),
          ],
        ),
      ),
    );
  }

  // ── GSTR-1 rate-wise (B2C) ─────────────────────────────────────────────
  Widget _gstr1Card(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final rows = state.gstr1Summary();
    final taxableTotal = rows.fold<double>(0, (a, r) => a + r.taxable);
    final taxTotal = rows.fold<double>(0, (a, r) => a + r.cgst + r.sgst);

    Widget cell(String s, int flex, {TextAlign align = TextAlign.right, bool head = false, bool strong = false}) => Expanded(
      flex: flex,
      child: Text(
        s,
        textAlign: align,
        style: head ? BxText.meta.copyWith(color: bx.faint) : TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w700, color: strong ? bx.brand : null),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.gstr1Title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(l.gstr1Sub, style: TextStyle(fontSize: 11.5, color: bx.faint, height: 1.35)),
            if (rows.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  children: [
                    TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-GSTR1.csv', state.gstr1Csv()), icon: const Icon(Icons.download, size: 16), label: Text(l.csv)),
                    TextButton.icon(
                      onPressed: () => PdfService.run(
                        context,
                        () => PdfService.shareGstReport(businessName: state.shopName, gstin: state.profile?.gstin, gstr1: state.gstr1Summary(), hsn: state.hsnSummary()),
                        failure: l.gstReportFail,
                      ),
                      icon: const Icon(Icons.ios_share, size: 16),
                      label: Text(l.exportGstPdf),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text(l.noSalesYet, style: TextStyle(color: bx.muted))
            else ...[
              Row(
                children: [
                  cell(l.gstCol, 2, align: TextAlign.left, head: true),
                  cell(l.taxableCol, 4, head: true),
                  cell(l.cgstCol, 3, head: true),
                  cell(l.sgstCol, 3, head: true),
                ],
              ),
              const SizedBox(height: 4),
              for (final r in rows)
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.border))),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('${r.rate.toStringAsFixed(0)}%', style: TextStyle(color: bx.muted, fontWeight: FontWeight.w600))),
                      cell(money(r.taxable), 4),
                      cell(money(r.cgst), 3),
                      cell(money(r.sgst), 3),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.brand.withValues(alpha: 0.4), width: 1.4))),
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    cell(l.totalLabel, 2, align: TextAlign.left, strong: true),
                    cell(money(taxableTotal), 4, strong: true),
                    cell(money(taxTotal / 2), 3, strong: true),
                    cell(money(taxTotal / 2), 3, strong: true),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Sale Summary by HSN ────────────────────────────────────────────────
  Widget _hsnCard(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final rows = state.hsnSummary();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.hsnSummaryTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                if (rows.isNotEmpty) TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-HSN-summary.csv', state.hsnCsv()), icon: const Icon(Icons.download, size: 16), label: Text(l.csv)),
              ],
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text(l.noSalesYet, style: TextStyle(color: bx.muted))
            else ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(l.hsnCol, style: BxText.meta.copyWith(color: bx.faint)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l.gstCol,
                      textAlign: TextAlign.right,
                      style: BxText.meta.copyWith(color: bx.faint),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l.taxableCol,
                      textAlign: TextAlign.right,
                      style: BxText.meta.copyWith(color: bx.faint),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l.taxCol,
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

  // ── Low stock · Reorder list ───────────────────────────────────────────
  Widget _lowStockCard(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final rows = state.reorderList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.lowStockTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(l.lowStockSub, style: TextStyle(fontSize: 11.5, color: bx.faint, height: 1.35)),
            if (rows.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  children: [
                    TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-reorder-list.csv', state.reorderCsv()), icon: const Icon(Icons.download, size: 16), label: Text(l.csv)),
                    TextButton.icon(
                      onPressed: () => PdfService.run(context, () => PdfService.whatsAppText(state.reorderWhatsAppText()), failure: l.reorderShareFail),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: Text(l.shareReorderWa),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text(l.stockHealthy, style: TextStyle(color: bx.pos, fontWeight: FontWeight.w600))
            else ...[
              Row(
                children: [
                  Expanded(flex: 4, child: Text(l.item, style: BxText.meta.copyWith(color: bx.faint))),
                  Expanded(flex: 3, child: Text(l.inStockCol, textAlign: TextAlign.right, style: BxText.meta.copyWith(color: bx.faint))),
                  Expanded(flex: 3, child: Text(l.reorderAtCol, textAlign: TextAlign.right, style: BxText.meta.copyWith(color: bx.faint))),
                  Expanded(flex: 2, child: Text(l.suggestedCol, textAlign: TextAlign.right, style: BxText.meta.copyWith(color: bx.faint))),
                ],
              ),
              const SizedBox(height: 4),
              for (final r in rows)
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.border))),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text(r.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 3, child: Text('${qtyLabel(r.qty)} ${r.unit}', textAlign: TextAlign.right, style: TextStyle(color: r.qty <= 0 ? bx.danger : bx.warn, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text(qtyLabel(r.reorder), textAlign: TextAlign.right, style: TextStyle(color: bx.muted))),
                      Expanded(flex: 2, child: Text(qtyLabel(r.suggested), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
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
    final l = L.of(context);
    final rows = state.dayBook();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.dayBookTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                if (rows.isNotEmpty) TextButton.icon(onPressed: () => _exportCsv(context, 'BillNex-daybook.csv', state.dayBookCsv()), icon: const Icon(Icons.download, size: 16), label: Text(l.csv)),
              ],
            ),
            const SizedBox(height: 4),
            if (rows.isEmpty)
              Text(l.noTransactions, style: TextStyle(color: bx.muted))
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
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          color: bx.pos,
                        ),
                      if (r.outAmt > 0)
                        Money(
                          r.outAmt,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await FilePicker.platform.saveFile(dialogTitle: l.saveFileTitle(fileName), fileName: fileName, bytes: Uint8List.fromList(utf8.encode(csv)));
      messenger.showSnackBar(SnackBar(content: Text(path == null ? l.exportCancelled : l.savedFile(fileName))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.exportFailed('$e'))));
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bx.muted),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(v, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ),
        ],
      ),
    ),
  );

  Widget _paymentMixCard(BuildContext context, Map<String, double> mix, double total) {
    final bx = context.bx;
    final l = L.of(context);
    final colors = {'Cash': bx.pos, 'UPI': bx.accent, 'Credit': bx.warn, 'Bank': bx.brand};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.paymentMixTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            if (mix.isEmpty)
              Text(l.noSalesYet, style: TextStyle(color: bx.muted))
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
                          Text(money(e.value), style: const TextStyle(fontWeight: FontWeight.w700)),
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
    final l = L.of(context);
    final top = items.take(8).toList();
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l.topItems, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(l.noSalesYet, style: TextStyle(color: bx.muted)),
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
                        style: TextStyle(fontWeight: FontWeight.w700, color: bx.faint),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        top[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(l.qtySold(qtyLabel(top[i].qty)), style: TextStyle(fontSize: 12, color: bx.muted)),
                    const SizedBox(width: 12),
                    Text(money(top[i].value), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
