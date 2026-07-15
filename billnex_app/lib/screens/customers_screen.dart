import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../widgets/customer_picker.dart';
import '../l10n/app_localizations.dart';

class CustomersScreen extends StatefulWidget {
  final AppState state;
  const CustomersScreen({required this.state, super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String? _selectedCustomerId;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final c = await pickCustomer(context, state);
          if (c != null && context.mounted) _openDetail(context, state, c);
        },
        icon: const Icon(Icons.person_add_alt),
        label: Text(l.addCustomer),
      ),
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(builder: (context, c) => c.maxWidth >= 720 ? _wide(context) : _narrow(context)),
    );
  }

  // ── Phone: unchanged single-column list, taps push the detail screen. ──
  Widget _narrow(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
    children: [ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: _masterColumn(context, wide: false))],
  );

  // ── Tablet: master list + live detail pane. ──
  Widget _wide(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final selected = _selectedCustomerId != null && state.customers.any((x) => x.id == _selectedCustomerId);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: ListView(padding: const EdgeInsets.fromLTRB(18, 24, 14, 100), children: [_masterColumn(context, wide: true)]),
            ),
            Container(width: 1, color: bx.border),
            Expanded(
              child: selected
                  ? CustomerDetailView(state: state, customerId: _selectedCustomerId!, embedded: true)
                  : Center(
                      child: EmptyState(illustration: 'empty-no-customers', title: l.selectItemTitle, subtitle: l.selectItemSub),
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
    final customers = state.customers;
    final withDue = customers.where((c) => state.balanceOf(c.id) > 0).toList()..sort((a, b) => state.balanceOf(b.id).compareTo(state.balanceOf(a.id)));
    final settled = customers.where((c) => state.balanceOf(c.id) <= 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(l.customersTitle, l.customersSubtitle(customers.length, money(state.totalReceivable), state.overdueCount), trailing: wide ? null : Badge2(l.khataLedger)),
        if (customers.isEmpty)
          _empty(bx, l)
        else ...[
          if (withDue.isNotEmpty) ...[
            _sectionLabel(bx, l.sectionOutstanding),
            Card(
              child: Column(children: [for (int i = 0; i < withDue.length; i++) _row(context, withDue[i], i == 0, wide: wide)]),
            ),
            const SizedBox(height: 16),
          ],
          if (settled.isNotEmpty) ...[
            _sectionLabel(bx, l.sectionSettled),
            Card(
              child: Column(children: [for (int i = 0; i < settled.length; i++) _row(context, settled[i], i == 0, wide: wide)]),
            ),
          ],
        ],
      ],
    );
  }

  Widget _sectionLabel(BxColors bx, String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4, left: 2),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
    ),
  );

  Widget _empty(BxColors bx, L l) => Card(
    child: EmptyState(illustration: 'empty-no-customers', title: l.noCustomersTitle, subtitle: l.noCustomersSub),
  );

  Widget _row(BuildContext context, Customer c, bool first, {required bool wide}) {
    final bx = context.bx;
    final l = L.of(context);
    final bal = state.balanceOf(c.id);
    final over = c.creditLimit > 0 && bal > c.creditLimit;
    final isSelected = wide && c.id == _selectedCustomerId;
    return InkWell(
      onTap: () => wide ? setState(() => _selectedCustomerId = c.id) : _openDetail(context, state, c),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? bx.brand.withValues(alpha: 0.08) : null,
          border: Border(
            top: first ? BorderSide.none : BorderSide(color: bx.border),
            left: isSelected ? BorderSide(color: bx.brand, width: 3) : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: bx.accent.withValues(alpha: 0.14),
              child: Text(
                c.name.characters.first.toUpperCase(),
                style: TextStyle(color: bx.accent, fontWeight: FontWeight.w700),
              ),
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
                          c.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (over) ...[const SizedBox(width: 6), StatusChip(l.overLimit, bx.warn, bx.warnBg)],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(c.mobile.isEmpty ? l.noMobile : c.mobile, style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bal > 0 ? money(bal) : l.settledLabel,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bal > 0 ? bx.danger : bx.pos),
                ),
                Text(bal > 0 ? l.outstandingLabel : l.noDues, style: TextStyle(fontSize: 11, color: bx.faint)),
              ],
            ),
            Icon(Icons.chevron_right, size: 20, color: bx.faint),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, AppState state, Customer c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(state: state, customerId: c.id),
      ),
    );
  }
}

/// Colored status chip (PAID / PENDING style from the design spec).
class StatusChip extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const StatusChip(this.label, this.fg, this.bg, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
    ),
  );
}

/// Pushed detail screen for phones — Scaffold + AppBar wrapping [CustomerDetailView].
class CustomerDetailScreen extends StatelessWidget {
  final AppState state;
  final String customerId;
  const CustomerDetailScreen({required this.state, required this.customerId, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final c = state.customers.where((x) => x.id == customerId).firstOrNull;
        if (c == null) return const Scaffold(body: SizedBox.shrink());
        return Scaffold(
          appBar: AppBar(title: Text(c.name), backgroundColor: Theme.of(context).colorScheme.surface),
          body: CustomerDetailView(state: state, customerId: customerId),
        );
      },
    );
  }
}

/// Body content for a customer — used both inside [CustomerDetailScreen] (phone)
/// and embedded in the tablet master-detail pane. Preserves the balance header,
/// collect-payment action and ledger list in both modes.
class CustomerDetailView extends StatelessWidget {
  final AppState state;
  final String customerId;
  final bool embedded;
  const CustomerDetailView({required this.state, required this.customerId, this.embedded = false, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final c = state.customers.where((x) => x.id == customerId).firstOrNull;
        if (c == null) return const SizedBox.shrink();
        final entries = state.ledgerFor(c.id).reversed.toList();
        final bal = state.balanceOf(c.id);
        double running = 0;
        // compute running balances oldest->newest for display
        final chrono = state.ledgerFor(c.id);
        // Keyed by the entry object (identity), not epochMs — two entries can
        // share a millisecond and would otherwise collide to the same balance.
        final runningMap = <LedgerEntry, double>{};
        for (final e in chrono) {
          running += e.delta;
          runningMap[e] = running;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // balance header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0A2A51), Color(0xFF0B3B75)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF3988FF).withValues(alpha: 0.42)),
                boxShadow: bx.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFF3988FF).withValues(alpha: 0.22), shape: BoxShape.circle),
                          child: const Icon(Icons.storefront_rounded, color: Color(0xFF72AAFF), size: 25),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(c.mobile.isEmpty ? l.noMobile : c.mobile, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB9CCE3))),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFB9CCE3)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.outstandingBalance,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB9CCE3)),
                    ),
                    const SizedBox(height: 4),
                    Money(
                      bal,
                      style: BxText.valueHero.copyWith(fontSize: 32, color: Colors.white),
                      color: bal > 0 ? const Color(0xFFFF746C) : const Color(0xFF45E195),
                    ),
                    if (c.creditLimit > 0) ...[const SizedBox(height: 4), Text(l.limitLabel(money(c.creditLimit)), style: const TextStyle(fontSize: 12.5, color: Color(0xFFB9CCE3)))],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: bal <= 0 ? null : () => _collect(context, c, bal),
                            icon: const Icon(Icons.payments_outlined, size: 18),
                            label: Text(l.collectPayment),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1677FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: chrono.isEmpty ? null : () => _statement(context, c, chrono, runningMap, bal),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Colors.white),
                            label: Text(l.statement, style: const TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0x553988FF)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bx.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: bx.border),
              ),
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 42),
                decoration: BoxDecoration(color: bx.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)),
                child: Text(
                  l.ledgerLabel,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bx.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(l.noLedgerEntries, style: TextStyle(color: bx.muted)),
                  ),
                ),
              )
            else
              Card(child: Column(children: [for (int i = 0; i < entries.length; i++) _ledgerRow(context, entries[i], runningMap[entries[i]] ?? 0, i == 0)])),
          ],
        );
      },
    );
  }

  Widget _ledgerRow(BuildContext context, LedgerEntry e, double running, bool first) {
    final bx = context.bx;
    final l = L.of(context);
    final isCredit = e.credit > 0;
    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: (isCredit ? bx.pos : bx.accent).withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Icon(isCredit ? Icons.south_west_rounded : Icons.receipt_long_outlined, size: 18, color: isCredit ? bx.pos : bx.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.kind.label}${e.mode != null ? ' · ${e.mode}' : ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${e.ref} · ${e.dateLabel}', style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '−' : '+'}${money(isCredit ? e.credit : e.debit)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isCredit ? bx.pos : Theme.of(context).colorScheme.onSurface),
              ),
              Text(l.balLabel(money(running)), style: TextStyle(fontSize: 11, color: bx.faint)),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the account-statement rows from the chronological ledger and share
  /// the PDF (WhatsApp / email / save via the system sheet).
  Future<void> _statement(BuildContext context, Customer c, List<LedgerEntry> chrono, Map<LedgerEntry, double> runningMap, double closing) async {
    final l = L.of(context);
    final rows = [
      for (final e in chrono)
        (
          date: e.dateLabel,
          particulars: '${_kindLabel(l, e.kind)}${e.ref.isEmpty ? '' : ' · ${e.ref}'}',
          debit: e.debit,
          credit: e.credit,
          balance: runningMap[e] ?? 0,
        ),
    ];
    await PdfService.run(
      context,
      () => PdfService.sharePartyStatement(
        businessName: state.shopName,
        gstin: state.profile?.gstin,
        customerName: c.name,
        customerMobile: c.mobile,
        rows: rows,
        closing: closing,
      ),
      failure: l.shareFail,
    );
  }

  String _kindLabel(L l, LedgerKind k) => switch (k) {
        LedgerKind.creditSale => l.ledgerCreditSale,
        LedgerKind.collection => l.ledgerPayment,
        LedgerKind.openingDue => l.ledgerOpeningDue,
      };

  Future<void> _collect(BuildContext context, Customer c, double due) async {
    final l = L.of(context);
    final controller = TextEditingController(text: due.toStringAsFixed(2));
    String mode = 'Cash';
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) {
          final bx = ctx.bx;
          return StatefulBuilder(
            builder: (ctx, setSt) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.collectFrom(c.name), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l.outstandingSuffix(money(due)), style: TextStyle(fontSize: 13, color: bx.muted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
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
                      child: Text(l.recordCollection),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
      if (result == true) {
        var amt = double.tryParse(controller.text.trim()) ?? 0;
        if (amt <= 0) {
          messenger.showSnackBar(SnackBar(content: Text(l.enterAmtGt0)));
          return;
        }
        if (amt > due) amt = due; // never collect more than what's outstanding
        final entry = state.collect(customer: c, amount: amt, mode: mode, nowMs: DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(SnackBar(content: Text(l.collectedSnack(entry.ref, money(amt)))));
      }
    } finally {
      controller.dispose();
    }
  }
}
