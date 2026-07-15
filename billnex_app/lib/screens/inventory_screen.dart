import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../state/app_state.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../l10n/app_localizations.dart';
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
  String? _selectedSku;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _addProduct(context), icon: const Icon(Icons.add), label: Text(l.addProductBtn)),
      body: LayoutBuilder(builder: (context, c) => c.maxWidth >= 720 ? _wide(context) : _narrow(context)),
    );
  }

  // Filtered items honoring search + low-only.
  List<StockItem> _items() {
    var items = widget.state.stockItems;
    if (_lowOnly) items = items.where((i) => i.low).toList();
    if (_q.isNotEmpty) items = items.where((i) => i.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return items;
  }

  // ── Phone: unchanged single-column list, taps push the detail screen. ──
  Widget _narrow(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
    children: [ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: _masterColumn(context, wide: false))],
  );

  // ── Tablet: master list + live detail pane. ──
  Widget _wide(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final selected = _selectedSku != null && widget.state.stockItems.any((x) => x.sku == _selectedSku);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 16, 100), children: [_masterColumn(context, wide: true)]),
            ),
            Container(width: 1, color: bx.border),
            Expanded(
              child: selected
                  ? StockDetailView(state: widget.state, sku: _selectedSku!, embedded: true, onDeleted: () => setState(() => _selectedSku = null))
                  : Center(
                      child: EmptyState(illustration: 'empty-no-products', title: l.selectItemTitle, subtitle: l.selectItemSub),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _masterColumn(BuildContext context, {required bool wide}) {
    final bx = context.bx;
    final l = L.of(context);
    final state = widget.state;
    final items = _items();
    final stockValue = state.stockItems.fold<double>(0, (a, i) => a + i.qty * i.cost);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(l.invTitle, l.invSubtitle(state.stockItems.length, state.lowStockCount, money(stockValue)), trailing: wide ? null : Badge2(l.liveStockLedger)),
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
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Icon(Icons.search, color: bx.muted),
                    ),
                    hintText: l.searchItem,
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
              label: Text(l.lowFilter(state.lowStockCount)),
              showCheckmark: false,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Card(
            child: EmptyState(
              illustration: 'empty-no-products',
              title: state.stockItems.isEmpty ? l.noProductsTitle : l.noMatchesTitle,
              subtitle: state.stockItems.isEmpty ? l.noProductsSub : l.noMatchesSub,
            ),
          )
        else
          Card(
            child: Column(children: [for (int i = 0; i < items.length; i++) _row(context, items[i], i == 0, wide: wide)]),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, StockItem it, bool first, {required bool wide}) {
    final bx = context.bx;
    final l = L.of(context);
    final qtyColor = it.out ? bx.danger : (it.low ? bx.warn : bx.pos);
    final isSelected = wide && it.sku == _selectedSku;
    return InkWell(
      onTap: () => wide
          ? setState(() => _selectedSku = it.sku)
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StockDetailScreen(state: widget.state, sku: it.sku),
              ),
            ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? bx.brand.withValues(alpha: 0.08) : null,
          border: Border(
            top: first ? BorderSide.none : BorderSide(color: bx.border),
            left: isSelected ? BorderSide(color: bx.brand, width: 3) : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.inventory_2_outlined, size: 19, color: bx.brand),
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
                          it.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (it.out) ...[
                        const SizedBox(width: 6),
                        StatusChip(l.chipOut, bx.danger, bx.dangerBg),
                      ] else if (it.low) ...[
                        const SizedBox(width: 6),
                        StatusChip(l.chipLow, bx.warn, bx.warnBg),
                      ],
                      if (it.batches.isNotEmpty) ...[const SizedBox(width: 6), Icon(Icons.event_outlined, size: 13, color: bx.faint)],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(l.pricePerUnitReorder(money(it.price), it.unit, it.reorderLevel.toStringAsFixed(0)), style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  it.stockTracked ? qtyLabel(it.qty) : '—',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: qtyColor),
                ),
                Text(it.stockTracked ? it.unit : l.service, style: TextStyle(fontSize: 11, color: bx.faint)),
              ],
            ),
            Icon(Icons.chevron_right, size: 20, color: bx.faint),
          ],
        ),
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
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final state = widget.state;
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSt) => Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640), // keep the sheet readable on tablets
                  child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.newProduct, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l.fieldName, border: const OutlineInputBorder()),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return l.enterProductName;
                        if (state.productExists(t)) return l.productExistsErr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: unit,
                            decoration: InputDecoration(labelText: l.fieldUnit, border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: price,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(prefixText: '₹ ', labelText: l.sellPrice, border: const OutlineInputBorder()),
                            validator: (v) {
                              final p = double.tryParse((v ?? '').trim());
                              if (p == null || p <= 0) return l.enterPriceGt0;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: cost,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(prefixText: '₹ ', labelText: l.costOptional, border: const OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l.trackStock), subtitle: Text(l.trackStockSub), value: tracked, onChanged: (v) => setSt(() => tracked = v)),
                    if (tracked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: qty,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: l.openingQty, border: const OutlineInputBorder()),
                              validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) < 0 ? l.geZero : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: reorder,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: l.reorderLevel, border: const OutlineInputBorder()),
                              validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) < 0 ? l.geZero : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: category,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(labelText: l.fieldCategory, border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: hsn,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: l.hsnSac, border: const OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: barcode,
                      decoration: InputDecoration(labelText: l.barcodeOptional, border: const OutlineInputBorder()),
                      validator: (v) => state.barcodeInUse((v ?? '').trim()) ? l.barcodeUsedErr : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                      },
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(l.addToCatalogue),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
        messenger.showSnackBar(SnackBar(content: Text(added != null ? l.addedSnack(added.name) : l.addFailExists)));
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
    decoration: InputDecoration(labelText: L.of(context).gstPct, border: const OutlineInputBorder()),
    items: _gstSlabs.map((r) => DropdownMenuItem<double>(value: r, child: Text('${r.toStringAsFixed(0)}%'))).toList(),
    onChanged: (v) => onChanged(v ?? 5),
  );
}

/// Pushed detail screen for phones — Scaffold + AppBar wrapping [StockDetailView].
class StockDetailScreen extends StatelessWidget {
  final AppState state;
  final String sku;
  const StockDetailScreen({required this.state, required this.sku, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final it = state.stockItems.where((x) => x.sku == sku).firstOrNull;
        if (it == null) {
          // Product was just deleted — the pop is in flight; render a safe frame.
          return const Scaffold(body: SizedBox.shrink());
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(it.name),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              IconButton(tooltip: l.editProductTooltip, onPressed: () => _editStock(context, state, it), icon: const Icon(Icons.edit_outlined)),
              IconButton(
                tooltip: l.deleteProductTooltip,
                onPressed: () => _deleteStock(context, state, it, onDeleted: () => Navigator.of(context).pop()),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: StockDetailView(state: state, sku: sku),
        );
      },
    );
  }
}

/// Body content for a stock item — used both inside [StockDetailScreen] (phone)
/// and embedded in the tablet master-detail pane. When [embedded] it renders its
/// own header with edit/delete actions; [onDeleted] fires after a delete so the
/// pane can clear its selection instead of popping a route.
class StockDetailView extends StatelessWidget {
  final AppState state;
  final String sku;
  final bool embedded;
  final VoidCallback? onDeleted;
  const StockDetailView({required this.state, required this.sku, this.embedded = false, this.onDeleted, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final it = state.stockItems.where((x) => x.sku == sku).firstOrNull;
        if (it == null) return const SizedBox.shrink();
        final moves = state.movementsFor(sku);
        final now = DateTime.now().millisecondsSinceEpoch;
        final qtyColor = it.out ? bx.danger : (it.low ? bx.warn : bx.pos);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            if (embedded) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      it.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(tooltip: l.editProductTooltip, onPressed: () => _editStock(context, state, it), icon: const Icon(Icons.edit_outlined)),
                  IconButton(
                    tooltip: l.deleteProductTooltip,
                    onPressed: () => _deleteStock(context, state, it, onDeleted: onDeleted),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.onHand,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          it.stockTracked ? qtyLabel(it.qty) : '—',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: qtyColor),
                        ),
                        const SizedBox(width: 6),
                        Text(it.unit, style: TextStyle(fontSize: 14, color: bx.muted)),
                        const Spacer(),
                        Text('${money(it.price)} / ${it.unit}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(l.reorderAtCost(it.reorderLevel.toStringAsFixed(0), money(it.cost)), style: TextStyle(fontSize: 13, color: bx.muted)),
                    if (it.stockTracked) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(onPressed: () => _adjustStock(context, state, it, false), icon: const Icon(Icons.remove, size: 18), label: Text(l.reduce)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(onPressed: () => _adjustStock(context, state, it, true), icon: const Icon(Icons.add, size: 18), label: Text(l.addStock)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (it.batches.isNotEmpty) ...[
              const SizedBox(height: 16),
              _label(bx, l.batches),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < it.batches.length; i++)
                      Container(
                        decoration: BoxDecoration(
                          border: i == 0 ? null : Border(top: BorderSide(color: bx.border)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.event_outlined, size: 18, color: bx.muted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(l.batchNo(it.batches[i].batchNo), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            if (it.batches[i].isExpired(now))
                              StatusChip(l.chipExpired, bx.danger, bx.dangerBg)
                            else if (it.batches[i].isNearExpiry(now))
                              StatusChip(l.chipNearExpiry, bx.warn, bx.warnBg),
                            const SizedBox(width: 8),
                            Text(l.expLabel(it.batches[i].expiryLabel), style: TextStyle(fontSize: 12, color: bx.muted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _label(bx, l.movementHistory),
            Card(child: Column(children: [for (int i = 0; i < moves.length; i++) _moveRow(context, moves[i], i == 0)])),
          ],
        );
      },
    );
  }

  Widget _label(BxColors bx, String s) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 8),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
    ),
  );

  Widget _moveRow(BuildContext context, StockMovement m, bool first) {
    final bx = context.bx;
    final positive = m.delta >= 0;
    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(positive ? Icons.arrow_downward : Icons.arrow_upward, size: 17, color: positive ? bx.pos : bx.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.kind.label}${m.reason != null ? ' · ${m.reason}' : ''}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                Text('${m.ref} · ${m.dateLabel}', style: TextStyle(fontSize: 11.5, color: bx.muted)),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : '−'}${qtyLabel(m.delta.abs())}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: positive ? bx.pos : bx.danger),
          ),
        ],
      ),
    );
  }
}

Future<void> _editStock(BuildContext context, AppState state, StockItem it) async {
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
  final l = L.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640), // keep the sheet readable on tablets
                child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.editProduct, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(labelText: l.fieldName, border: const OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().isEmpty ? l.enterName : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: unit,
                          decoration: InputDecoration(labelText: l.fieldUnit, border: const OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: reorder,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: l.fieldReorder, border: const OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: price,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(prefixText: '₹ ', labelText: l.sellPrice, border: const OutlineInputBorder()),
                          validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) <= 0 ? l.gtZeroShort : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: cost,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(prefixText: '₹ ', labelText: l.fieldCost, border: const OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _GstDropdown(value: gst, onChanged: (v) => setSt(() => gst = v)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: hsn,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l.hsnSac, border: const OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: category,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(labelText: l.fieldCategory, border: const OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: barcode,
                          decoration: InputDecoration(labelText: l.barcodeOptional, border: const OutlineInputBorder()),
                          validator: (v) => state.barcodeInUse((v ?? '').trim(), exceptSku: it.sku) ? l.usedByAnother : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(l.saveChanges),
                  ),
                ],
              ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      state.editStockItem(
        it.sku,
        name: name.text,
        unit: unit.text,
        price: double.tryParse(price.text.trim()) ?? it.price,
        cost: double.tryParse(cost.text.trim()) ?? it.cost,
        reorder: double.tryParse(reorder.text.trim()) ?? it.reorderLevel,
        gstRate: gst,
        barcode: barcode.text,
        category: category.text,
        hsn: hsn.text,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );
      messenger.showSnackBar(SnackBar(content: Text(l.productUpdated)));
    }
  } finally {
    for (final c in [name, unit, price, cost, reorder, barcode, category, hsn]) {
      c.dispose();
    }
  }
}

Future<void> _deleteStock(BuildContext context, AppState state, StockItem it, {VoidCallback? onDeleted}) async {
  final l = L.of(context);
  final ok = await confirmDialog(context, title: l.removeProductTitle, message: l.removeProductBody(it.name), confirmLabel: l.removeAction, destructive: true);
  if (ok && context.mounted) {
    state.deleteStockItem(it.sku, nowMs: DateTime.now().millisecondsSinceEpoch);
    onDeleted?.call(); // phone pops the route; embedded pane clears its selection
  }
}

Future<void> _adjustStock(BuildContext context, AppState state, StockItem it, bool add) async {
  final l = L.of(context);
  final qty = TextEditingController();
  final reason = TextEditingController(text: add ? l.purchaseRestock : l.damageCorrection);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(add ? l.addStockTitle(it.name) : l.reduceStockTitle(it.name), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (!add)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.onHandLabel(qtyLabel(it.qty), it.unit), style: TextStyle(fontSize: 12.5, color: context.bx.muted)),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: qty,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.quantityUnit(it.unit), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reason,
              decoration: InputDecoration(labelText: l.reasonField, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(l.recordAdjustment),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      var q = double.tryParse(qty.text.trim()) ?? 0;
      if (q <= 0) {
        messenger.showSnackBar(SnackBar(content: Text(l.enterQtyGt0)));
        return;
      }
      if (!add && q > it.qty) q = it.qty; // can't reduce below on-hand
      state.adjustStock(sku: it.sku, delta: add ? q : -q, reason: reason.text.trim(), kind: add ? MoveKind.purchase : MoveKind.damage, nowMs: DateTime.now().millisecondsSinceEpoch);
      messenger.showSnackBar(SnackBar(content: Text(add ? l.stockAdded : l.stockReduced)));
    }
  } finally {
    qty.dispose();
    reason.dispose();
  }
}
