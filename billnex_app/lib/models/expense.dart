/// A business expense (rent, transport, salary, …) — feeds the Profit & Loss
/// report and the day book. Kept deliberately simple: one amount, a category,
/// an optional note, and how it was paid.
class Expense {
  final String id;
  final int epochMs;
  final String category;
  final double amount;
  final String note;
  final String mode; // Cash / UPI / Bank

  const Expense({
    required this.id,
    required this.epochMs,
    required this.category,
    required this.amount,
    this.note = '',
    this.mode = 'Cash',
  });

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toJson() => {'id': id, 't': epochMs, 'c': category, 'a': amount, 'n': note, 'm': mode};

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        epochMs: (j['t'] as num).toInt(),
        category: j['c'] as String,
        amount: (j['a'] as num).toDouble(),
        note: (j['n'] as String?) ?? '',
        mode: (j['m'] as String?) ?? 'Cash',
      );
}

/// Common expense categories offered as quick chips (free-text still allowed).
const kExpenseCategories = ['Rent', 'Salary', 'Transport', 'Electricity', 'Supplies', 'Maintenance', 'Marketing', 'Other'];
