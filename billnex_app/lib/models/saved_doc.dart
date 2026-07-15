import 'sale.dart';

/// A saved, non-posted document — an Estimate/Quotation or a Sale Order. Unlike
/// a [Sale] it does not touch stock or the khata until it is *converted* into an
/// invoice. Holds the same line/total shape so it reuses the PDF engine.
enum DocType { estimate, order }

extension DocTypeX on DocType {
  String get code => name;
  static DocType fromCode(String c) => DocType.values.firstWhere((t) => t.name == c, orElse: () => DocType.estimate);
  /// Template used to render this doc as a PDF.
  String get templateId => this == DocType.estimate ? 'quotation' : 'classic';
}

class SavedDoc {
  final String id;
  final DocType type;
  final String number; // EST-1 / ORD-1
  final int epochMs;
  final String? customerId;
  final String customerName;
  final List<SaleLine> lines;
  final double subtotal;
  final double gst;
  final double total;
  final double discount;
  final double roundOff;
  final bool taxInclusive;
  final double otherCharges;
  final String chargesLabel;
  final String? transportNote;
  final String? businessName;
  final String? sellerGstin;
  final String? sellerPhone;
  final String? sellerAddress;

  const SavedDoc({
    required this.id,
    required this.type,
    required this.number,
    required this.epochMs,
    this.customerId,
    this.customerName = 'Walk-in',
    required this.lines,
    required this.subtotal,
    required this.gst,
    required this.total,
    this.discount = 0,
    this.roundOff = 0,
    this.taxInclusive = true,
    this.otherCharges = 0,
    this.chargesLabel = '',
    this.transportNote,
    this.businessName,
    this.sellerGstin,
    this.sellerPhone,
    this.sellerAddress,
  });

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Render/convert helper: a [Sale] view of this document with the given
  /// invoice number (or the doc number for a preview) and payment mode.
  Sale toSale({String? invoiceNo, String paymentMode = 'Cash'}) => Sale(
        invoiceNo: invoiceNo ?? number,
        epochMs: epochMs,
        businessName: businessName ?? '',
        templateId: type.templateId,
        lines: lines,
        subtotal: subtotal,
        gst: gst,
        total: total,
        discount: discount,
        roundOff: roundOff,
        taxInclusive: taxInclusive,
        paymentMode: paymentMode,
        sellerGstin: sellerGstin,
        sellerPhone: sellerPhone,
        sellerAddress: sellerAddress,
        otherCharges: otherCharges,
        chargesLabel: chargesLabel,
        transportNote: transportNote,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ty': type.code,
        'no': number,
        't': epochMs,
        'cid': customerId,
        'cn': customerName,
        'l': lines.map((e) => e.toJson()).toList(),
        's': subtotal,
        'g': gst,
        'tot': total,
        'disc': discount,
        'ro': roundOff,
        'ti': taxInclusive,
        'oc': otherCharges,
        'ocl': chargesLabel,
        'tn': transportNote,
        'bn': businessName,
        'sg': sellerGstin,
        'sp': sellerPhone,
        'sa': sellerAddress,
      };

  factory SavedDoc.fromJson(Map<String, dynamic> j) => SavedDoc(
        id: j['id'] as String,
        type: DocTypeX.fromCode(j['ty'] as String),
        number: j['no'] as String,
        epochMs: (j['t'] as num).toInt(),
        customerId: j['cid'] as String?,
        customerName: (j['cn'] as String?) ?? 'Walk-in',
        lines: (j['l'] as List).map((e) => SaleLine.fromJson(e as Map<String, dynamic>)).toList(),
        subtotal: (j['s'] as num).toDouble(),
        gst: (j['g'] as num).toDouble(),
        total: (j['tot'] as num).toDouble(),
        discount: (j['disc'] as num?)?.toDouble() ?? 0,
        roundOff: (j['ro'] as num?)?.toDouble() ?? 0,
        taxInclusive: j['ti'] != false,
        otherCharges: (j['oc'] as num?)?.toDouble() ?? 0,
        chargesLabel: (j['ocl'] as String?) ?? '',
        transportNote: j['tn'] as String?,
        businessName: j['bn'] as String?,
        sellerGstin: j['sg'] as String?,
        sellerPhone: j['sp'] as String?,
        sellerAddress: j['sa'] as String?,
      );
}
