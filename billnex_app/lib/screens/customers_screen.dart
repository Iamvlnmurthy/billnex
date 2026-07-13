import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import '../widgets/customer_picker.dart';

class CustomersScreen extends StatelessWidget {
  final AppState state;
  const CustomersScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final customers = state.customers;
    final withDue = customers.where((c) => state.balanceOf(c.id) > 0).toList()..sort((a, b) => state.balanceOf(b.id).compareTo(state.balanceOf(a.id)));
    final settled = customers.where((c) => state.balanceOf(c.id) <= 0).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final c = await pickCustomer(context, state);
          if (c != null && context.mounted) _openDetail(context, state, c);
        },
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add customer'),
      ),
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  'Customers & Credit',
                  '${customers.length} customers · ${money(state.totalReceivable)} receivable across ${state.overdueCount} accounts.',
                  trailing: const Badge2('Khata ledger'),
                ),
                if (customers.isEmpty)
                  _empty(bx)
                else ...[
                  if (withDue.isNotEmpty) ...[
                    _sectionLabel(bx, 'Outstanding'),
                    Card(child: Column(children: [for (int i = 0; i < withDue.length; i++) _row(context, withDue[i], i == 0)])),
                    const SizedBox(height: 16),
                  ],
                  if (settled.isNotEmpty) ...[
                    _sectionLabel(bx, 'Settled'),
                    Card(child: Column(children: [for (int i = 0; i < settled.length; i++) _row(context, settled[i], i == 0)])),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BxColors bx, String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4, left: 2),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
    ),
  );

  Widget _empty(BxColors bx) => const Card(
    child: EmptyState(illustration: 'empty-no-customers', title: 'No customers yet', subtitle: 'Add one here, or attach a customer on a credit sale.'),
  );

  Widget _row(BuildContext context, Customer c, bool first) {
    final bx = context.bx;
    final bal = state.balanceOf(c.id);
    final over = c.creditLimit > 0 && bal > c.creditLimit;
    return InkWell(
      onTap: () => _openDetail(context, state, c),
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
                c.name.characters.first.toUpperCase(),
                style: TextStyle(color: bx.brand, fontWeight: FontWeight.w800),
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
                      if (over) ...[const SizedBox(width: 6), StatusChip('Over limit', bx.warn, bx.warnBg)],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(c.mobile.isEmpty ? 'No mobile' : c.mobile, style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bal > 0 ? money(bal) : 'Settled',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: bal > 0 ? bx.danger : bx.pos),
                ),
                Text(bal > 0 ? 'outstanding' : 'no dues', style: TextStyle(fontSize: 11, color: bx.faint)),
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
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
    ),
  );
}

class CustomerDetailScreen extends StatelessWidget {
  final AppState state;
  final String customerId;
  const CustomerDetailScreen({required this.state, required this.customerId, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final c = state.customers.firstWhere((x) => x.id == customerId);
        final entries = state.ledgerFor(c.id).reversed.toList();
        final bal = state.balanceOf(c.id);
        double running = 0;
        // compute running balances oldest->newest for display
        final chrono = state.ledgerFor(c.id);
        final runningMap = <int, double>{};
        for (final e in chrono) {
          running += e.delta;
          runningMap[e.epochMs] = running;
        }

        return Scaffold(
          appBar: AppBar(title: Text(c.name), backgroundColor: Theme.of(context).colorScheme.surface),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // balance header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OUTSTANDING BALANCE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        money(bal),
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: bal > 0 ? bx.danger : bx.pos),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: bx.muted),
                          const SizedBox(width: 5),
                          Text(c.mobile.isEmpty ? 'No mobile' : c.mobile, style: TextStyle(fontSize: 13, color: bx.muted)),
                          if (c.creditLimit > 0) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.credit_score_outlined, size: 14, color: bx.muted),
                            const SizedBox(width: 5),
                            Text('Limit ${money(c.creditLimit)}', style: TextStyle(fontSize: 13, color: bx.muted)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: bal <= 0 ? null : () => _collect(context, c, bal),
                              icon: const Icon(Icons.payments_outlined, size: 18),
                              label: const Text('Collect payment'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  'LEDGER',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint),
                ),
              ),
              if (entries.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No ledger entries', style: TextStyle(color: bx.muted)),
                    ),
                  ),
                )
              else
                Card(child: Column(children: [for (int i = 0; i < entries.length; i++) _ledgerRow(context, entries[i], runningMap[entries[i].epochMs] ?? 0, i == 0)])),
            ],
          ),
        );
      },
    );
  }

  Widget _ledgerRow(BuildContext context, LedgerEntry e, double running, bool first) {
    final bx = context.bx;
    final isCredit = e.credit > 0;
    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: (isCredit ? bx.pos : bx.brand).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(isCredit ? Icons.south_west : Icons.north_east, size: 17, color: isCredit ? bx.pos : bx.brand),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isCredit ? bx.pos : Theme.of(context).colorScheme.onSurface),
              ),
              Text('bal ${money(running)}', style: TextStyle(fontSize: 11, color: bx.faint)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _collect(BuildContext context, Customer c, double due) async {
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
                    Text('Collect from ${c.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${money(due)} outstanding', style: TextStyle(fontSize: 13, color: bx.muted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
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
                      child: const Text('Record collection'),
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
          messenger.showSnackBar(const SnackBar(content: Text('Enter an amount greater than 0')));
          return;
        }
        if (amt > due) amt = due; // never collect more than what's outstanding
        final entry = state.collect(customer: c, amount: amt, mode: mode, nowMs: DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(SnackBar(content: Text('${entry.ref} · ${money(amt)} collected ✓')));
      }
    } finally {
      controller.dispose();
    }
  }
}
