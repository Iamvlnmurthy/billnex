import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

/// Business expenses — a simple ledger by category that feeds Profit & Loss.
class ExpensesScreen extends StatelessWidget {
  final AppState state;
  const ExpensesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.expensesTitle)),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context), icon: const Icon(Icons.add), label: Text(l.addExpenseTitle)),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          final bx = context.bx;
          final items = state.expenses;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageHeader(l.expensesTitle, l.expensesSub),
                      Card(
                        color: bx.brand.withValues(alpha: 0.06),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Icon(Icons.trending_down, color: bx.danger),
                              const SizedBox(width: 12),
                              Expanded(child: Text(l.totalExpensesLabel, style: const TextStyle(fontWeight: FontWeight.w700))),
                              Money(state.totalExpenses, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800), color: bx.danger),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text(l.noExpenses, style: TextStyle(color: bx.muted))),
                        )
                      else
                        Card(
                          child: Column(
                            children: [
                              for (int i = 0; i < items.length; i++) _row(context, items[i], first: i == 0),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, Expense e, {required bool first}) {
    final bx = context.bx;
    return Dismissible(
      key: ValueKey(e.id),
      direction: DismissDirection.endToStart,
      background: Container(color: bx.dangerBg, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: Icon(Icons.delete_outline, color: bx.danger)),
      confirmDismiss: (_) async => confirmDialog(context, title: L.of(context).expenseDelete, message: '${e.category} · ${money(e.amount)}', confirmLabel: L.of(context).delete, destructive: true),
      onDismissed: (_) => state.deleteExpense(e.id),
      child: Container(
        decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: bx.warnBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.receipt_outlined, size: 19, color: bx.warn),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${e.dateLabel} · ${e.mode}${e.note.isEmpty ? '' : ' · ${e.note}'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: bx.muted)),
                ],
              ),
            ),
            Money(e.amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    var category = kExpenseCategories.first;
    var mode = 'Cash';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final bx = ctx.bx;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.addExpenseTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountC,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(prefixText: '₹ ', labelText: l.expenseAmount, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  Text(l.expenseCategory, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bx.faint)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final cat in kExpenseCategories)
                        ChoiceChip(label: Text(cat), selected: category == cat, onSelected: (_) => setSt(() => category = cat)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'Cash', label: Text(l.cash)),
                            ButtonSegment(value: 'UPI', label: Text(l.upi)),
                            const ButtonSegment(value: 'Bank', label: Text('Bank')),
                          ],
                          selected: {mode},
                          onSelectionChanged: (s) => setSt(() => mode = s.first),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteC,
                    decoration: InputDecoration(labelText: l.expenseNote, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if ((double.tryParse(amountC.text.trim()) ?? 0) > 0) Navigator.pop(ctx, true);
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(l.addExpenseTitle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok == true) {
      state.addExpense(category: category, amount: double.tryParse(amountC.text.trim()) ?? 0, note: noteC.text, mode: mode, nowMs: DateTime.now().millisecondsSinceEpoch);
      messenger.showSnackBar(SnackBar(content: Text(l.expenseSaved)));
    }
    amountC.dispose();
    noteC.dispose();
  }
}
