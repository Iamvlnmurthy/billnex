import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/pdf_service.dart';
import '../services/billing.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import 'customers_screen.dart' show StatusChip;

class SalesScreen extends StatelessWidget {
  final AppState state;
  const SalesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final sales = state.sales;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader('Sales', '${state.billCount} bills · ${money(state.todaySales)} total · every bill is immutable and reprintable.', trailing: const Badge2('Audited reprint')),
              if (sales.isEmpty)
                const Card(
                  child: EmptyState(illustration: 'empty-no-sales', title: 'No bills yet', subtitle: 'Post a sale from Billing — it appears here.'),
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
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return this bill?'),
        content: Text(
          'Create a credit note for ${sale.invoiceNo} (${money(sale.total)}). Items go back into stock.${sale.paymentMode == 'Credit' ? '\n\nThis was a credit bill — adjust the customer\'s khata separately.' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: ctx.bx.danger),
            child: const Text('Return'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final ret = state.returnSale(sale, nowMs: DateTime.now().millisecondsSinceEpoch);
      messenger.showSnackBar(SnackBar(content: Text('${ret.invoiceNo} · credit note for ${sale.invoiceNo} ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
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
                    Text(sale.invoiceNo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    if (_isReturn)
                      StatusChip('RETURN', bx.danger, bx.dangerBg)
                    else if (sale.paymentMode == 'Credit')
                      StatusChip('PENDING', bx.warn, bx.warnBg)
                    else
                      StatusChip('PAID · ${sale.paymentMode}', bx.pos, bx.posBg),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${sale.dateLabel} · ${qtyLabel(sale.itemCount)} items', style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          Money(
            sale.total,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            color: _isReturn ? bx.danger : null,
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: Icon(Icons.more_vert, size: 20, color: bx.muted),
            onSelected: (v) {
              switch (v) {
                case 'print':
                  PdfService.run(context, () => PdfService.printSale(sale), failure: "Couldn't reprint — check the printer");
                case 'share':
                  PdfService.run(context, () => PdfService.shareSale(sale), failure: "Couldn't share the PDF");
                case 'return':
                  _return(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'print',
                child: ListTile(dense: true, leading: Icon(Icons.print_outlined), title: Text('Reprint')),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(dense: true, leading: Icon(Icons.ios_share), title: Text('Share PDF')),
              ),
              if (!_isReturn && !state.isReturned(sale.invoiceNo))
                const PopupMenuItem(
                  value: 'return',
                  child: ListTile(dense: true, leading: Icon(Icons.assignment_return_outlined), title: Text('Return / credit note')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
