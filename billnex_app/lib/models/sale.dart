/// A single posted line on a sale.
class SaleLine {
  final String name;
  final int qty;
  final double price;
  const SaleLine(this.name, this.qty, this.price);
  double get amount => price * qty;

  Map<String, dynamic> toJson() => {'n': name, 'q': qty, 'p': price};
  factory SaleLine.fromJson(Map<String, dynamic> j) =>
      SaleLine(j['n'] as String, (j['q'] as num).toInt(), (j['p'] as num).toDouble());
}

/// An immutable posted sale (PRD: no silent deletion; reversal via document).
class Sale {
  final String invoiceNo;
  final int epochMs;
  final String businessName;
  final String templateId;
  final List<SaleLine> lines;
  final double subtotal;
  final double gst;
  final double total;
  final String paymentMode;
  final String? sellerGstin; // captured at post time so reprints stay correct
  final String? sellerPhone;
  final String? sellerAddress;

  const Sale({
    required this.invoiceNo,
    required this.epochMs,
    required this.businessName,
    required this.templateId,
    required this.lines,
    required this.subtotal,
    required this.gst,
    required this.total,
    required this.paymentMode,
    this.sellerGstin,
    this.sellerPhone,
    this.sellerAddress,
  });

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ap = d.hour < 12 ? 'AM' : 'PM';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year} · $hh:$mm $ap';
  }

  int get itemCount => lines.fold(0, (a, l) => a + l.qty);

  Map<String, dynamic> toJson() => {
        'no': invoiceNo,
        't': epochMs,
        'b': businessName,
        'tpl': templateId,
        'l': lines.map((e) => e.toJson()).toList(),
        's': subtotal,
        'g': gst,
        'tot': total,
        'pm': paymentMode,
        'sg': sellerGstin,
        'sp': sellerPhone,
        'sa': sellerAddress,
      };

  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
        invoiceNo: j['no'] as String,
        epochMs: (j['t'] as num).toInt(),
        businessName: j['b'] as String,
        templateId: j['tpl'] as String,
        lines: (j['l'] as List).map((e) => SaleLine.fromJson(e as Map<String, dynamic>)).toList(),
        subtotal: (j['s'] as num).toDouble(),
        gst: (j['g'] as num).toDouble(),
        total: (j['tot'] as num).toDouble(),
        paymentMode: j['pm'] as String,
        sellerGstin: j['sg'] as String?,
        sellerPhone: j['sp'] as String?,
        sellerAddress: j['sa'] as String?,
      );
}
