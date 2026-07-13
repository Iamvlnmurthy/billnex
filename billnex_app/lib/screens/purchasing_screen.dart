import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../models/stock.dart';
import '../state/app_state.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'customers_screen.dart' show StatusChip;

class PurchasingScreen extends StatelessWidget {
  final AppState state;
  const PurchasingScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final suppliers = [...state.suppliers]..sort((a, b) => state.payableOf(b.id).compareTo(state.payableOf(a.id)));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _newPurchase(context), icon: const Icon(Icons.add_shopping_cart), label: const Text('New purchase')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  'Purchasing & Suppliers',
                  '${suppliers.length} suppliers · ${money(state.totalPayable)} payable · ${state.purchases.length} purchases.',
                  trailing: OutlinedButton.icon(onPressed: () => _addSupplier(context), icon: const Icon(Icons.person_add_alt, size: 18), label: const Text('Supplier')),
                ),
                if (suppliers.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 44),
                      child: Column(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 40, color: bx.faint),
                          const SizedBox(height: 12),
                          Text(
                            'No suppliers yet',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bx.muted),
                          ),
                          const SizedBox(height: 4),
                          Text('Add a supplier, then record a purchase to stock-in.', style: TextStyle(fontSize: 13, color: bx.faint)),
                        ],
                      ),
                    ),
                  )
                else
                  Card(child: Column(children: [for (int i = 0; i < suppliers.length; i++) _row(context, suppliers[i], i == 0)])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Supplier s, bool first) {
    final bx = context.bx;
    final pay = state.payableOf(s.id);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SupplierDetailScreen(state: state, supplierId: s.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: first ? null : Border(top: BorderSide(color: bx.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: bx.brand.withValues(alpha: 0.12),
              child: Text(
                s.name.characters.first.toUpperCase(),
                style: TextStyle(color: bx.brand, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(s.phone.isEmpty ? (s.gstin ?? 'No contact') : s.phone, style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pay > 0 ? money(pay) : 'Settled',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: pay > 0 ? bx.warn : bx.pos),
                ),
                Text(pay > 0 ? 'payable' : 'no dues', style: TextStyle(fontSize: 11, color: bx.faint)),
              ],
            ),
            Icon(Icons.chevron_right, size: 20, color: bx.faint),
          ],
        ),
      ),
    );
  }

  Future<Supplier?> _addSupplier(BuildContext context) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final gstin = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New supplier', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: gstin,
                  decoration: const InputDecoration(labelText: 'GSTIN (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save supplier'),
                ),
              ],
            ),
          ),
        ),
      );
      if (ok == true && name.text.trim().isNotEmpty) {
        return state.addSupplier(name: name.text, phone: phone.text, gstin: gstin.text, nowMs: DateTime.now().millisecondsSinceEpoch);
      }
      return null;
    } finally {
      name.dispose();
      phone.dispose();
      gstin.dispose();
    }
  }

  Future<void> _newPurchase(BuildContext context) async {
    final Supplier? supplier = state.suppliers.isNotEmpty ? state.suppliers.first : await _addSupplier(context);
    if (supplier == null || !context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PurchaseSheet(state: state, initialSupplier: supplier, onAddSupplier: () => _addSupplier(ctx)),
    );
  }
}

class _PurchaseSheet extends StatefulWidget {
  final AppState state;
  final Supplier initialSupplier;
  final Future<Supplier?> Function() onAddSupplier;
  const _PurchaseSheet({required this.state, required this.initialSupplier, required this.onAddSupplier});
  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  late Supplier _supplier = widget.initialSupplier;
  final _ref = TextEditingController();
  bool _paid = false;
  final List<PurchaseLine> _lines = [];

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  double get _total => widget.state.purchaseTotal(_lines);

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final dup = widget.state.isDuplicatePurchase(_supplier.id, _ref.text);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Record purchase', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            // supplier
            InkWell(
              onTap: () async {
                final s = await _pickSupplier(context);
                if (s != null) setState(() => _supplier = s);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder(), suffixIcon: Icon(Icons.expand_more)),
                child: Text(_supplier.name),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ref,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: "Supplier invoice no.", border: const OutlineInputBorder(), errorText: dup ? 'Duplicate invoice for this supplier' : null),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(onPressed: _addLine, icon: const Icon(Icons.add, size: 18), label: const Text('Add item')),
              ],
            ),
            for (int i = 0; i < _lines.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _lines[i].sku,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${qtyLabel(_lines[i].qty)} × ${money(_lines[i].rate)}', style: TextStyle(color: bx.muted, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(money(_lines[i].amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      tooltip: 'Remove item',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _lines.removeAt(i)),
                      icon: Icon(Icons.close, size: 16, color: bx.faint),
                    ),
                  ],
                ),
              ),
            if (_lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No items yet', style: TextStyle(color: bx.faint)),
              ),
            const Divider(),
            Row(
              children: [
                const Text('Total (incl. GST)', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(money(_total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _paid,
              onChanged: (v) => setState(() => _paid = v),
              title: const Text('Paid now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(_paid ? 'No payable created' : 'Adds to supplier payable', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: (_lines.isEmpty || dup) ? null : _record,
              icon: const Icon(Icons.check, size: 18),
              label: Text(dup ? 'Duplicate invoice — change the ref' : 'Record purchase & stock-in'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Future<Supplier?> _pickSupplier(BuildContext context) => showModalBottomSheet<Supplier>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in widget.state.suppliers) ListTile(title: Text(s.name), subtitle: Text('${money(widget.state.payableOf(s.id))} payable'), onTap: () => Navigator.pop(ctx, s)),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text('New supplier'),
            onTap: () async {
              final s = await widget.onAddSupplier();
              if (ctx.mounted) Navigator.pop(ctx, s);
            },
          ),
        ],
      ),
    ),
  );

  Future<void> _addLine() async {
    final items = widget.state.stockItems;
    final picked = await showModalBottomSheet<StockItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: ListView(
            children: [for (final it in items) ListTile(title: Text(it.name), subtitle: Text('on hand ${qtyLabel(it.qty)} · cost ${money(it.cost)}'), onTap: () => Navigator.pop(ctx, it))],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final qty = TextEditingController(text: '10');
    final rate = TextEditingController(text: qtyLabel(picked.cost));
    final formKey = GlobalKey<FormState>();
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(picked.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: qty,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Qty (${picked.unit})', border: const OutlineInputBorder()),
                        validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) <= 0 ? '> 0' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: rate,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Rate', border: OutlineInputBorder()),
                        validator: (v) => (double.tryParse((v ?? '').trim()) ?? -1) < 0 ? '≥ 0' : null,
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
                  child: const Text('Add line'),
                ),
              ],
            ),
          ),
        ),
      );
      if (ok == true) {
        setState(() => _lines.add(PurchaseLine(picked.sku, double.tryParse(qty.text.trim()) ?? 0, double.tryParse(rate.text.trim()) ?? 0)));
      }
    } finally {
      qty.dispose();
      rate.dispose();
    }
  }

  void _record() {
    final messenger = ScaffoldMessenger.of(context);
    final count = _lines.length;
    widget.state.recordPurchase(supplier: _supplier, lines: _lines, supplierRef: _ref.text, paid: _paid, nowMs: DateTime.now().millisecondsSinceEpoch);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('Purchase recorded · $count items stocked-in ✓')));
  }
}

class SupplierDetailScreen extends StatelessWidget {
  final AppState state;
  final String supplierId;
  const SupplierDetailScreen({required this.state, required this.supplierId, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final s = state.suppliers.where((x) => x.id == supplierId).firstOrNull;
        if (s == null) return const Scaffold(body: SizedBox.shrink());
        final pay = state.payableOf(s.id);
        final purchases = state.purchasesFor(s.id);
        return Scaffold(
          appBar: AppBar(title: Text(s.name), backgroundColor: Theme.of(context).colorScheme.surface),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYABLE BALANCE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        money(pay),
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: pay > 0 ? bx.warn : bx.pos),
                      ),
                      if (s.phone.isNotEmpty) ...[const SizedBox(height: 4), Text(s.phone, style: TextStyle(fontSize: 13, color: bx.muted))],
                      const SizedBox(height: 14),
                      FilledButton.icon(onPressed: pay <= 0 ? null : () => _pay(context, s, pay), icon: const Icon(Icons.payments_outlined, size: 18), label: const Text('Pay supplier')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  'PURCHASES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                ),
              ),
              if (purchases.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text('No purchases', style: TextStyle(color: bx.muted)),
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (int i = 0; i < purchases.length; i++)
                        Container(
                          decoration: BoxDecoration(
                            border: i == 0 ? null : Border(top: BorderSide(color: bx.border)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(purchases[i].purchaseNo, style: const TextStyle(fontWeight: FontWeight.w800)),
                                        const SizedBox(width: 8),
                                        purchases[i].paid ? StatusChip('PAID', bx.pos, bx.posBg) : StatusChip('CREDIT', bx.warn, bx.warnBg),
                                      ],
                                    ),
                                    Text(
                                      '${purchases[i].supplierRef.isEmpty ? 'no ref' : purchases[i].supplierRef} · ${purchases[i].dateLabel} · ${purchases[i].lines.length} items',
                                      style: TextStyle(fontSize: 12, color: bx.muted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(money(purchases[i].total), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pay(BuildContext context, Supplier s, double due) async {
    final amt = TextEditingController(text: due.toStringAsFixed(2));
    String mode = 'Cash';
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSt) => Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pay ${s.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Payable: ${money(due)}', style: TextStyle(fontSize: 12.5, color: context.bx.muted)),
                const SizedBox(height: 12),
                TextField(
                  controller: amt,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Amount', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in ['Cash', 'UPI', 'Bank']) ChoiceChip(label: Text(m), selected: mode == m, onSelected: (_) => setSt(() => mode = m)),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Record payment'),
                ),
              ],
            ),
          ),
        ),
      );
      if (ok == true) {
        var v = double.tryParse(amt.text.trim()) ?? 0;
        if (v <= 0) {
          messenger.showSnackBar(const SnackBar(content: Text('Enter an amount greater than 0')));
          return;
        }
        if (v > due) v = due; // can't pay more than owed
        state.paySupplier(supplier: s, amount: v, mode: mode, nowMs: DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(SnackBar(content: Text('Paid ${money(v)} to ${s.name} ✓')));
      }
    } finally {
      amt.dispose();
    }
  }
}
