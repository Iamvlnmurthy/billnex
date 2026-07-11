/// A supplier / vendor (PRD BNX-0172 supplier master).
class Supplier {
  final String id;
  final String name;
  final String phone;
  final String? gstin;
  final int creditDays;

  const Supplier({required this.id, required this.name, this.phone = '', this.gstin, this.creditDays = 0});

  Map<String, dynamic> toJson() => {'id': id, 'n': name, 'p': phone, 'g': gstin, 'd': creditDays};
  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: j['id'] as String,
        name: j['n'] as String,
        phone: (j['p'] ?? '') as String,
        gstin: j['g'] as String?,
        creditDays: (j['d'] as num?)?.toInt() ?? 0,
      );
}

class PurchaseLine {
  final String sku;
  final double qty;
  final double rate;
  const PurchaseLine(this.sku, this.qty, this.rate);
  double get amount => qty * rate;

  Map<String, dynamic> toJson() => {'s': sku, 'q': qty, 'r': rate};
  factory PurchaseLine.fromJson(Map<String, dynamic> j) =>
      PurchaseLine(j['s'] as String, (j['q'] as num).toDouble(), (j['r'] as num).toDouble());
}

/// A recorded purchase (PRD BNX-0177 purchase invoice) — increases stock and
/// creates a payable.
class Purchase {
  final String purchaseNo;
  final int epochMs;
  final String supplierId;
  final String supplierRef; // supplier's own invoice number
  final List<PurchaseLine> lines;
  final double subtotal;
  final double gst;
  final double total;
  final bool paid;

  const Purchase({
    required this.purchaseNo,
    required this.epochMs,
    required this.supplierId,
    required this.supplierRef,
    required this.lines,
    required this.subtotal,
    required this.gst,
    required this.total,
    this.paid = false,
  });

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toJson() => {
        'no': purchaseNo,
        't': epochMs,
        'sid': supplierId,
        'ref': supplierRef,
        'l': lines.map((e) => e.toJson()).toList(),
        's': subtotal,
        'g': gst,
        'tot': total,
        'paid': paid,
      };

  factory Purchase.fromJson(Map<String, dynamic> j) => Purchase(
        purchaseNo: j['no'] as String,
        epochMs: (j['t'] as num).toInt(),
        supplierId: j['sid'] as String,
        supplierRef: (j['ref'] ?? '') as String,
        lines: (j['l'] as List).map((e) => PurchaseLine.fromJson(e as Map<String, dynamic>)).toList(),
        subtotal: (j['s'] as num).toDouble(),
        gst: (j['g'] as num).toDouble(),
        total: (j['tot'] as num).toDouble(),
        paid: j['paid'] == true,
      );
}

/// Supplier payable movement. [debit] = we owe more; [credit] = we paid.
class PayableEntry {
  final String supplierId;
  final int epochMs;
  final String ref;
  final double debit;
  final double credit;
  final String? mode;

  const PayableEntry({required this.supplierId, required this.epochMs, required this.ref, this.debit = 0, this.credit = 0, this.mode});

  double get delta => debit - credit;

  Map<String, dynamic> toJson() => {'s': supplierId, 't': epochMs, 'r': ref, 'd': debit, 'c': credit, 'm': mode};
  factory PayableEntry.fromJson(Map<String, dynamic> j) => PayableEntry(
        supplierId: j['s'] as String,
        epochMs: (j['t'] as num).toInt(),
        ref: j['r'] as String,
        debit: (j['d'] as num?)?.toDouble() ?? 0,
        credit: (j['c'] as num?)?.toDouble() ?? 0,
        mode: j['m'] as String?,
      );
}
