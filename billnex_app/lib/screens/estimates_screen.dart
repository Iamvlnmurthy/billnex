import 'package:flutter/material.dart';
import '../models/saved_doc.dart';
import '../models/customer.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/customer_picker.dart';
import '../l10n/app_localizations.dart';

/// Saved Estimates/Quotations and Sale Orders — list, share, and convert to an
/// invoice (the point where stock + khata are actually posted).
class EstimatesScreen extends StatelessWidget {
  final AppState state;
  const EstimatesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.estimatesOrdersTitle),
          bottom: TabBar(tabs: [Tab(text: l.estimatesTab), Tab(text: l.ordersTab)]),
        ),
        body: AnimatedBuilder(
          animation: state,
          builder: (context, _) => TabBarView(
            children: [
              _list(context, DocType.estimate),
              _list(context, DocType.order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, DocType type) {
    final bx = context.bx;
    final l = L.of(context);
    final docs = state.docsOfType(type);
    if (docs.isEmpty) {
      return Center(child: Text(type == DocType.estimate ? l.noEstimates : l.noOrders, style: TextStyle(color: bx.muted)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              child: Column(
                children: [for (int i = 0; i < docs.length; i++) _row(context, docs[i], first: i == 0)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, SavedDoc d, {required bool first}) {
    final bx = context.bx;
    final l = L.of(context);
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(11)),
            child: Icon(d.type == DocType.estimate ? Icons.request_quote_outlined : Icons.assignment_outlined, size: 20, color: bx.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.number, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${d.dateLabel} · ${d.customerName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          Money(d.total, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          PopupMenuButton<String>(
            tooltip: l.more,
            icon: Icon(Icons.more_vert, size: 20, color: bx.muted),
            onSelected: (v) {
              switch (v) {
                case 'share':
                  PdfService.run(context, () => PdfService.shareSale(d.toSale()), failure: l.shareFail);
                case 'convert':
                  _convert(context, d);
                case 'delete':
                  _delete(context, d);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'share', child: ListTile(dense: true, leading: const Icon(Icons.ios_share), title: Text(l.sharePdf))),
              PopupMenuItem(value: 'convert', child: ListTile(dense: true, leading: const Icon(Icons.receipt_long_outlined), title: Text(l.convertToInvoice))),
              PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: bx.danger), title: Text(l.delete, style: TextStyle(color: bx.danger)))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _convert(BuildContext context, SavedDoc d) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(l.convertToInvoice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ListTile(leading: const Icon(Icons.payments_outlined), title: Text(l.cash), onTap: () => Navigator.pop(ctx, 'Cash')),
            ListTile(leading: const Icon(Icons.qr_code_2), title: Text(l.upi), onTap: () => Navigator.pop(ctx, 'UPI')),
            if (state.isOn('creditLedger')) ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: Text(l.credit), onTap: () => Navigator.pop(ctx, 'Credit')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (mode == null) return;
    if (!context.mounted) return;
    Customer? customer;
    if (mode == 'Credit') {
      customer = await pickCustomer(context, state);
      if (customer == null) return;
    }
    final sale = state.convertDoc(d, paymentMode: mode, customer: customer, nowMs: DateTime.now().millisecondsSinceEpoch);
    messenger.showSnackBar(SnackBar(content: Text(l.docConverted(sale.invoiceNo))));
  }

  Future<void> _delete(BuildContext context, SavedDoc d) async {
    final l = L.of(context);
    if (await confirmDialog(context, title: l.deleteDoc, message: '${d.number} · ${money(d.total)}', confirmLabel: l.delete, destructive: true)) {
      state.deleteDoc(d.id);
    }
  }
}
