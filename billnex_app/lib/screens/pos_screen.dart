import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/receipt.dart';
import '../services/billing.dart';
import '../services/pdf_service.dart';
import '../models/customer.dart';
import '../models/stock.dart';
import '../models/sale.dart';
import '../widgets/customer_picker.dart';
import '../widgets/empty_state.dart';
import '../l10n/app_localizations.dart';
import 'scanner_screen.dart';

class PosScreen extends StatelessWidget {
  final AppState state;
  const PosScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final items = state.stockItems;
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth > 900;

        // Wide (tablet/desktop): products + cart side by side.
        if (wide) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  children: [
                    PageHeader(l.billingTitle, l.billingSubtitleWide),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Catalog(state: state, items: items),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(width: 380, child: _CartPanel(state: state)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Phone: products scroll; a sticky bottom bar shows the total and opens
        // the cart. Core billing stays in view.
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                children: [
                  PageHeader(l.billingTitle, l.billingSubtitlePhone),
                  _Catalog(state: state, items: items),
                ],
              ),
            ),
            _MobileCartBar(state: state),
          ],
        );
      },
    );
  }
}

/// Sticky bottom billing bar for phones: live qty + total, opens the cart sheet.
class _MobileCartBar extends StatelessWidget {
  final AppState state;
  const _MobileCartBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final empty = state.cart.isEmpty;
    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.itemCountLabel(qtyLabel(state.cartQty)), style: TextStyle(fontSize: 12, color: bx.muted)),
                Text(money(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: empty ? null : () => _openCart(context),
              icon: const Icon(Icons.shopping_cart_checkout, size: 18),
              label: Text(l.viewBill),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13)),
            ),
          ],
        ),
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
    // Web/desktop have no reliable camera → go straight to manual entry.
    String? code;
    if (!kIsWeb) {
      code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ScannerScreen()));
    } else {
      code = '__manual__';
    }
    if (code == '__manual__') {
      if (!context.mounted) return;
      code = await _manualEntry(context);
    }
    if (code == null || code.trim().isEmpty) return;
    final name = widget.state.addByCode(code);
    if (context.mounted) {
      final l = L.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(name != null ? l.addedSnack(name) : l.noProductBarcode(code))));
    }
  }

  /// Adds a product to the cart; warns when a tracked item is out of stock
  /// instead of silently driving stock negative.
  void _add(BuildContext context, StockItem item) {
    final ok = widget.state.addProduct(item);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.of(context).outOfStock(item.name))));
    }
  }

  Future<String?> _manualEntry(BuildContext context) async {
    final l = L.of(context);
    final c = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.enterBarcodeSku),
          content: TextField(
            controller: c,
            autofocus: true,
            decoration: InputDecoration(hintText: l.barcodeHint, border: const OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(l.add)),
          ],
        ),
      );
    } finally {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final all = widget.items;
    final items = _q.isEmpty
        ? all
        : all.where((i) {
            final q = _q.toLowerCase();
            return i.name.toLowerCase().contains(q) || (i.barcode?.toLowerCase().contains(q) ?? false) || i.sku.toLowerCase().contains(q);
          }).toList();
    return Column(
      children: [
        Row(
          children: [
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
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Icon(Icons.search, color: bx.muted),
                    ),
                    suffixIcon: _q.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l.clearSearch,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() {
                              _q = '';
                              _search.clear();
                            }),
                          ),
                    hintText: l.searchProducts,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              height: 52,
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
          ],
        ),
        const SizedBox(height: 14),
        if (all.isEmpty)
          EmptyState(illustration: 'empty-no-products', title: l.noProductsTitle, subtitle: l.posNoProductsSub)
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(l.noProductsMatch(_q), style: TextStyle(color: bx.muted)),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 130),
            itemBuilder: (context, i) => _ProductTile(item: items[i], onTap: () => _add(context, items[i])),
          ),
      ],
    );
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
    return Opacity(
      opacity: item.out ? 0.55 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.out ? bx.danger.withValues(alpha: 0.5) : bx.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: bx.surface2, borderRadius: BorderRadius.circular(9)),
                    child: Icon(Icons.inventory_2_outlined, size: 18, color: bx.brand),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: qtyColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      item.stockTracked ? '${qtyLabel(item.qty)} ${item.unit}' : L.of(context).serviceLabel,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: qtyColor),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(money(item.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '/ ${item.unit}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: bx.muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final l = L.of(context);
    final posTemplates = kTemplates.where((t) => ['thermal80', 'thermal58', 'classic', 'modern'].contains(t.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.currentBill, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                    Badge2(l.qtyBadge(qtyLabel(state.cartQty))),
                  ],
                ),
                if (state.isOn('creditLedger')) ...[const SizedBox(height: 10), _CustomerChip(state: state)],
                const SizedBox(height: 8),
                if (state.cart.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 34),
                    child: Center(
                      child: Text(l.tapProductToStart, style: TextStyle(fontSize: 13, color: bx.muted)),
                    ),
                  )
                else
                  ...state.cart.asMap().entries.map((e) => _CartRow(state: state, index: e.key, line: e.value)),
                const SizedBox(height: 6),
                if (state.cart.isNotEmpty) ...[
                  _totRow(bx, l.taxable, money(state.bill.taxable)),
                  if (state.bill.discountTotal > 0) _totRow(bx, l.discount, '− ${money(state.bill.discountTotal)}'),
                  _totRow(bx, l.cgst, money(state.bill.cgst)),
                  _totRow(bx, l.sgst, money(state.bill.sgst)),
                  if (state.bill.roundOff != 0) _totRow(bx, l.roundOff, money(state.bill.roundOff)),
                  // Bill discount entry
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_outlined, size: 15, color: bx.muted),
                        const SizedBox(width: 6),
                        Text(l.billDiscountLabel, style: TextStyle(fontSize: 13, color: bx.muted)),
                        const Spacer(),
                        SizedBox(width: 90, child: _BillDiscountField(state: state)),
                      ],
                    ),
                  ),
                ],
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: bx.border, width: 2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.total, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(money(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final empty = state.cart.isEmpty;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(onPressed: empty ? null : () => _charge(context, 'Cash'), icon: const Icon(Icons.account_balance_wallet_outlined, size: 18), label: Text(l.cash)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(onPressed: empty ? null : () => _charge(context, 'UPI'), child: Text(l.upiQr)),
                        ),
                        if (state.isOn('creditLedger')) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(onPressed: empty ? null : () => _charge(context, 'Credit'), child: Text(l.credit)),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (state.isOn('kot')) ...[
                  OutlinedButton.icon(onPressed: state.cart.isEmpty ? null : () => _sendKot(context), icon: const Icon(Icons.soup_kitchen_outlined, size: 18), label: Text(l.sendKot)),
                  const SizedBox(height: 8),
                ],
                FilledButton.icon(
                  onPressed: state.cart.isEmpty ? null : () => _charge(context, 'Cash'),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(state.cart.isEmpty ? l.addItemsToCharge : l.chargePrintAmt(money(state.total))),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Live receipt
        Row(
          children: [
            Expanded(
              child: Text(l.liveReceipt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [for (final t in posTemplates) _TplChip(label: t.name, on: state.posTemplate == t.id, onTap: () => state.setPosTemplate(t.id))],
        ),
        const SizedBox(height: 12),
        Center(
          child: ReceiptView(
            templateId: state.posTemplate,
            businessName: state.shopName,
            gstin: state.profile?.gstin,
            phone: state.profile?.phone,
            address: state.profile?.address,
            lines: state.cart.isEmpty ? [RcptLine(l.addItemsPlaceholder, 0, 0)] : state.cart.map((cl) => RcptLine(cl.name, cl.qty, cl.net)).toList(),
            subtotal: state.subtotal,
            gst: state.gst,
            total: state.total,
          ),
        ),
      ],
    );
  }

  Future<void> _sendKot(BuildContext context) async {
    // Print a kitchen ticket (no price) without posting the sale.
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final kot = Sale(
      invoiceNo: '#KOT',
      epochMs: DateTime.now().millisecondsSinceEpoch,
      businessName: state.shopName,
      templateId: 'kot',
      lines: state.cart.map((l) => SaleLine(l.name, l.qty, l.price)).toList(),
      subtotal: state.subtotal,
      gst: state.gst,
      total: state.total,
      paymentMode: 'KOT',
    );
    try {
      await PdfService.printSale(kot);
      messenger.showSnackBar(SnackBar(content: Text(l.kotSent)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.kotPrintFail)));
    }
  }

  Future<void> _charge(BuildContext context, String mode) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (state.cart.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.addItemsFirst)));
      return;
    }
    Customer? customer;
    if (mode == 'Credit') {
      customer = state.selectedCustomer ?? await pickCustomer(context, state);
      if (customer == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.creditNeedsCustomer)));
        return;
      }
      if (state.overLimit(customer, state.total)) {
        if (!context.mounted) return;
        final proceed = await confirmDialog(context, title: l.creditLimitExceeded, message: l.creditLimitBody(customer.name, money(customer.creditLimit)), confirmLabel: l.overrideAction);
        if (!proceed) return;
      }
    }
    final sale = state.postSale(paymentMode: mode, nowMs: DateTime.now().millisecondsSinceEpoch, customer: customer);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${l.salePostedPrefix(sale.invoiceNo, mode, money(sale.total))}${customer != null ? ' · ${customer.name}' : ''} ✓'),
        action: SnackBarAction(label: l.share, onPressed: () => PdfService.shareSale(sale)),
      ),
    );
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(fontSize: 13, color: bx.muted)),
        Text(v, style: TextStyle(fontSize: 13, color: bx.muted)),
      ],
    ),
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
    final l = L.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${money(line.price)} · ${line.unit}', style: TextStyle(fontSize: 11, color: bx.muted)),
              ],
            ),
          ),
          _stepBtn(bx, l, Icons.remove, () => state.dec(index)),
          InkWell(
            onTap: () => _editQty(context),
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text(
                  qtyLabel(line.qty),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          _stepBtn(bx, l, Icons.add, () => state.inc(index)),
          SizedBox(
            width: 66,
            child: Text(
              money(line.net),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  /// Tap-to-edit exact quantity — lets a grocer bill 0.5 kg of loose goods.
  Future<void> _editQty(BuildContext context) async {
    final l = L.of(context);
    final c = TextEditingController(text: qtyLabel(line.qty));
    try {
      final v = await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.quantityOf(line.name)),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(suffixText: line.unit, border: const OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, double.tryParse(c.text.trim())), child: Text(l.setLabel)),
          ],
        ),
      );
      if (v != null) state.setQty(index, v);
    } finally {
      c.dispose();
    }
  }

  Widget _stepBtn(BxColors bx, L l, IconData ic, VoidCallback onTap) => Semantics(
    button: true,
    label: ic == Icons.add ? l.increaseQty : l.decreaseQty,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bx.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bx.border),
            ),
            child: Icon(ic, size: 16),
          ),
        ),
      ),
    ),
  );
}

class _CustomerChip extends StatelessWidget {
  final AppState state;
  const _CustomerChip({required this.state});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
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
        child: Row(
          children: [
            Icon(c != null ? Icons.person : Icons.person_outline, size: 18, color: c != null ? bx.brand : bx.muted),
            const SizedBox(width: 8),
            Expanded(
              child: c == null
                  ? Text(l.walkInCustomer, style: TextStyle(fontSize: 13, color: bx.muted))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        if (state.balanceOf(c.id) > 0)
                          Text(
                            l.outstandingSuffix(money(state.balanceOf(c.id))),
                            style: TextStyle(fontSize: 11, color: bx.danger, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
            ),
            if (c != null)
              InkWell(
                onTap: () => state.selectCustomer(null),
                borderRadius: BorderRadius.circular(22),
                child: Semantics(
                  button: true,
                  label: l.removeCustomer,
                  child: SizedBox(width: 44, height: 44, child: Icon(Icons.close, size: 18, color: bx.muted)),
                ),
              )
            else
              Icon(Icons.chevron_right, size: 18, color: bx.faint),
          ],
        ),
      ),
    );
  }
}

/// Controlled bill-discount input — stays in sync with `state.billDiscount`
/// so it clears to blank after a sale posts (was an uncontrolled field that
/// retained stale text and desynced from the actual discount).
class _BillDiscountField extends StatefulWidget {
  final AppState state;
  const _BillDiscountField({required this.state});
  @override
  State<_BillDiscountField> createState() => _BillDiscountFieldState();
}

class _BillDiscountFieldState extends State<_BillDiscountField> {
  late final TextEditingController _c;

  String _fmt(double v) => v <= 0 ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _fmt(widget.state.billDiscount));
  }

  @override
  void didUpdateWidget(_BillDiscountField old) {
    super.didUpdateWidget(old);
    // Sync only on external changes (e.g. reset to 0 after posting); never
    // clobber the value the user is actively typing.
    final external = widget.state.billDiscount;
    if ((double.tryParse(_c.text.trim()) ?? 0) != external) {
      _c.text = _fmt(external);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(prefixText: '₹ ', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
      onChanged: (v) => widget.state.setBillDiscount(double.tryParse(v) ?? 0),
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
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? bx.brand.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? bx.brand : bx.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: on ? bx.brand : bx.muted),
        ),
      ),
    );
  }
}
