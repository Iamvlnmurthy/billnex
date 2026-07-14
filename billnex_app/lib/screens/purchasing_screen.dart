import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/supplier.dart';
import '../models/stock.dart';
import '../state/app_state.dart';
import '../services/billing.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import 'customers_screen.dart' show StatusChip;

class PurchasingScreen extends StatefulWidget {
  final AppState state;
  const PurchasingScreen({required this.state, super.key});
  @override
  State<PurchasingScreen> createState() => _PurchasingScreenState();
}

class _PurchasingScreenState extends State<PurchasingScreen> {
  String? _selectedSupplierId;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _newPurchase(context), icon: const Icon(Icons.add_shopping_cart), label: Text(l.newPurchase)),
      body: LayoutBuilder(builder: (context, c) => c.maxWidth >= 720 ? _wide(context) : _narrow(context)),
    );
  }

  List<Supplier> _sorted() => [...state.suppliers]..sort((a, b) => state.payableOf(b.id).compareTo(state.payableOf(a.id)));

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
        final selected = _selectedSupplierId != null && state.suppliers.any((x) => x.id == _selectedSupplierId);
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
                  ? SupplierDetailView(state: state, supplierId: _selectedSupplierId!, embedded: true)
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
    final suppliers = _sorted();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          l.purchasingTitle,
          l.purchasingSubtitle(suppliers.length, money(state.totalPayable), state.purchases.length),
          trailing: wide ? null : OutlinedButton.icon(onPressed: () => _addSupplier(context), icon: const Icon(Icons.person_add_alt, size: 18), label: Text(l.supplier)),
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
                    l.noSuppliersTitle,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bx.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(l.noSuppliersSub, style: TextStyle(fontSize: 13, color: bx.faint)),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(children: [for (int i = 0; i < suppliers.length; i++) _row(context, suppliers[i], i == 0, wide: wide)]),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, Supplier s, bool first, {required bool wide}) {
    final bx = context.bx;
    final l = L.of(context);
    final pay = state.payableOf(s.id);
    final isSelected = wide && s.id == _selectedSupplierId;
    return InkWell(
      onTap: () => wide
          ? setState(() => _selectedSupplierId = s.id)
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SupplierDetailScreen(state: state, supplierId: s.id),
              ),
            ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? bx.brand.withValues(alpha: 0.08) : null,
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
                style: TextStyle(color: bx.brand, fontWeight: FontWeight.w700),
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
                  Text(s.phone.isEmpty ? (s.gstin ?? l.noContact) : s.phone, style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pay > 0 ? money(pay) : l.settledLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pay > 0 ? bx.warn : bx.pos),
                  ),
                  Text(
                    pay > 0 ? l.payableLower : l.noDues,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: bx.faint),
                  ),
                ],
              ),
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
        builder: (ctx) {
          final l = L.of(ctx);
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.newSupplier, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: name,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l.fieldName, border: const OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().isEmpty ? l.enterName : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l.phoneField, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: gstin,
                    decoration: InputDecoration(labelText: l.gstinOptional, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(l.saveSupplier),
                  ),
                ],
              ),
            ),
          );
        },
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
    final l = L.of(context);
    final dup = widget.state.isDuplicatePurchase(_supplier.id, _ref.text);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.recordPurchase, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            // supplier
            InkWell(
              onTap: () async {
                final s = await _pickSupplier(context);
                if (s != null) setState(() => _supplier = s);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: l.supplier, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.expand_more)),
                child: Text(_supplier.name),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ref,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l.supplierInvoiceNo, border: const OutlineInputBorder(), errorText: dup ? l.duplicateInvoiceSupplier : null),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l.items, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(onPressed: _addLine, icon: const Icon(Icons.add, size: 18), label: Text(l.addItem)),
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
                      tooltip: l.removeItem,
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
                child: Text(l.noItemsYet, style: TextStyle(color: bx.faint)),
              ),
            const Divider(),
            Row(
              children: [
                Text(l.totalInclGst, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(money(_total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _paid,
              onChanged: (v) => setState(() => _paid = v),
              title: Text(l.paidNow, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(_paid ? l.noPayableCreated : l.addsToPayable, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: (_lines.isEmpty || dup) ? null : _record,
              icon: const Icon(Icons.check, size: 18),
              label: Text(dup ? l.duplicateChangeRef : l.recordPurchaseStockIn),
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
    builder: (ctx) {
      final l = L.of(ctx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in widget.state.suppliers) ListTile(title: Text(s.name), subtitle: Text(l.amtPayable(money(widget.state.payableOf(s.id)))), onTap: () => Navigator.pop(ctx, s)),
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(l.newSupplier),
              onTap: () async {
                final s = await widget.onAddSupplier();
                if (ctx.mounted) Navigator.pop(ctx, s);
              },
            ),
          ],
        ),
      );
    },
  );

  Future<void> _addLine() async {
    final items = widget.state.stockItems;
    final picked = await showModalBottomSheet<StockItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final l = L.of(ctx);
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: ListView(
              children: [for (final it in items) ListTile(title: Text(it.name), subtitle: Text(l.onHandCost(qtyLabel(it.qty), money(it.cost))), onTap: () => Navigator.pop(ctx, it))],
            ),
          ),
        );
      },
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
        builder: (ctx) {
          final l = L.of(ctx);
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(picked.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qty,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: l.qtyUnit(picked.unit), border: const OutlineInputBorder()),
                          validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) <= 0 ? l.gtZeroShort : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: rate,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(prefixText: '₹ ', labelText: l.rate, border: const OutlineInputBorder()),
                          validator: (v) => (double.tryParse((v ?? '').trim()) ?? -1) < 0 ? l.geZero : null,
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
                    child: Text(l.addLine),
                  ),
                ],
              ),
            ),
          );
        },
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
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final count = _lines.length;
    widget.state.recordPurchase(supplier: _supplier, lines: _lines, supplierRef: _ref.text, paid: _paid, nowMs: DateTime.now().millisecondsSinceEpoch);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(l.purchaseRecordedSnack(count.toString()))));
  }
}

/// Pushed detail screen for phones — Scaffold + AppBar wrapping [SupplierDetailView].
class SupplierDetailScreen extends StatelessWidget {
  final AppState state;
  final String supplierId;
  const SupplierDetailScreen({required this.state, required this.supplierId, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final s = state.suppliers.where((x) => x.id == supplierId).firstOrNull;
        if (s == null) return const Scaffold(body: SizedBox.shrink());
        return Scaffold(
          appBar: AppBar(title: Text(s.name), backgroundColor: Theme.of(context).colorScheme.surface),
          body: SupplierDetailView(state: state, supplierId: supplierId),
        );
      },
    );
  }
}

/// Supplier detail body — used inside [SupplierDetailScreen] (phone) and embedded
/// in the tablet master-detail pane. When [embedded] it renders its own name header.
class SupplierDetailView extends StatelessWidget {
  final AppState state;
  final String supplierId;
  final bool embedded;
  const SupplierDetailView({required this.state, required this.supplierId, this.embedded = false, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final l = L.of(context);
        final s = state.suppliers.where((x) => x.id == supplierId).firstOrNull;
        if (s == null) return const SizedBox.shrink();
        final pay = state.payableOf(s.id);
        final purchases = state.purchasesFor(s.id);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            if (embedded) ...[
              Text(
                s.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.payableBalance,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      money(pay),
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: pay > 0 ? bx.warn : bx.pos),
                    ),
                    if (s.phone.isNotEmpty) ...[const SizedBox(height: 4), Text(s.phone, style: TextStyle(fontSize: 13, color: bx.muted))],
                    const SizedBox(height: 14),
                    FilledButton.icon(onPressed: pay <= 0 ? null : () => _pay(context, s, pay), icon: const Icon(Icons.payments_outlined, size: 18), label: Text(l.paySupplierBtn)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                l.purchasesUpper,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
              ),
            ),
            if (purchases.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(l.noPurchases, style: TextStyle(color: bx.muted)),
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
                                      Text(purchases[i].purchaseNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 8),
                                      purchases[i].paid ? StatusChip(l.paid, bx.pos, bx.posBg) : StatusChip(l.creditChip, bx.warn, bx.warnBg),
                                    ],
                                  ),
                                  Text(
                                    l.purchaseLineInfo(purchases[i].supplierRef.isEmpty ? l.noRef : purchases[i].supplierRef, purchases[i].dateLabel, purchases[i].lines.length.toString()),
                                    style: TextStyle(fontSize: 12, color: bx.muted),
                                  ),
                                ],
                              ),
                            ),
                            Text(money(purchases[i].total), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pay(BuildContext context, Supplier s, double due) async {
    final l = L.of(context);
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
                Text(l.paySupplierTitle(s.name), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l.payableColon(money(due)), style: TextStyle(fontSize: 12.5, color: context.bx.muted)),
                const SizedBox(height: 12),
                TextField(
                  controller: amt,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(prefixText: '₹ ', labelText: l.amount, border: const OutlineInputBorder()),
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
                  child: Text(l.recordPayment),
                ),
              ],
            ),
          ),
        ),
      );
      if (ok == true) {
        var v = double.tryParse(amt.text.trim()) ?? 0;
        if (v <= 0) {
          messenger.showSnackBar(SnackBar(content: Text(l.enterAmtGt0)));
          return;
        }
        if (v > due) v = due; // can't pay more than owed
        state.paySupplier(supplier: s, amount: v, mode: mode, nowMs: DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(SnackBar(content: Text(l.paidToSnack(money(v), s.name))));
      }
    } finally {
      amt.dispose();
    }
  }
}
