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
}
