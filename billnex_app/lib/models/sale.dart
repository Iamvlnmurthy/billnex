/// A single posted line on a sale.
class SaleLine {
  final String name;
  final int qty;
  final double price;
  final double gstRate;
  final double discount;
  const SaleLine(this.name, this.qty, this.price, {this.gstRate = 5, this.discount = 0});
  double get amount => price * qty;

  Map<String, dynamic> toJson() => {'n': name, 'q': qty, 'p': price, 'g': gstRate, 'd': discount};
  factory SaleLine.fromJson(Map<String, dynamic> j) => SaleLine(
        j['n'] as String,
        (j['q'] as num).toInt(),
        (j['p'] as num).toDouble(),
        gstRate: (j['g'] as num?)?.toDouble() ?? 5,
        discount: (j['d'] as num?)?.toDouble() ?? 0,
      );
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
  final double discount;
  final double roundOff;
  final bool taxInclusive;
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
    this.discount = 0,
    this.roundOff = 0,
    this.taxInclusive = true,
    required this.paymentMode,
    this.sellerGstin,
    this.sellerPhone,
    this.sellerAddress,
  });

  double get cgst => gst / 2;
  double get sgst => gst / 2;

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
        'disc': discount,
        'ro': roundOff,
        'ti': taxInclusive,
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
        discount: (j['disc'] as num?)?.toDouble() ?? 0,
        roundOff: (j['ro'] as num?)?.toDouble() ?? 0,
        taxInclusive: j['ti'] != false,
        paymentMode: j['pm'] as String,
        sellerGstin: j['sg'] as String?,
        sellerPhone: j['sp'] as String?,
        sellerAddress: j['sa'] as String?,
      );
}
