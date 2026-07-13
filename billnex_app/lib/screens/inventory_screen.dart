import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../state/app_state.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import 'customers_screen.dart' show StatusChip;

class InventoryScreen extends StatefulWidget {
  final AppState state;
  const InventoryScreen({required this.state, super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _q = '';
  bool _lowOnly = false;

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final state = widget.state;
    var items = state.stockItems;
    if (_lowOnly) items = items.where((i) => i.low).toList();
    if (_q.isNotEmpty) items = items.where((i) => i.name.toLowerCase().contains(_q.toLowerCase())).toList();
    final stockValue = state.stockItems.fold<double>(0, (a, i) => a + i.qty * i.cost);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              PageHeader('Inventory & Stock',
                  '${state.stockItems.length} SKUs · ${state.lowStockCount} low · ${money(stockValue)} at cost.',
                  trailing: const Badge2('Live stock ledger')),
              Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: bx.border)),
                    child: TextField(
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Padding(padding: const EdgeInsets.only(left: 14), child: Icon(Icons.search, color: bx.muted)),
                        hintText: 'Search item…',
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  selected: _lowOnly,
                  onSelected: (v) => setState(() => _lowOnly = v),
                  avatar: Icon(Icons.warning_amber_rounded, size: 16, color: _lowOnly ? bx.onAccent : bx.warn),
                  label: Text('Low (${state.lowStockCount})'),
                  showCheckmark: false,
                ),
              ]),
              const SizedBox(height: 14),
              if (items.isEmpty)
                Card(child: EmptyState(
                  illustration: 'empty-no-products',
                  title: state.stockItems.isEmpty ? 'No products yet' : 'No matches',
                  subtitle: state.stockItems.isEmpty ? 'Tap "Add product" to build your catalogue.' : 'Try a different search.',
                ))
              else
                Card(child: Column(children: [for (int i = 0; i < items.length; i++) _row(context, items[i], i == 0)])),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, StockItem it, bool first) {
    final bx = context.bx;
    final qtyColor = it.out ? bx.danger : (it.low ? bx.warn : bx.pos);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailScreen(state: widget.state, sku: it.sku))),
      child: Container(
        decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.inventory_2_outlined, size: 19, color: bx.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(it.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                if (it.out) ...[const SizedBox(width: 6), StatusChip('OUT', bx.danger, bx.dangerBg)]
                else if (it.low) ...[const SizedBox(width: 6), StatusChip('LOW', bx.warn, bx.warnBg)],
                if (it.batches.isNotEmpty) ...[const SizedBox(width: 6), Icon(Icons.event_outlined, size: 13, color: bx.faint)],
              ]),
              const SizedBox(height: 2),
              Text('${money(it.price)} / ${it.unit} · reorder ${it.reorderLevel.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: bx.muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(it.stockTracked ? qtyLabel(it.qty) : '—', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: qtyColor)),
            Text(it.stockTracked ? it.unit : 'service', style: TextStyle(fontSize: 11, color: bx.faint)),
          ]),
          Icon(Icons.chevron_right, size: 20, color: bx.faint),
        ]),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final name = TextEditingController();
    final unit = TextEditingController(text: 'Piece');
    final price = TextEditingController();
    final cost = TextEditingController();
    final qty = TextEditingController(text: '0');
    final reorder = TextEditingController(text: '10');
    final barcode = TextEditingController();
    final category = TextEditingController();
    final hsn = TextEditingController();
    final formKey = GlobalKey<FormState>();
    double gst = 5;
    bool tracked = true;
    final messenger = ScaffoldMessenger.of(context);
    final state = widget.state;
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('New product', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Enter a product name';
                    if (state.productExists(t)) return 'A product with this name already exists';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Sell price', border: OutlineInputBorder()),
                    validator: (v) {
                      final p = double.tryParse((v ?? '').trim());
                      if (p == null || p <= 0) return 'Enter a price > 0';
                      return null;
                    },
                  )),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    controller: cost,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Cost (optional)', border: OutlineInputBorder()),
                  )),
                ]),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Track stock'),
                  subtitle: const Text('Off for services (salon, repair)'),
                  value: tracked,
                  onChanged: (v) => setSt(() => tracked = v),
                ),
                if (tracked) ...[
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: qty,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Opening qty', border: OutlineInputBorder()),
                      validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) < 0 ? '≥ 0' : null,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(
                      controller: reorder,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Reorder level', border: OutlineInputBorder()),
                      validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) < 0 ? '≥ 0' : null,
                    )),
                  ]),
                  const SizedBox(height: 10),
                ],
                Row(children: [
                  Expanded(child: TextFormField(controller: category, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: hsn, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HSN/SAC', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: barcode,
                  decoration: const InputDecoration(labelText: 'Barcode (optional)', border: OutlineInputBorder()),
                  validator: (v) => state.barcodeInUse((v ?? '').trim()) ? 'Barcode already used by another product' : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Add to catalogue'),
                ),
              ]),
            ),
          ),
        )),
      );
      if (ok == true) {
        final sell = double.tryParse(price.text.trim()) ?? 0;
        final added = state.addStockItem(
          name: name.text,
          unit: unit.text.trim().isEmpty ? 'Piece' : unit.text.trim(),
          price: sell,
          cost: double.tryParse(cost.text.trim()) ?? 0,
          qty: tracked ? (double.tryParse(qty.text.trim()) ?? 0) : 0,
          reorder: double.tryParse(reorder.text.trim()) ?? 10,
          gstRate: gst,
          barcode: barcode.text.trim().isEmpty ? null : barcode.text.trim(),
          category: category.text.trim().isEmpty ? null : category.text.trim(),
          hsn: hsn.text.trim().isEmpty ? null : hsn.text.trim(),
          stockTracked: tracked,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
        messenger.showSnackBar(SnackBar(content: Text(added != null ? '${added.name} added ✓' : 'Could not add — name already exists')));
      }
    } finally {
      for (final c in [name, unit, price, cost, qty, reorder, barcode, category, hsn]) {
        c.dispose();
      }
    }
  }
}

const _gstSlabs = <double>[0, 5, 12, 18, 28];

/// Snaps any rate to the nearest supported GST slab so an off-slab value
/// (e.g. a 3% imported item) can't crash the dropdown assertion.
double snapGst(double v) => _gstSlabs.reduce((a, b) => (v - a).abs() <= (v - b).abs() ? a : b);

/// GST-rate dropdown (0/5/12/18/28%).
class _GstDropdown extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _GstDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<double>(
        initialValue: snapGst(value),
        decoration: const InputDecoration(labelText: 'GST %', border: OutlineInputBorder()),
        items: _gstSlabs.map((r) => DropdownMenuItem<double>(value: r, child: Text('${r.toStringAsFixed(0)}%'))).toList(),
        onChanged: (v) => onChanged(v ?? 5),
      );
}

class StockDetailScreen extends StatelessWidget {
  final AppState state;
  final String sku;
  const StockDetailScreen({required this.state, required this.sku, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final it = state.stockItems.where((x) => x.sku == sku).firstOrNull;
        if (it == null) {
          // Product was just deleted — the pop is in flight; render a safe frame.
          return const Scaffold(body: SizedBox.shrink());
        }
        final moves = state.movementsFor(sku);
        final now = DateTime.now().millisecondsSinceEpoch;
        final qtyColor = it.out ? bx.danger : (it.low ? bx.warn : bx.pos);
        return Scaffold(
          appBar: AppBar(
            title: Text(it.name),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              IconButton(tooltip: 'Edit product', onPressed: () => _editProduct(context, it), icon: const Icon(Icons.edit_outlined)),
              IconButton(tooltip: 'Delete product', onPressed: () => _deleteProduct(context, it), icon: const Icon(Icons.delete_outline)),
            ],
          ),
          body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ON HAND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint)),
                  const SizedBox(height: 6),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(it.stockTracked ? qtyLabel(it.qty) : '—', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: qtyColor)),
                    const SizedBox(width: 6),
                    Text(it.unit, style: TextStyle(fontSize: 14, color: bx.muted)),
                    const Spacer(),
                    Text('${money(it.price)} / ${it.unit}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Reorder at ${it.reorderLevel.toStringAsFixed(0)} · cost ${money(it.cost)}', style: TextStyle(fontSize: 13, color: bx.muted)),
                  if (it.stockTracked) ...[
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => _adjust(context, it, false), icon: const Icon(Icons.remove, size: 18), label: const Text('Reduce'))),
                      const SizedBox(width: 10),
                      Expanded(child: FilledButton.icon(onPressed: () => _adjust(context, it, true), icon: const Icon(Icons.add, size: 18), label: const Text('Add stock'))),
                    ]),
                  ],
                ]),
              ),
            ),
            if (it.batches.isNotEmpty) ...[
              const SizedBox(height: 16),
              _label(bx, 'Batches'),
              Card(child: Column(children: [
                for (int i = 0; i < it.batches.length; i++)
                  Container(
                    decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: bx.border))),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Icon(Icons.event_outlined, size: 18, color: bx.muted),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Batch ${it.batches[i].batchNo}', style: const TextStyle(fontWeight: FontWeight.w600))),
                      if (it.batches[i].isExpired(now)) StatusChip('EXPIRED', bx.danger, bx.dangerBg)
                      else if (it.batches[i].isNearExpiry(now)) StatusChip('NEAR EXPIRY', bx.warn, bx.warnBg),
                      const SizedBox(width: 8),
                      Text('exp ${it.batches[i].expiryLabel}', style: TextStyle(fontSize: 12, color: bx.muted)),
                    ]),
                  ),
              ])),
            ],
            const SizedBox(height: 16),
            _label(bx, 'Movement history'),
            Card(child: Column(children: [
              for (int i = 0; i < moves.length; i++) _moveRow(context, moves[i], i == 0),
            ])),
          ]),
        );
      },
    );
  }

  Widget _label(BxColors bx, String s) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 8),
        child: Text(s.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint)),
      );

  Widget _moveRow(BuildContext context, StockMovement m, bool first) {
    final bx = context.bx;
    final positive = m.delta >= 0;
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        Icon(positive ? Icons.arrow_downward : Icons.arrow_upward, size: 17, color: positive ? bx.pos : bx.danger),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${m.kind.label}${m.reason != null ? ' · ${m.reason}' : ''}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            Text('${m.ref} · ${m.dateLabel}', style: TextStyle(fontSize: 11.5, color: bx.muted)),
          ]),
        ),
        Text('${positive ? '+' : '−'}${qtyLabel(m.delta.abs())}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: positive ? bx.pos : bx.danger)),
      ]),
    );
  }

  Future<void> _editProduct(BuildContext context, StockItem it) async {
    final name = TextEditingController(text: it.name);
    final unit = TextEditingController(text: it.unit);
    final price = TextEditingController(text: it.price.toStringAsFixed(it.price % 1 == 0 ? 0 : 2));
    final cost = TextEditingController(text: it.cost.toStringAsFixed(it.cost % 1 == 0 ? 0 : 2));
    final reorder = TextEditingController(text: qtyLabel(it.reorderLevel));
    final barcode = TextEditingController(text: it.barcode ?? '');
    final category = TextEditingController(text: it.category ?? '');
    final hsn = TextEditingController(text: it.hsn ?? '');
    final formKey = GlobalKey<FormState>();
    double gst = it.gstRate;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Edit product', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: reorder, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Reorder', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Sell price', border: OutlineInputBorder()),
                    validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) <= 0 ? '> 0' : null,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: cost, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Cost', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: hsn, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HSN/SAC', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: category, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    controller: barcode,
                    decoration: const InputDecoration(labelText: 'Barcode', border: OutlineInputBorder()),
                    validator: (v) => state.barcodeInUse((v ?? '').trim(), exceptSku: it.sku) ? 'Used by another product' : null,
                  )),
                ]),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save changes'),
                ),
              ]),
            ),
          ),
        )),
      );
      if (ok == true) {
        state.editStockItem(it.sku,
            name: name.text, unit: unit.text,
            price: double.tryParse(price.text) ?? it.price,
            cost: double.tryParse(cost.text) ?? it.cost,
            reorder: double.tryParse(reorder.text) ?? it.reorderLevel,
            gstRate: gst, barcode: barcode.text, category: category.text, hsn: hsn.text,
            nowMs: DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(const SnackBar(content: Text('Product updated ✓')));
      }
    } finally {
      for (final c in [name, unit, price, cost, reorder, barcode, category, hsn]) {
        c.dispose();
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context, StockItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove product?'),
        content: Text('Remove "${it.name}" from your catalogue? Past sales keep their records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: context.bx.danger), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      state.deleteStockItem(it.sku, nowMs: DateTime.now().millisecondsSinceEpoch);
      if (context.mounted) Navigator.of(context).pop(); // leave the detail page
    }
  }

  Future<void> _adjust(BuildContext context, StockItem it, bool add) async {
    final qty = TextEditingController();
    final reason = TextEditingController(text: add ? 'Purchase / restock' : 'Damage / correction');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(add ? 'Add stock · ${it.name}' : 'Reduce stock · ${it.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            if (!add) Padding(padding: const EdgeInsets.only(top: 4), child: Text('On hand: ${qtyLabel(it.qty)} ${it.unit}', style: TextStyle(fontSize: 12.5, color: context.bx.muted))),
            const SizedBox(height: 12),
            TextField(controller: qty, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Quantity (${it.unit})', border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: reason, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Record adjustment')),
          ]),
        ),
      );
      if (ok == true) {
        var q = double.tryParse(qty.text.trim()) ?? 0;
        if (q <= 0) {
          messenger.showSnackBar(const SnackBar(content: Text('Enter a quantity greater than 0')));
          return;
        }
        if (!add && q > it.qty) q = it.qty; // can't reduce below on-hand
        state.adjustStock(
          sku: it.sku,
          delta: add ? q : -q,
          reason: reason.text.trim(),
          kind: add ? MoveKind.purchase : MoveKind.damage,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
        messenger.showSnackBar(SnackBar(content: Text('Stock ${add ? 'added' : 'reduced'} ✓')));
      }
    } finally {
      qty.dispose();
      reason.dispose();
    }
  }
}
