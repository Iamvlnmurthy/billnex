/// A customer / account holder (PRD: BNX-0220 Customer profile).
class Customer {
  final String id;
  final String name;
  final String mobile;
  final String? gstin;
  final double creditLimit;
  final bool consent; // BNX-0235 opt-in

  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    this.gstin,
    this.creditLimit = 0,
    this.consent = false,
  });

  Customer copyWith({String? name, String? mobile, String? gstin, double? creditLimit, bool? consent}) => Customer(
        id: id,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        gstin: gstin ?? this.gstin,
        creditLimit: creditLimit ?? this.creditLimit,
        consent: consent ?? this.consent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'm': mobile,
        'g': gstin,
        'cl': creditLimit,
        'c': consent,
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        name: j['n'] as String,
        mobile: (j['m'] ?? '') as String,
        gstin: j['g'] as String?,
        creditLimit: (j['cl'] as num?)?.toDouble() ?? 0,
        consent: j['c'] == true,
      );
}

enum LedgerKind { creditSale, collection, openingDue }

extension LedgerKindX on LedgerKind {
  String get label => switch (this) {
        LedgerKind.creditSale => 'Credit sale',
        LedgerKind.collection => 'Collection',
        LedgerKind.openingDue => 'Opening due',
      };
  String get code => name;
  static LedgerKind fromCode(String c) => LedgerKind.values.firstWhere((k) => k.name == c, orElse: () => LedgerKind.creditSale);
}

/// A single movement on a customer's account.
/// [debit] increases what the customer owes; [credit] reduces it.
class LedgerEntry {
  final String customerId;
  final int epochMs;
  final LedgerKind kind;
  final String ref; // invoice / receipt number
  final double debit;
  final double credit;
  final String? mode; // payment mode for collections

  const LedgerEntry({
    required this.customerId,
    required this.epochMs,
    required this.kind,
    required this.ref,
    this.debit = 0,
    this.credit = 0,
    this.mode,
  });

  double get delta => debit - credit;

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toJson() => {
        'c': customerId,
        't': epochMs,
        'k': kind.code,
        'r': ref,
        'd': debit,
        'cr': credit,
        'm': mode,
      };

  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
        customerId: j['c'] as String,
        epochMs: (j['t'] as num).toInt(),
        kind: LedgerKindX.fromCode(j['k'] as String),
        ref: j['r'] as String,
        debit: (j['d'] as num?)?.toDouble() ?? 0,
        credit: (j['cr'] as num?)?.toDouble() ?? 0,
        mode: j['m'] as String?,
      );
}
