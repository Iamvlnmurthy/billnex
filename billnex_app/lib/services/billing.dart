import 'dart:math' as math;

/// One line as seen by the calculator.
class BillInput {
  final double price; // unit price (tax-inclusive or exclusive per [taxInclusive])
  final double qty; // supports weighed/loose goods (e.g. 0.5 kg)
  final double gstRate; // %, e.g. 0/5/12/18/28
  final double lineDiscount; // absolute ₹ off this line
  const BillInput({required this.price, required this.qty, required this.gstRate, this.lineDiscount = 0});
}

/// Formats a quantity: integer when whole (2), else trimmed decimals (0.5, 1.25).
String qtyLabel(num q) {
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

const _ones = [
  '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
  'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
];
const _tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

String _twoDigit(int n) {
  if (n < 20) return _ones[n];
  return '${_tens[n ~/ 10]}${n % 10 == 0 ? '' : ' ${_ones[n % 10]}'}';
}

String _threeDigit(int n) {
  final h = n ~/ 100, r = n % 100;
  return [
    if (h > 0) '${_ones[h]} Hundred',
    if (r > 0) _twoDigit(r),
  ].join(' ');
}

/// Rupees amount in words, Indian numbering (crore/lakh/thousand), e.g.
/// 1,25,430 → "One Lakh Twenty Five Thousand Four Hundred Thirty Rupees Only".
/// Includes paise when non-zero. Handles negatives (returns/credit notes) by
/// prefixing "Minus", carries paise that rounds to 100 into rupees, and never
/// overflows the number tables. Used on invoices ("Amount in words").
String amountInWords(num amount) {
  final negative = amount < 0;
  final v = amount.abs();
  var rupees = v.floor();
  var paise = ((v - rupees) * 100).round();
  if (paise >= 100) {
    // e.g. 99.995 → paise 100: carry into rupees rather than overflow _twoDigit.
    rupees += paise ~/ 100;
    paise %= 100;
  }
  if (rupees == 0 && paise == 0) return 'Zero Rupees Only';

  final parts = <String>[];
  final crore = rupees ~/ 10000000;
  final lakh = (rupees % 10000000) ~/ 100000;
  final thousand = (rupees % 100000) ~/ 1000;
  final hundred = rupees % 1000;
  // _threeDigit safely covers 0–999, so crore up to 999 (₹999 crore) is fine.
  if (crore > 0) parts.add('${crore < 100 ? _twoDigit(crore) : _threeDigit(crore)} Crore');
  if (lakh > 0) parts.add('${_twoDigit(lakh)} Lakh');
  if (thousand > 0) parts.add('${_twoDigit(thousand)} Thousand');
  if (hundred > 0) parts.add(_threeDigit(hundred));

  final rupeeWords = parts.isEmpty ? '' : '${parts.join(' ')} Rupees';
  final paiseWords = paise > 0 ? '${rupeeWords.isEmpty ? '' : ' and '}${_twoDigit(paise)} Paise' : '';
  final body = rupeeWords.isEmpty && paiseWords.isEmpty ? 'Zero Rupees' : '$rupeeWords$paiseWords';
  return '${negative ? 'Minus ' : ''}$body Only'.trim();
}

/// Per-GST-rate aggregation (for the HSN/tax summary on the invoice).
class RateBucket {
  double taxable = 0;
  double tax = 0;
}

/// Fully computed bill (PRD BNX-0104/0105/0106): correct per-item GST with
/// CGST/SGST split, tax-inclusive or exclusive pricing, line + bill discounts
/// (bill discount allocated proportionally over taxable value), and round-off.
class BillTotals {
  final double gross; // sum of price*qty before any discount
  final double lineDiscountTotal;
  final double billDiscount;
  final double taxable; // net taxable value after all discounts
  final double tax; // total GST
  final double roundOff;
  final double total; // rounded grand total
  final Map<double, RateBucket> byRate;

  const BillTotals({
    required this.gross,
    required this.lineDiscountTotal,
    required this.billDiscount,
    required this.taxable,
    required this.tax,
    required this.roundOff,
    required this.total,
    required this.byRate,
  });

  double get cgst => tax / 2;
  double get sgst => tax / 2;
  double get discountTotal => lineDiscountTotal + billDiscount;

  static const empty = BillTotals(gross: 0, lineDiscountTotal: 0, billDiscount: 0, taxable: 0, tax: 0, roundOff: 0, total: 0, byRate: {});
}

double _r2(double v) => (v * 100).round() / 100;

BillTotals computeBill({required List<BillInput> lines, required bool taxInclusive, double billDiscount = 0, bool roundToUnit = true}) {
  if (lines.isEmpty) return BillTotals.empty;

  double gross = 0, lineDiscTotal = 0;
  // Stage 1: per-line taxable + tax after line discounts.
  final taxables = <double>[];
  final taxes = <double>[];
  final rates = <double>[];
  double taxableSum = 0;
  for (final l in lines) {
    final g = l.price * l.qty;
    gross += g;
    final disc = math.min(l.lineDiscount, g);
    lineDiscTotal += disc;
    final net = g - disc;
    double taxable, tax;
    if (taxInclusive) {
      taxable = net / (1 + l.gstRate / 100);
      tax = net - taxable;
    } else {
      taxable = net;
      tax = net * l.gstRate / 100;
    }
    taxables.add(taxable);
    taxes.add(tax);
    rates.add(l.gstRate);
    taxableSum += taxable;
  }

  // Stage 2: allocate bill discount proportionally over taxable, recompute tax.
  final bd = billDiscount.clamp(0, taxableSum).toDouble();
  final factor = taxableSum > 0 ? (taxableSum - bd) / taxableSum : 1.0;

  final byRate = <double, RateBucket>{};
  double finalTaxable = 0, finalTax = 0;
  for (var i = 0; i < lines.length; i++) {
    final t = _r2(taxables[i] * factor);
    final x = _r2(taxes[i] * factor);
    finalTaxable += t;
    finalTax += x;
    final b = byRate.putIfAbsent(rates[i], RateBucket.new);
    b.taxable += t;
    b.tax += x;
  }

  final raw = finalTaxable + finalTax;
  final total = roundToUnit ? raw.roundToDouble() : _r2(raw);
  final roundOff = _r2(total - raw);

  return BillTotals(gross: _r2(gross), lineDiscountTotal: _r2(lineDiscTotal), billDiscount: _r2(bd), taxable: _r2(finalTaxable), tax: _r2(finalTax), roundOff: roundOff, total: total, byRate: byRate);
}
