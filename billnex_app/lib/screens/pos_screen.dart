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

      // Wide (tablet/desktop): products + cart side by side.
      if (wide) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(children: [
                const PageHeader('Billing', 'Search or scan · live receipt updates as you go.',
                    trailing: Badge2('5-item sale in <20s')),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _Catalog(state: state, items: items)),
                  const SizedBox(width: 16),
                  SizedBox(width: 380, child: _CartPanel(state: state)),
                ]),
              ]),
            ),
          ],
        );
      }

      // Phone: products scroll; a sticky bottom bar shows the total and opens
      // the cart. Core billing stays in view.
      return Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
            children: [
              const PageHeader('Billing', 'Search or scan to add items.'),
              _Catalog(state: state, items: items),
            ],
          ),
        ),
        _MobileCartBar(state: state),
      ]);
    });
  }
}

/// Sticky bottom billing bar for phones: live qty + total, opens the cart sheet.
class _MobileCartBar extends StatelessWidget {
  final AppState state;
  const _MobileCartBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final empty = state.cart.isEmpty;
    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('${state.cartQty} item${state.cartQty == 1 ? '' : 's'}', style: TextStyle(fontSize: 12, color: bx.muted)),
              Text(money(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ]),
            const Spacer(),
            FilledButton.icon(
              onPressed: empty ? null : () => _openCart(context),
              icon: const Icon(Icons.shopping_cart_checkout, size: 18),
              label: const Text('View bill'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13)),
            ),
          ]),
        ),
    );
  }

  void _openCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scroll) => AnimatedBuilder(
          animation: state,
          builder: (ctx, _) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            children: [_CartPanel(state: state)],
          ),
        ),
      ),
    );
  }
}

class _Catalog extends StatefulWidget {
  final AppState state;
  final List<StockItem> items;
  const _Catalog({required this.state, required this.items});
  @override
  State<_Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<_Catalog> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _scan(BuildContext context) async {
    final c = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter / scan barcode'),
        content: TextField(controller: c, autofocus: true, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Barcode number', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
        ],
      ),
    );
    if (code == null || code.trim().isEmpty) return;
    final name = widget.state.addByCode(code);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(name != null ? '$name added ✓' : 'No product with barcode $code')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final all = widget.items;
    final items = _q.isEmpty
        ? all
        : all.where((i) => i.name.toLowerCase().contains(_q.toLowerCase()) || (i.barcode?.contains(_q) ?? false)).toList();
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
              controller: _search,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Padding(padding: const EdgeInsets.only(left: 14), child: Icon(Icons.search, color: bx.muted)),
                suffixIcon: _q.isEmpty ? null : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() { _q = ''; _search.clear(); })),
                hintText: 'Search products…',
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52, height: 52,
          child: FilledButton(
            onPressed: () => _scan(context),
            style: FilledButton.styleFrom(
              backgroundColor: bx.accent,
              foregroundColor: bx.onAccent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.qr_code_scanner, size: 22),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      if (all.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: bx.border)),
          child: Column(children: [
            Icon(Icons.add_business_outlined, size: 40, color: bx.faint),
            const SizedBox(height: 12),
            const Text('No products yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Add your shop\'s products in the Inventory tab, then bill them here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: bx.muted)),
          ]),
        )
      else if (items.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Center(child: Text('No products match "$_q"', style: TextStyle(color: bx.muted))))
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, i) => _ProductTile(item: items[i], onTap: () => widget.state.addProduct(items[i])),
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
            if (state.cart.isNotEmpty) ...[
              _totRow(bx, 'Taxable', money(state.bill.taxable)),
              if (state.bill.discountTotal > 0) _totRow(bx, 'Discount', '− ${money(state.bill.discountTotal)}'),
              _totRow(bx, 'CGST', money(state.bill.cgst)),
              _totRow(bx, 'SGST', money(state.bill.sgst)),
              if (state.bill.roundOff != 0) _totRow(bx, 'Round off', money(state.bill.roundOff)),
              // Bill discount entry
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(Icons.local_offer_outlined, size: 15, color: bx.muted),
                  const SizedBox(width: 6),
                  Text('Bill discount', style: TextStyle(fontSize: 13, color: bx.muted)),
                  const Spacer(),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '₹ ', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                      onChanged: (v) => state.setBillDiscount(double.tryParse(v) ?? 0),
                    ),
                  ),
                ]),
              ),
            ],
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
      const Row(children: [
        Expanded(child: Text('Live receipt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
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
          businessName: state.shopName,
          gstin: state.profile?.gstin,
          phone: state.profile?.phone,
          address: state.profile?.address,
          lines: state.cart.isEmpty
              ? const [RcptLine('— add items —', 0, 0)]
              : state.cart.map((l) => RcptLine(l.name, l.qty, l.amount)).toList(),
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
      businessName: state.shopName,
      templateId: 'kot',
      lines: state.cart.map((l) => SaleLine(l.name, l.qty, l.price)).toList(),
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
            Text(line.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${money(line.price)} · ${line.unit}', style: TextStyle(fontSize: 11, color: bx.muted)),
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
