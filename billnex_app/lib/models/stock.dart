import '../data/catalog.dart';

/// A batch/lot for expiry-tracked items (PRD BNX-0154).
class Batch {
  final String batchNo;
  final int expiryMs;
  double qty;
  Batch(this.batchNo, this.expiryMs, this.qty);

  bool isExpired(int nowMs) => expiryMs < nowMs;
  bool isNearExpiry(int nowMs) => !isExpired(nowMs) && expiryMs - nowMs < const Duration(days: 60).inMilliseconds;

  String get expiryLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toJson() => {'b': batchNo, 'e': expiryMs, 'q': qty};
  factory Batch.fromJson(Map<String, dynamic> j) => Batch(j['b'] as String, (j['e'] as num).toInt(), (j['q'] as num).toDouble());
}

/// A stock-tracked catalogue item (PRD BNX-0021, BNX-0137 stock ledger).
class StockItem {
  final String sku; // unique key (demo: product name)
  String name;
  String unit;
  double price;
  double cost;
  double qty;
  double reorderLevel;
  double gstRate; // % GST for this item (0/5/12/18/28)
  String? barcode;
  String? category;
  String? hsn;
  bool stockTracked; // false for services (salon, repair) — no stock ledger
  final List<Batch> batches;

  StockItem({
    required this.sku,
    required this.name,
    required this.unit,
    required this.price,
    this.cost = 0,
    this.qty = 0,
    this.reorderLevel = 10,
    this.gstRate = 5,
    this.barcode,
    this.category,
    this.hsn,
    this.stockTracked = true,
    List<Batch>? batches,
  }) : batches = batches ?? [];

  bool get low => stockTracked && qty <= reorderLevel;
  bool get out => stockTracked && qty <= 0;

  Product toProduct() => Product(name, unit, price);

  Map<String, dynamic> toJson() => {
    's': sku,
    'n': name,
    'u': unit,
    'p': price,
    'c': cost,
    'q': qty,
    'r': reorderLevel,
    'g': gstRate,
    'bc': barcode,
    'cat': category,
    'hsn': hsn,
    'st': stockTracked,
    'b': batches.map((e) => e.toJson()).toList(),
  };

  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
    sku: j['s'] as String,
    name: j['n'] as String,
    unit: j['u'] as String,
    price: (j['p'] as num).toDouble(),
    cost: (j['c'] as num?)?.toDouble() ?? 0,
    qty: (j['q'] as num).toDouble(),
    reorderLevel: (j['r'] as num?)?.toDouble() ?? 10,
    gstRate: (j['g'] as num?)?.toDouble() ?? 5,
    barcode: j['bc'] as String?,
    category: j['cat'] as String?,
    hsn: j['hsn'] as String?,
    stockTracked: j['st'] as bool? ?? true,
    batches: (j['b'] as List?)?.map((e) => Batch.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  );
}

enum MoveKind { opening, sale, adjustment, purchase, damage }

extension MoveKindX on MoveKind {
  String get label => switch (this) {
    MoveKind.opening => 'Opening stock',
    MoveKind.sale => 'Sale',
    MoveKind.adjustment => 'Adjustment',
    MoveKind.purchase => 'Purchase',
    MoveKind.damage => 'Damage / wastage',
  };
  static MoveKind fromCode(String c) => MoveKind.values.firstWhere((k) => k.name == c, orElse: () => MoveKind.adjustment);
}

/// An immutable stock movement (PRD BNX-0138 movement history).
class StockMovement {
  final String sku;
  final int epochMs;
  final MoveKind kind;
  final double delta; // +in / -out
  final String ref;
  final String? reason;

  const StockMovement({required this.sku, required this.epochMs, required this.kind, required this.delta, required this.ref, this.reason});

  String get dateLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} · $hh:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  Map<String, dynamic> toJson() => {'s': sku, 't': epochMs, 'k': kind.name, 'd': delta, 'r': ref, 'x': reason};
  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
    sku: j['s'] as String,
    epochMs: (j['t'] as num).toInt(),
    kind: MoveKindX.fromCode(j['k'] as String),
    delta: (j['d'] as num).toDouble(),
    ref: j['r'] as String,
    reason: j['x'] as String?,
  );
}
