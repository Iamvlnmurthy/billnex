import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
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
                Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('No items', style: TextStyle(color: bx.muted)))))
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
            Text(it.qty.toStringAsFixed(it.qty % 1 == 0 ? 0 : 1), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: qtyColor)),
            Text(it.unit, style: TextStyle(fontSize: 11, color: bx.faint)),
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
    final qty = TextEditingController(text: '0');
    final reorder = TextEditingController(text: '10');
    final barcode = TextEditingController();
    double gst = 5;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('New product', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(controller: name, autofocus: true, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Price', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening qty', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder level', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: barcode, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Barcode', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Add to catalogue')),
          ]),
        ),
      )),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      widget.state.addStockItem(
        name: name.text,
        unit: unit.text.trim().isEmpty ? 'Piece' : unit.text.trim(),
        price: double.tryParse(price.text) ?? 0,
        cost: (double.tryParse(price.text) ?? 0) * 0.78,
        qty: double.tryParse(qty.text) ?? 0,
        reorder: double.tryParse(reorder.text) ?? 10,
        gstRate: gst,
        barcode: barcode.text.trim().isEmpty ? null : barcode.text.trim(),
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${name.text} added')));
    }
  }
}

/// GST-rate dropdown (0/5/12/18/28%).
class _GstDropdown extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _GstDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<double>(
        initialValue: value,
        decoration: const InputDecoration(labelText: 'GST %', border: OutlineInputBorder()),
        items: const <double>[0, 5, 12, 18, 28].map((r) => DropdownMenuItem<double>(value: r, child: Text('${r.toStringAsFixed(0)}%'))).toList(),
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
        final it = state.stockItems.firstWhere((x) => x.sku == sku);
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
                    Text(it.qty.toStringAsFixed(it.qty % 1 == 0 ? 0 : 1), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: qtyColor)),
                    const SizedBox(width: 6),
                    Text(it.unit, style: TextStyle(fontSize: 14, color: bx.muted)),
                    const Spacer(),
                    Text('${money(it.price)} / ${it.unit}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Reorder at ${it.reorderLevel.toStringAsFixed(0)} · cost ${money(it.cost)}', style: TextStyle(fontSize: 13, color: bx.muted)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _adjust(context, it, false), icon: const Icon(Icons.remove, size: 18), label: const Text('Reduce'))),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton.icon(onPressed: () => _adjust(context, it, true), icon: const Icon(Icons.add, size: 18), label: const Text('Add stock'))),
                  ]),
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
        Text('${positive ? '+' : ''}${m.delta.toStringAsFixed(m.delta % 1 == 0 ? 0 : 1)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: positive ? bx.pos : bx.danger)),
      ]),
    );
  }

  Future<void> _editProduct(BuildContext context, StockItem it) async {
    final name = TextEditingController(text: it.name);
    final unit = TextEditingController(text: it.unit);
    final price = TextEditingController(text: it.price.toStringAsFixed(it.price % 1 == 0 ? 0 : 2));
    final cost = TextEditingController(text: it.cost.toStringAsFixed(it.cost % 1 == 0 ? 0 : 2));
    final reorder = TextEditingController(text: it.reorderLevel.toStringAsFixed(0));
    final barcode = TextEditingController(text: it.barcode ?? '');
    double gst = it.gstRate;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Edit product', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Sell price', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: cost, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Cost', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: barcode, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Barcode', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Save changes')),
          ]),
        ),
      )),
    );
    if (ok == true) {
      state.editStockItem(it.sku,
          name: name.text, unit: unit.text,
          price: double.tryParse(price.text) ?? it.price,
          cost: double.tryParse(cost.text) ?? it.cost,
          reorder: double.tryParse(reorder.text) ?? it.reorderLevel,
          gstRate: gst, barcode: barcode.text,
          nowMs: DateTime.now().millisecondsSinceEpoch);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated ✓')));
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
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(add ? 'Add stock · ${it.name}' : 'Reduce stock · ${it.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(controller: qty, autofocus: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Quantity (${it.unit})', border: const OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: reason, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Record adjustment')),
        ]),
      ),
    );
    if (ok == true) {
      final q = double.tryParse(qty.text) ?? 0;
      if (q > 0) {
        state.adjustStock(
          sku: it.sku,
          delta: add ? q : -q,
          reason: reason.text.trim(),
          kind: add ? MoveKind.purchase : MoveKind.damage,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock ${add ? 'added' : 'reduced'} ✓')));
      }
    }
  }
}
