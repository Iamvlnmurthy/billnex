import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/pdf_service.dart';
import '../services/billing.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../widgets/receipt.dart';
import '../l10n/app_localizations.dart';
import 'customers_screen.dart' show StatusChip;

class SalesScreen extends StatefulWidget {
  final AppState state;
  const SalesScreen({required this.state, super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String? _selectedInvoice;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) => c.maxWidth >= 720 ? _wide(context) : _narrow(context));
  }

  Widget _narrow(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
    children: [ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: _masterColumn(context, wide: false))],
  );

  Widget _wide(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final sale = state.sales.where((x) => x.invoiceNo == _selectedInvoice).firstOrNull;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 16, 100), children: [_masterColumn(context, wide: true)]),
            ),
            Container(width: 1, color: bx.border),
            Expanded(
              child: sale != null
                  ? SaleDetailView(state: state, sale: sale)
                  : Center(
                      child: EmptyState(illustration: 'empty-no-sales', title: l.selectItemTitle, subtitle: l.selectItemSub),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _masterColumn(BuildContext context, {required bool wide}) {
    final l = L.of(context);
    final sales = state.sales;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(l.salesTitle, l.salesSubtitle(state.billCount, money(state.todaySales)), trailing: wide ? null : Badge2(l.auditedReprint)),
        if (sales.isEmpty)
          Card(
            child: EmptyState(illustration: 'empty-no-sales', title: l.salesEmptyTitle, subtitle: l.salesEmptySubtitle),
          )
        else
          Card(
            child: Column(
              children: [
                for (int i = 0; i < sales.length; i++)
                  _SaleRow(
                    state: state,
                    sale: sales[i],
                    first: i == 0,
                    selected: wide && sales[i].invoiceNo == _selectedInvoice,
                    onTap: wide ? () => setState(() => _selectedInvoice = sales[i].invoiceNo) : null,
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
  final bool selected;
  final VoidCallback? onTap;
  const _SaleRow({required this.state, required this.sale, required this.first, this.selected = false, this.onTap});

  bool get _isReturn => sale.paymentMode == 'Return';

  bool get _isCredit => sale.paymentMode == 'Credit';

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final balance = _isCredit ? state.invoiceBalance(sale.invoiceNo) : 0.0;
    final row = Container(
      decoration: BoxDecoration(
        color: selected ? bx.brand.withValues(alpha: 0.08) : null,
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isReturn)
                      Flexible(child: StatusChip(l.chipReturn, bx.danger, bx.dangerBg))
                    else if (_isCredit && balance > 0)
                      Flexible(child: StatusChip(l.balanceDue(money(balance)), bx.warn, bx.warnBg))
                    else if (_isCredit)
                      Flexible(child: StatusChip(l.chipPaidMode(sale.paymentMode), bx.pos, bx.posBg))
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                case 'whatsapp':
                  PdfService.run(context, () => PdfService.whatsAppSale(sale), failure: l.whatsappFail);
                case 'receive':
                  _receivePayment(context);
                case 'return':
                  returnSale(context, state, sale);
              }
            },
            itemBuilder: (ctx) => [
              if (_isCredit && balance > 0)
                PopupMenuItem(
                  value: 'receive',
                  child: ListTile(dense: true, leading: const Icon(Icons.payments_outlined), title: Text(l.receivePayment)),
                ),
              PopupMenuItem(
                value: 'print',
                child: ListTile(dense: true, leading: const Icon(Icons.print_outlined), title: Text(l.reprint)),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(dense: true, leading: const Icon(Icons.ios_share), title: Text(l.sharePdf)),
              ),
              PopupMenuItem(
                value: 'whatsapp',
                child: ListTile(dense: true, leading: const Icon(Icons.chat_outlined), title: Text(l.sendOnWhatsApp)),
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
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }

  /// Record a (possibly partial) Payment-In against this credit invoice. The
  /// amount defaults to the full balance; anything less leaves a running due.
  Future<void> _receivePayment(BuildContext context) async {
    final l = L.of(context);
    final customer = state.customerForInvoice(sale.invoiceNo);
    final balance = state.invoiceBalance(sale.invoiceNo);
    if (customer == null || balance <= 0) return;
    final messenger = ScaffoldMessenger.of(context);
    final c = TextEditingController(text: qtyLabel(balance));
    var mode = 'Cash';
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(l.receivePaymentFor(sale.invoiceNo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.balanceDue(money(balance)), style: TextStyle(color: ctx.bx.muted)),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(prefixText: '₹ ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'Cash', label: Text(l.cash)),
                  ButtonSegment(value: 'UPI', label: Text(l.upi)),
                ],
                selected: {mode},
                onSelectionChanged: (s) => setSt(() => mode = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, (double.tryParse(c.text.trim()) ?? 0).clamp(0, balance).toDouble()),
              child: Text(l.receive),
            ),
          ],
        ),
      ),
    );
    c.dispose();
    if (amount == null || amount <= 0) return;
    state.collect(customer: customer, amount: amount, mode: mode, against: sale.invoiceNo, nowMs: DateTime.now().millisecondsSinceEpoch);
    final left = state.invoiceBalance(sale.invoiceNo);
    messenger.showSnackBar(SnackBar(content: Text(left > 0 ? l.paymentRecordedLeft(money(left)) : l.paymentRecordedPaid)));
  }
}

/// Read-only invoice/receipt pane for the tablet master-detail layout. Shows the
/// same ⋮ actions (Reprint / Share / Return) available in the list row.
class SaleDetailView extends StatelessWidget {
  final AppState state;
  final Sale sale;
  const SaleDetailView({required this.state, required this.sale, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final canReturn = !sale.isReturn && !state.isReturned(sale.invoiceNo);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                sale.invoiceNo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: l.reprint,
              onPressed: () => PdfService.run(context, () => PdfService.printSale(sale), failure: l.reprintFail),
              icon: const Icon(Icons.print_outlined),
            ),
            IconButton(
              tooltip: l.sharePdf,
              onPressed: () => PdfService.run(context, () => PdfService.shareSale(sale), failure: l.shareFail),
              icon: const Icon(Icons.ios_share),
            ),
            if (canReturn) IconButton(tooltip: l.returnCreditNote, onPressed: () => returnSale(context, state, sale), icon: const Icon(Icons.assignment_return_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ReceiptView(
            templateId: sale.templateId,
            businessName: sale.businessName,
            gstin: sale.sellerGstin,
            phone: sale.sellerPhone,
            address: sale.sellerAddress,
            lines: sale.lines.map((sl) => RcptLine(sl.name, sl.qty, sl.amount)).toList(),
            subtotal: sale.subtotal,
            gst: sale.gst,
            total: sale.total,
          ),
        ),
      ],
    );
  }
}

/// Shared return flow used by both the list row menu and the detail pane.
Future<void> returnSale(BuildContext context, AppState state, Sale sale) async {
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
