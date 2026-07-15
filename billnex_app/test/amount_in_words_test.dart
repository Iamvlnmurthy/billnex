import 'package:flutter_test/flutter_test.dart';
import 'package:billnex/services/billing.dart';

/// Indian-numbering amount-in-words used on invoices ("Amount in words: …").
void main() {
  test('whole rupees, Indian grouping', () {
    expect(amountInWords(0), 'Zero Rupees Only');
    expect(amountInWords(5), 'Five Rupees Only');
    expect(amountInWords(15), 'Fifteen Rupees Only');
    expect(amountInWords(147), 'One Hundred Forty Seven Rupees Only');
    expect(amountInWords(1000), 'One Thousand Rupees Only');
    expect(amountInWords(1302), 'One Thousand Three Hundred Two Rupees Only');
    expect(amountInWords(125430), 'One Lakh Twenty Five Thousand Four Hundred Thirty Rupees Only');
    expect(amountInWords(10000000), 'One Crore Rupees Only');
    expect(amountInWords(12345678), 'One Crore Twenty Three Lakh Forty Five Thousand Six Hundred Seventy Eight Rupees Only');
  });

  test('paise included when non-zero', () {
    expect(amountInWords(99.5), 'Ninety Nine Rupees and Fifty Paise Only');
    expect(amountInWords(0.75), 'Seventy Five Paise Only');
    expect(amountInWords(100.25), 'One Hundred Rupees and Twenty Five Paise Only');
  });

  test('paise rounding to 100 carries into rupees (no crash)', () {
    expect(amountInWords(99.995), 'One Hundred Rupees Only'); // was a RangeError crash
    expect(amountInWords(0.999), 'One Rupees Only');
  });

  test('negative totals (returns/credit notes) read as Minus', () {
    expect(amountInWords(-590), 'Minus Five Hundred Ninety Rupees Only'); // was garbage via % on negatives
    expect(amountInWords(-1250.5), 'Minus One Thousand Two Hundred Fifty Rupees and Fifty Paise Only');
  });

  test('large values ≥ 100 crore do not crash', () {
    expect(amountInWords(1230000000), 'One Hundred Twenty Three Crore Rupees Only');
  });
}
