import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/pdf_service.dart';
import '../services/billing.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../l10n/app_localizations.dart';
import 'customers_screen.dart' show StatusChip;

class SalesScreen extends StatelessWidget {
  final AppState state;
  const SalesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final sales = state.sales;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(l.salesTitle, l.salesSubtitle(state.billCount, money(state.todaySales)), trailing: Badge2(l.auditedReprint)),
              if (sales.isEmpty)
                Card(
                  child: EmptyState(illustration: 'empty-no-sales', title: l.salesEmptyTitle, subtitle: l.salesEmptySubtitle),
                )
              else
                Card(
                  child: Column(
                    children: [for (int i = 0; i < sales.length; i++) _SaleRow(state: state, sale: sales[i], first: i == 0)],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaleRow extends StatelessWidget {
  final AppState state;
  final Sale sale;
  final bool first;
  const _SaleRow({required this.state, required this.sale, required this.first});

  bool get _isReturn => sale.paymentMode == 'Return';

  Future<void> _return(BuildContext context) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: l.returnDialogTitle,
      message: l.returnDialogBody(sale.invoiceNo, money(sale.total)) + (sale.paymentMode == 'Credit' ? l.returnCreditKhataNote : ''),
      confirmLabel: l.returnAction,
      destructive: true,
    );
    if (ok) {
      final ret = state.returnSale(sale, nowMs: DateTime.now().millisecondsSinceEpoch);
      messenger.showSnackBar(SnackBar(content: Text(l.returnSnack(ret.invoiceNo, sale.invoiceNo))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt_long_outlined, size: 20, color: bx.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sale.invoiceNo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isReturn)
                      Flexible(child: StatusChip(l.chipReturn, bx.danger, bx.dangerBg))
                    else if (sale.paymentMode == 'Credit')
                      Flexible(child: StatusChip(l.pending, bx.warn, bx.warnBg))
                    else
                      Flexible(child: StatusChip(l.chipPaidMode(sale.paymentMode), bx.pos, bx.posBg)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l.saleItemsLine(sale.dateLabel, qtyLabel(sale.itemCount)), style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          Money(
            sale.total,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            color: _isReturn ? bx.danger : null,
          ),
          PopupMenuButton<String>(
            tooltip: l.more,
            icon: Icon(Icons.more_vert, size: 20, color: bx.muted),
            onSelected: (v) {
              switch (v) {
                case 'print':
                  PdfService.run(context, () => PdfService.printSale(sale), failure: l.reprintFail);
                case 'share':
                  PdfService.run(context, () => PdfService.shareSale(sale), failure: l.shareFail);
                case 'return':
                  _return(context);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'print',
                child: ListTile(dense: true, leading: const Icon(Icons.print_outlined), title: Text(l.reprint)),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(dense: true, leading: const Icon(Icons.ios_share), title: Text(l.sharePdf)),
              ),
              if (!_isReturn && !state.isReturned(sale.invoiceNo))
                PopupMenuItem(
                  value: 'return',
                  child: ListTile(dense: true, leading: const Icon(Icons.assignment_return_outlined), title: Text(l.returnCreditNote)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
