import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/receipt.dart';
import '../services/pdf_service.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/sale.dart';
import '../widgets/customer_picker.dart';

class PosScreen extends StatelessWidget {
  final AppState state;
  const PosScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final items = state.stockItems;
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 900;
      final catalogCols = c.maxWidth > 1100
          ? 3
          : c.maxWidth > 560
              ? 2
              : 2;
      final catalog = _Catalog(state: state, items: items, cols: catalogCols);
      final cart = _CartPanel(state: state);

      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(children: [
              PageHeader('Billing', 'Search or scan · live receipt updates as you go.',
                  trailing: const Badge2('5-item sale in <20s')),
              if (wide)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: catalog),
                  const SizedBox(width: 16),
                  SizedBox(width: 380, child: cart),
                ])
              else ...[
                catalog,
                const SizedBox(height: 16),
                cart,
              ],
            ]),
          ),
        ],
      );
    });
  }
}

class _Catalog extends StatelessWidget {
  final AppState state;
  final List<StockItem> items;
  final int cols;
  const _Catalog({required this.state, required this.items, required this.cols});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Column(children: [
      Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bx.border),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Padding(padding: const EdgeInsets.only(left: 14), child: Icon(Icons.search, color: bx.muted)),
                hintText: 'Search item, scan barcode, or type code…',
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text('Scan'),
          style: FilledButton.styleFrom(
            backgroundColor: bx.accent,
            foregroundColor: bx.onAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 118,
        ),
        itemBuilder: (context, i) => _ProductTile(item: items[i], onTap: () => state.addProduct(items[i].toProduct())),
      ),
    ]);
  }
}

class _ProductTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback onTap;
  const _ProductTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final qtyColor = item.out ? bx.danger : (item.low ? bx.warn : bx.muted);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bx.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: bx.surface2, borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.inventory_2_outlined, size: 18, color: bx.brand),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: qtyColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 1)} ${item.unit}',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: qtyColor)),
            ),
          ]),
          const Spacer(),
          Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(children: [
            Text(money(item.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Text('/ ${item.unit}', style: TextStyle(fontSize: 11, color: bx.muted)),
          ]),
        ]),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  final AppState state;
  const _CartPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final posTemplates = kTemplates.where((t) => ['thermal80', 'thermal58', 'classic', 'modern'].contains(t.id)).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Expanded(child: Text('Current bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
              Badge2('${state.cartQty} qty'),
            ]),
            if (state.isOn('creditLedger')) ...[
              const SizedBox(height: 10),
              _CustomerChip(state: state),
            ],
            const SizedBox(height: 8),
            if (state.cart.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),
                child: Center(child: Text('Tap a product to start the bill', style: TextStyle(fontSize: 13, color: bx.muted))),
              )
            else
              ...state.cart.asMap().entries.map((e) => _CartRow(state: state, index: e.key, line: e.value)),
            const SizedBox(height: 6),
            _totRow(bx, 'Subtotal', money(state.subtotal)),
            _totRow(bx, 'GST @5%', money(state.gst)),
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.border, width: 2))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(money(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _charge(context, 'Cash'), icon: const Icon(Icons.account_balance_wallet_outlined, size: 18), label: const Text('Cash'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _charge(context, 'UPI'), child: const Text('UPI QR'))),
              if (state.isOn('creditLedger')) ...[
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () => _charge(context, 'Credit'), child: const Text('Credit'))),
              ],
            ]),
            const SizedBox(height: 8),
            if (state.isOn('kot')) ...[
              OutlinedButton.icon(
                onPressed: state.cart.isEmpty ? null : () => _sendKot(context),
                icon: const Icon(Icons.soup_kitchen_outlined, size: 18),
                label: const Text('Send to Kitchen (KOT)'),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              onPressed: () => _charge(context, 'Cash'),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text('Charge & print · ${money(state.total)}'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      // Live receipt
      Row(children: [
        const Expanded(child: Text('Live receipt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 7, runSpacing: 7, children: [
        for (final t in posTemplates)
          _TplChip(label: t.name, on: state.posTemplate == t.id, onTap: () => state.setPosTemplate(t.id)),
      ]),
      const SizedBox(height: 12),
      Center(
        child: ReceiptView(
          templateId: state.posTemplate,
          businessName: state.business!.name,
          lines: state.cart.isEmpty
              ? const [RcptLine('— add items —', 0, 0)]
              : state.cart.map((l) => RcptLine(l.product.name, l.qty, l.amount)).toList(),
          subtotal: state.subtotal,
          gst: state.gst,
          total: state.total,
        ),
      ),
    ]);
  }

  Future<void> _sendKot(BuildContext context) async {
    // Print a kitchen ticket (no price) without posting the sale.
    final kot = Sale(
      invoiceNo: '#KOT',
      epochMs: DateTime.now().millisecondsSinceEpoch,
      businessName: state.business!.name,
      templateId: 'kot',
      lines: state.cart.map((l) => SaleLine(l.product.name, l.qty, l.product.price)).toList(),
      subtotal: state.subtotal, gst: state.gst, total: state.total, paymentMode: 'KOT',
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KOT sent to kitchen ✓')));
    try {
      await PdfService.printSale(kot);
    } catch (_) {}
  }

  Future<void> _charge(BuildContext context, String mode) async {
    final messenger = ScaffoldMessenger.of(context);
    if (state.cart.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Add items first')));
      return;
    }
    Customer? customer;
    if (mode == 'Credit') {
      customer = state.selectedCustomer ?? await pickCustomer(context, state);
      if (customer == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Credit sale needs a customer')));
        return;
      }
      if (state.overLimit(customer, state.total)) {
        if (!context.mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Credit limit exceeded'),
            content: Text('${customer!.name} would exceed the ${money(customer.creditLimit)} limit. Post anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Override')),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }
    final sale = state.postSale(paymentMode: mode, nowMs: DateTime.now().millisecondsSinceEpoch, customer: customer);
    messenger.showSnackBar(SnackBar(
      content: Text('${sale.invoiceNo} posted · $mode ${money(sale.total)}${customer != null ? ' · ${customer.name}' : ''} ✓'),
      action: SnackBarAction(label: 'Share', onPressed: () => PdfService.shareSale(sale)),
    ));
    // Open the printer dialog with the real invoice PDF (default template).
    try {
      await PdfService.printSale(sale);
    } catch (_) {
      // Printing may be unavailable on some desktop/headless targets — the sale
      // is already posted and saved; user can reprint from Sales history.
    }
  }

  Widget _totRow(BxColors bx, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: TextStyle(fontSize: 13, color: bx.muted)),
          Text(v, style: TextStyle(fontSize: 13, color: bx.muted)),
        ]),
      );
}

class _CartRow extends StatelessWidget {
  final AppState state;
  final int index;
  final CartLine line;
  const _CartRow({required this.state, required this.index, required this.line});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: bx.border))),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${money(line.product.price)} · ${line.product.unit}', style: TextStyle(fontSize: 11, color: bx.muted)),
          ]),
        ),
        _stepBtn(bx, Icons.remove, () => state.dec(index)),
        SizedBox(width: 28, child: Text('${line.qty}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
        _stepBtn(bx, Icons.add, () => state.inc(index)),
        SizedBox(width: 70, child: Text(money(line.amount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
      ]),
    );
  }

  Widget _stepBtn(BxColors bx, IconData ic, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 26, height: 26,
          decoration: BoxDecoration(color: bx.surface2, borderRadius: BorderRadius.circular(7), border: Border.all(color: bx.border)),
          child: Icon(ic, size: 15),
        ),
      );
}

class _CustomerChip extends StatelessWidget {
  final AppState state;
  const _CustomerChip({required this.state});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final c = state.selectedCustomer;
    return InkWell(
      onTap: () async {
        final picked = await pickCustomer(context, state);
        if (picked != null) state.selectCustomer(picked);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bx.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c != null ? bx.brand : bx.border),
        ),
        child: Row(children: [
          Icon(c != null ? Icons.person : Icons.person_outline, size: 18, color: c != null ? bx.brand : bx.muted),
          const SizedBox(width: 8),
          Expanded(
            child: c == null
                ? Text('Walk-in customer · tap to attach', style: TextStyle(fontSize: 13, color: bx.muted))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    if (state.balanceOf(c.id) > 0)
                      Text('${money(state.balanceOf(c.id))} outstanding', style: TextStyle(fontSize: 11, color: bx.danger, fontWeight: FontWeight.w600)),
                  ]),
          ),
          if (c != null)
            InkWell(onTap: () => state.selectCustomer(null), child: Icon(Icons.close, size: 16, color: bx.muted))
          else
            Icon(Icons.chevron_right, size: 18, color: bx.faint),
        ]),
      ),
    );
  }
}

class _TplChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _TplChip({required this.label, required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: on ? bx.brand.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? bx.brand : bx.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: on ? bx.brand : bx.muted)),
      ),
    );
  }
}
