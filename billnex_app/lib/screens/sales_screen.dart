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
                    children: [for (int i = 0; i < sales.length; i++) _SaleRow(sale: sales[i], first: i == 0)],
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
  final Sale sale;
  final bool first;
  const _SaleRow({required this.sale, required this.first});

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
                    sale.paymentMode == 'Credit' ? StatusChip('PENDING', bx.warn, bx.warnBg) : StatusChip('PAID · ${sale.paymentMode}', bx.pos, bx.posBg),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${sale.dateLabel} · ${qtyLabel(sale.itemCount)} items', style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          Text(money(sale.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Reprint',
            onPressed: () => PdfService.run(context, () => PdfService.printSale(sale), failure: "Couldn't reprint — check the printer"),
            icon: Icon(Icons.print_outlined, size: 20, color: bx.muted),
          ),
          IconButton(
            tooltip: 'Share PDF',
            onPressed: () => PdfService.run(context, () => PdfService.shareSale(sale), failure: "Couldn't share the PDF"),
            icon: Icon(Icons.ios_share, size: 19, color: bx.muted),
          ),
        ],
      ),
    );
  }
}
