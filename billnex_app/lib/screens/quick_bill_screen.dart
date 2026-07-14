import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../services/billing.dart';
import '../services/pdf_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common.dart';
import '../widgets/customer_picker.dart';

/// The fastest counter-billing flow — built for a rush-hour kirana counter.
///
/// Two modes share one Collect footer:
///  • Tally    — a smart adding machine: punch amounts on a big keypad.
///  • Itemized — custom item + unit + quantity presets + rate, with a passive
///    catalogue (learned name→rate) so there is nothing to set up first.
class QuickBillScreen extends StatefulWidget {
  final AppState state;
  const QuickBillScreen({required this.state, super.key});
  @override
  State<QuickBillScreen> createState() => _QuickBillScreenState();
}

enum _Mode { tally, itemized }

class _QLine {
  String name;
  String unit; // base unit: 'kg' | 'L' | 'pc'
  double qty; // in the base unit
  double rate; // per base unit
  _QLine({this.name = '', this.unit = 'pc', this.qty = 1, this.rate = 0});
  double get amount => qty * rate;
}

class _QuickBillScreenState extends State<QuickBillScreen> {
  _Mode _mode = _Mode.tally;

  // Tally state
  final List<double> _tally = [];
  String _entry = '';

  // Itemized state
  final List<_QLine> _items = [];
  final _nameC = TextEditingController();
  final _qtyC = TextEditingController(text: '1');
  final _rateC = TextEditingController();
  String _unit = 'kg';
  bool _showSuggestions = false;

  // Shared footer
  double _discount = 0;
  bool _roundOff = true;

  AppState get state => widget.state;

  @override
  void dispose() {
    _nameC.dispose();
    _qtyC.dispose();
    _rateC.dispose();
    super.dispose();
  }

  // ── totals ────────────────────────────────────────────────────────────
  double get _subtotal => _mode == _Mode.tally ? _tally.fold(0.0, (a, v) => a + v) + (double.tryParse(_entry) ?? 0) : _items.fold(0.0, (a, l) => a + l.amount);

  double get _grandRaw => (_subtotal - _discount).clamp(0, double.infinity);
  double get _grand => _roundOff ? _grandRaw.roundToDouble() : (_grandRaw * 100).round() / 100;
  int get _count => _mode == _Mode.tally ? _tally.length + (_entry.isNotEmpty ? 1 : 0) : _items.length;
  bool get _hasLines => _count > 0;

  // ── build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Column(
      children: [
        _header(bx),
        Expanded(child: _mode == _Mode.tally ? _tallyBody(bx) : _itemizedBody(bx)),
        _footer(bx),
      ],
    );
  }

  Widget _header(BxColors bx) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF06356A), Color(0xFF071F3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2076D9)),
        boxShadow: const [BoxShadow(color: Color(0x330067E8), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: const Color(0xFF1578F6), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          // Title yields space to the mode switch (which can carry long localized
          // labels); both shrink with ellipsis rather than overflow on small phones.
          Flexible(
            flex: 2,
            child: Text(
              L.of(context).quickBill,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
          ),
          const SizedBox(width: 8),
          // mode switch
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: _modeTab(bx, L.of(context).tally, _Mode.tally)),
                  Flexible(child: _modeTab(bx, L.of(context).itemized, _Mode.itemized)),
                ],
              ),
            ),
          ),
          if (_hasLines) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: L.of(context).more,
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (v) {
                switch (v) {
                  case 'estimate':
                    _shareDoc(context, 'quotation', 'Estimate');
                  case 'challan':
                    _shareDoc(context, 'delivery', 'Delivery challan');
                  case 'clear':
                    _confirmClear();
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: 'estimate',
                  child: ListTile(dense: true, leading: Icon(Icons.description_outlined), title: Text('Share as estimate')),
                ),
                PopupMenuItem(
                  value: 'challan',
                  child: ListTile(dense: true, leading: Icon(Icons.local_shipping_outlined), title: Text('Share delivery challan')),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: ListTile(dense: true, leading: Icon(Icons.delete_sweep_outlined), title: Text('Clear bill')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _modeTab(BxColors bx, String label, _Mode m) {
    final on = _mode == m;
    return InkWell(
      onTap: () => setState(() => _mode = m),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: on ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: on ? const Color(0xFF0969DC) : Colors.white70),
        ),
      ),
    );
  }

  // ── TALLY ─────────────────────────────────────────────────────────────
  Widget _tallyBody(BxColors bx) {
    return Column(
      children: [
        Expanded(
          child: _tally.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: bx.border),
                      boxShadow: bx.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: bx.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.receipt_long_outlined, color: bx.accent, size: 20),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                L.of(context).currentBill,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                L.of(context).punchAmounts,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: bx.muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('₹0', style: BxText.value.copyWith(color: bx.faint)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: _tally.length,
                  itemBuilder: (context, i) {
                    final idx = _tally.length - 1 - i; // reversed
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: bx.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${idx + 1}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bx.faint),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(money(_tally[idx]), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          ),
                          InkWell(
                            onTap: () => setState(() => _tally.removeAt(idx)),
                            borderRadius: BorderRadius.circular(22),
                            child: Semantics(
                              button: true,
                              label: L.of(context).removeLine,
                              child: SizedBox(width: 40, height: 40, child: Icon(Icons.close, size: 18, color: bx.faint)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // current entry
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bx.border),
          ),
          child: Row(
            children: [
              Text(
                L.of(context).amount,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: bx.muted),
              ),
              const Spacer(),
              Text(
                '₹${_entry.isEmpty ? '0' : _entry}',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, color: _entry.isEmpty ? bx.faint : bx.accent),
              ),
            ],
          ),
        ),
        _keypad(bx),
      ],
    );
  }

  Widget _keypad(BxColors bx) {
    Widget key(String label, {VoidCallback? onTap, Widget? child, Color? color, Color? fg, int flex = 1}) {
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Material(
            color: color ?? bx.surface2,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: bx.border),
                ),
                child:
                    child ??
                    Text(
                      label,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: fg),
                    ),
              ),
            ),
          ),
        ),
      );
    }

    void press(String d) {
      HapticFeedback.selectionClick();
      setState(() {
        if (d == '.' && _entry.contains('.')) return;
        if (_entry.length > 9) return;
        _entry += d;
      });
    }

    void addLine() {
      final v = double.tryParse(_entry) ?? 0;
      if (v <= 0) return;
      HapticFeedback.lightImpact();
      setState(() {
        _tally.add(v);
        _entry = '';
      });
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bx.border),
        boxShadow: bx.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              key('7', onTap: () => press('7')),
              key('8', onTap: () => press('8')),
              key('9', onTap: () => press('9')),
            ],
          ),
          Row(
            children: [
              key('4', onTap: () => press('4')),
              key('5', onTap: () => press('5')),
              key('6', onTap: () => press('6')),
            ],
          ),
          Row(
            children: [
              key('1', onTap: () => press('1')),
              key('2', onTap: () => press('2')),
              key('3', onTap: () => press('3')),
            ],
          ),
          Row(
            children: [
              key('.', onTap: () => press('.')),
              key('0', onTap: () => press('0')),
              key(
                '',
                onTap: () => setState(() => _entry = _entry.isEmpty ? '' : _entry.substring(0, _entry.length - 1)),
                child: Icon(Icons.backspace_outlined, color: bx.muted),
              ),
            ],
          ),
          Row(
            children: [key('${L.of(context).add} +', onTap: addLine, color: bx.accent, fg: bx.onAccent, flex: 3)],
          ),
        ],
      ),
    );
  }

  // ── ITEMIZED ──────────────────────────────────────────────────────────
  Widget _itemizedBody(BxColors bx) {
    final freq = state.frequentItems();
    final suggestions = state.quickSuggest(_nameC.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      children: [
        if (freq.isNotEmpty) ...[
          Text(
            L.of(context).frequent,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: bx.faint),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: freq.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ActionChip(label: Text('${freq[i].name} · ${money(freq[i].rate)}'), onPressed: () => _pick(freq[i].name, freq[i].rate, freq[i].unit)),
            ),
          ),
          const SizedBox(height: 14),
        ],
        // added lines
        for (int i = 0; i < _items.length; i++) _itemCard(bx, _items[i], i),
        if (_items.isNotEmpty) const SizedBox(height: 12),
        // editor
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameC,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() => _showSuggestions = true),
                  decoration: InputDecoration(
                    labelText: L.of(context).item,
                    hintText: 'Type to search stock, or leave blank for loose',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _nameC.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: L.of(context).clearLabel,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() {
                              _nameC.clear();
                              _showSuggestions = false;
                            }),
                          ),
                  ),
                ),
                // Live filtered dropdown of matching inventory / past items.
                if (_showSuggestions && suggestions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 232),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: bx.border),
                      boxShadow: bx.cardShadow,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: bx.border),
                      itemBuilder: (context, i) {
                        final sug = suggestions[i];
                        return InkWell(
                          onTap: () => _pick(sug.name, sug.rate, sug.unit),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            child: Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 18, color: bx.brand),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sug.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (sug.inStock) ...[
                                  Text('${qtyLabel(sug.stock)} ${sug.unit}', style: TextStyle(fontSize: 11.5, color: sug.stock <= 0 ? bx.danger : bx.muted)),
                                  const SizedBox(width: 10),
                                ],
                                Text(
                                  '${money(sug.rate)}/${sug.unit == 'pc' ? 'pc' : sug.unit}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bx.accent),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // unit toggle
                Row(
                  children: [
                    Text(L.of(context).unit, style: TextStyle(fontSize: 13, color: bx.muted)),
                    const SizedBox(width: 12),
                    for (final u in const ['kg', 'L', 'pc']) ...[_unitChip(bx, u), const SizedBox(width: 8)],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyC,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Qty (${_unit == 'pc' ? 'pieces' : _unit})',
                          hintText: _unit == 'kg' ? 'e.g. 150g or 0.15' : '1',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _rateC,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(prefixText: '₹ ', labelText: 'Rate / ${_unit == 'pc' ? 'pc' : _unit}', border: const OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // quantity presets
                _presetChips(bx),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(L.of(context).amount, style: TextStyle(fontSize: 13, color: bx.muted)),
                    const Spacer(),
                    Text(money(_editorAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _editorAmount > 0 ? _addItem : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(L.of(context).addItem),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double get _editorQty => parseQty(_qtyC.text, _unit) ?? 0;
  double get _editorRate => double.tryParse(_rateC.text.trim()) ?? 0;
  double get _editorAmount => _editorQty * _editorRate;

  Widget _unitChip(BxColors bx, String u) {
    final on = _unit == u;
    return InkWell(
      onTap: () => setState(() => _unit = u),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? bx.brand.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? bx.brand : bx.border),
        ),
        child: Text(
          u == 'pc' ? 'Pieces' : u,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? bx.brand : bx.muted),
        ),
      ),
    );
  }

  Widget _presetChips(BxColors bx) {
    final presets = switch (_unit) {
      'kg' => const [('100g', 0.1), ('250g', 0.25), ('½kg', 0.5), ('1kg', 1.0), ('2kg', 2.0)],
      'L' => const [('100ml', 0.1), ('250ml', 0.25), ('500ml', 0.5), ('1L', 1.0)],
      _ => const [('1', 1.0), ('2', 2.0), ('5', 5.0), ('10', 10.0)],
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_unit == 'pc')
          _stepBtn(bx, Icons.remove, () {
            final q = (double.tryParse(_qtyC.text) ?? 0) - 1;
            _qtyC.text = qtyLabel(q < 0 ? 0 : q);
            setState(() {});
          }),
        for (final p in presets)
          InkWell(
            onTap: () {
              _qtyC.text = qtyLabel(p.$2);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 52),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bx.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bx.border),
              ),
              child: Text(p.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        if (_unit == 'pc')
          _stepBtn(bx, Icons.add, () {
            final q = (double.tryParse(_qtyC.text) ?? 0) + 1;
            _qtyC.text = qtyLabel(q);
            setState(() {});
          }),
      ],
    );
  }

  Widget _stepBtn(BxColors bx, IconData ic, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 44,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bx.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bx.border),
      ),
      child: Icon(ic, size: 18),
    ),
  );

  Widget _itemCard(BxColors bx, _QLine l, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bx.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name.isEmpty ? 'Item ${i + 1}' : l.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${friendlyQty(l.qty, l.unit)} × ${money(l.rate)}/${l.unit == 'pc' ? 'pc' : l.unit}', style: TextStyle(fontSize: 12.5, color: bx.muted)),
              ],
            ),
          ),
          Text(money(l.amount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          InkWell(
            onTap: () => setState(() => _items.removeAt(i)),
            borderRadius: BorderRadius.circular(22),
            child: Semantics(
              button: true,
              label: L.of(context).removeLine,
              child: SizedBox(width: 40, height: 40, child: Icon(Icons.close, size: 18, color: bx.faint)),
            ),
          ),
        ],
      ),
    );
  }

  /// Fills the editor from a picked suggestion / frequent item and closes the
  /// dropdown so the owner can move straight to quantity.
  void _pick(String name, double rate, String unit) {
    setState(() {
      _nameC.text = name;
      _rateC.text = qtyLabel(rate);
      _unit = unit;
      _showSuggestions = false;
    });
  }

  void _addItem() {
    setState(() {
      _items.add(_QLine(name: _nameC.text.trim(), unit: _unit, qty: _editorQty, rate: _editorRate));
      _nameC.clear();
      _qtyC.text = '1';
      _rateC.clear();
      _showSuggestions = false;
    });
  }

  // ── FOOTER ────────────────────────────────────────────────────────────
  Widget _footer(BxColors bx) {
    final roundedDelta = _grand - _grandRaw;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: bx.border)),
        boxShadow: bx.cardShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // discount
                  InkWell(
                    onTap: _editDiscount,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 15, color: bx.muted),
                          const SizedBox(width: 6),
                          Text(
                            _discount > 0 ? '${L.of(context).discount} ${money(_discount)}' : L.of(context).discount,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _discount > 0 ? bx.accent : bx.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // round-off toggle
                  InkWell(
                    onTap: () => setState(() => _roundOff = !_roundOff),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_roundOff ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: _roundOff ? bx.accent : bx.faint),
                          const SizedBox(width: 6),
                          Text(
                            '${L.of(context).roundOff}${_roundOff && roundedDelta != 0 ? ' (${roundedDelta > 0 ? '+' : ''}${money(roundedDelta)})' : ''}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: bx.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _hasLines ? _collect : null,
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.check_circle_outline, size: 21),
                  label: Text(_hasLines ? '${L.of(context).collect}  ${money(_grand)}' : L.of(context).collect, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── actions ───────────────────────────────────────────────────────────
  Future<void> _editDiscount() async {
    final c = TextEditingController(text: _discount > 0 ? qtyLabel(_discount) : '');
    try {
      final v = await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bill discount'),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ ', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 0.0), child: const Text('Clear')),
            FilledButton(onPressed: () => Navigator.pop(ctx, double.tryParse(c.text.trim()) ?? 0), child: const Text('Apply')),
          ],
        ),
      );
      if (v != null) setState(() => _discount = v.clamp(0, _subtotal).toDouble());
    } finally {
      c.dispose();
    }
  }

  void _confirmClear() {
    setState(() {
      _tally.clear();
      _items.clear();
      _entry = '';
      _discount = 0;
      _nameC.clear();
      _rateC.clear();
      _qtyC.text = '1';
    });
  }

  List<({String name, String unit, double qty, double rate, double gstRate})> _saleLines() {
    if (_mode == _Mode.tally) {
      final all = [..._tally, if ((double.tryParse(_entry) ?? 0) > 0) double.parse(_entry)];
      return [for (final a in all) (name: '', unit: 'pc', qty: 1.0, rate: a, gstRate: 0.0)];
    }
    return [for (final l in _items) (name: l.name, unit: l.unit, qty: l.qty, rate: l.rate, gstRate: 0.0)];
  }

  /// Shares an Estimate / Delivery Challan PDF from the current lines WITHOUT
  /// posting — a quote/challan is not an accounting document.
  Future<void> _shareDoc(BuildContext context, String templateId, String label) async {
    final lines = _saleLines();
    if (lines.isEmpty) return;
    final doc = Sale(
      invoiceNo: label == 'Estimate' ? '#EST' : '#DC',
      epochMs: DateTime.now().millisecondsSinceEpoch,
      businessName: state.shopName,
      templateId: templateId,
      lines: [for (final l in lines) SaleLine(l.name.isEmpty ? 'Item' : l.name, l.qty, l.rate, gstRate: l.gstRate)],
      subtotal: _grand,
      gst: 0,
      total: _grand,
      paymentMode: label,
      sellerGstin: state.profile?.gstin,
      sellerPhone: state.profile?.phone,
      sellerAddress: state.profile?.address,
    );
    await PdfService.run(context, () => PdfService.shareSale(doc), failure: "Couldn't share the $label");
  }

  Future<void> _collect() async {
    final lines = _saleLines();
    if (lines.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showModalBottomSheet<_CollectResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _CollectSheet(state: state, total: _grand),
    );
    if (result == null) return;

    final sale = state.postCustomSale(lines: lines, paymentMode: result.mode, billDiscount: _discount, roundOff: _roundOff, customer: result.customer, nowMs: DateTime.now().millisecondsSinceEpoch);
    _confirmClear();
    if (!mounted) return;
    final l = L.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${l.qbSalePosted(sale.invoiceNo, result.mode, money(sale.total))}${result.change > 0 ? l.qbReturnSuffix(money(result.change)) : ''} ✓'),
        action: SnackBarAction(
          label: l.navPrint,
          onPressed: () => PdfService.run(context, () => PdfService.printSale(sale), failure: l.printFail),
        ),
      ),
    );
  }
}

/// Parses a quantity that may be a raw base-unit number (0.15) or a
/// real-unit string (150g, 500ml, 2kg). Returns the value in [base] units.
double? parseQty(String raw, String base) {
  final t = raw.trim().toLowerCase().replaceAll(' ', '');
  if (t.isEmpty) return null;
  final m = RegExp(r'^([0-9]*\.?[0-9]+)(kg|gms|gm|g|ml|ltr|lt|l|pcs|pc|nos|no)?$').firstMatch(t);
  if (m == null) return double.tryParse(t);
  final n = double.parse(m.group(1)!);
  final u = m.group(2);
  if (u == null) return n; // raw number, already in base unit
  return switch (u) {
    'g' || 'gm' || 'gms' => base == 'kg' ? n / 1000 : n,
    'kg' => n,
    'ml' => base == 'L' ? n / 1000 : n,
    'l' || 'lt' || 'ltr' => n,
    _ => n,
  };
}

/// Friendly display of a base-unit quantity (0.15 kg → "150 g").
String friendlyQty(double q, String base) {
  if (base == 'kg') return q > 0 && q < 1 ? '${qtyLabel(q * 1000)} g' : '${qtyLabel(q)} kg';
  if (base == 'L') return q > 0 && q < 1 ? '${qtyLabel(q * 1000)} ml' : '${qtyLabel(q)} L';
  return '${qtyLabel(q)} pc';
}

class _CollectResult {
  final String mode;
  final Customer? customer;
  final double change;
  _CollectResult(this.mode, this.customer, this.change);
}

/// Collect footer: choose mode, take cash received → show change, or attach a
/// khata customer for credit.
class _CollectSheet extends StatefulWidget {
  final AppState state;
  final double total;
  const _CollectSheet({required this.state, required this.total});
  @override
  State<_CollectSheet> createState() => _CollectSheetState();
}

class _CollectSheetState extends State<_CollectSheet> {
  final _received = TextEditingController();
  Customer? _customer;

  @override
  void dispose() {
    _received.dispose();
    super.dispose();
  }

  double get _change {
    final r = double.tryParse(_received.text.trim()) ?? 0;
    final c = r - widget.total;
    return c > 0 ? c : 0;
  }

  void _finish(String mode) {
    if (mode == 'Credit' && _customer == null) {
      pickCustomer(context, widget.state).then((c) {
        if (c != null && mounted) Navigator.pop(context, _CollectResult('Credit', c, 0));
      });
      return;
    }
    Navigator.pop(context, _CollectResult(mode, _customer, mode == 'Cash' ? _change : 0));
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final creditOn = widget.state.isOn('creditLedger');
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Money(widget.total, style: BxText.valueHero.copyWith(fontSize: 34))),
          const SizedBox(height: 2),
          Center(
            child: Text(L.of(context).amountToCollect, style: TextStyle(fontSize: 13, color: bx.muted)),
          ),
          const SizedBox(height: 18),
          // cash received → change
          TextField(
            controller: _received,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(prefixText: '₹ ', labelText: L.of(context).cashReceived, border: const OutlineInputBorder()),
          ),
          if (_change > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(L.of(context).returnChange, style: TextStyle(fontSize: 14, color: bx.muted)),
                const Spacer(),
                Text(
                  money(_change),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: bx.pos),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _finish('Cash'),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: Text(L.of(context).cash),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _finish('UPI'),
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: Text(L.of(context).upi),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
          if (creditOn) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _finish('Credit'),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(_customer == null ? L.of(context).khataCredit : 'Khata · ${_customer!.name}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ],
      ),
    );
  }
}
