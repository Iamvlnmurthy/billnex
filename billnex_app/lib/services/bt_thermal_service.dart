import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/sale.dart';
import 'billing.dart';

/// A paired Bluetooth printer (name + MAC).
class BtPrinter {
  final String name;
  final String mac;
  const BtPrinter(this.name, this.mac);
}

/// Direct Bluetooth ESC-POS printing for cheap 2"/3" thermal printers — the
/// kind Android's system print framework can't drive. Generates ESC-POS bytes
/// from a [Sale] and streams them over the SPP connection.
///
/// NOTE: requires a real device with Bluetooth; there is nothing to connect to
/// on an emulator. All methods degrade gracefully (return false / empty).
class BtThermalService {
  /// Whether the device's Bluetooth radio is on.
  static Future<bool> isEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (_) {
      return false;
    }
  }

  /// Printers already paired in Android Settings (we don't do raw discovery —
  /// the merchant pairs once in system settings, then picks here).
  static Future<List<BtPrinter>> paired() async {
    try {
      final list = await PrintBluetoothThermal.pairedBluetooths;
      return [for (final d in list) BtPrinter(d.name, d.macAdress)];
    } catch (_) {
      return const [];
    }
  }

  static Future<bool> get isConnected async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> connect(String mac) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    } catch (_) {
      return false;
    }
  }

  static Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
  }

  /// Print a sale as an ESC-POS receipt on the connected printer. Ensures a
  /// connection to [mac] first. Returns true when the bytes were written.
  static Future<bool> printSale(Sale sale, {required String mac, int widthMm = 58}) async {
    if (!await isConnected) {
      final ok = await connect(mac);
      if (!ok) return false;
    }
    final bytes = await _receiptBytes(sale, widthMm);
    try {
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (_) {
      return false;
    }
  }

  /// A short "connection OK" test slip — used by the Print Settings screen.
  static Future<bool> printTest(String businessName, {required String mac, int widthMm = 58}) async {
    if (!await isConnected) {
      final ok = await connect(mac);
      if (!ok) return false;
    }
    final profile = await CapabilityProfile.load();
    final gen = Generator(widthMm == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);
    final bytes = <int>[
      ...gen.text(businessName, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2)),
      ...gen.text('BillNex test print', styles: const PosStyles(align: PosAlign.center)),
      ...gen.hr(),
      ...gen.text('Bluetooth printer connected OK', styles: const PosStyles(align: PosAlign.center)),
      ...gen.feed(2),
      ...gen.cut(),
    ];
    try {
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (_) {
      return false;
    }
  }

  // Plain "Rs" money (avoids the ₹ glyph, which many thermal fonts lack).
  static String _rs(num n) {
    final neg = n < 0;
    final s = n.round().abs().toString();
    final sign = neg ? '-' : '';
    if (s.length <= 3) return 'Rs $sign$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return 'Rs $sign${parts.join(',')},$last3';
  }

  static Future<List<int>> _receiptBytes(Sale sale, int widthMm) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(widthMm == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);
    final b = <int>[];
    b.addAll(gen.text(sale.businessName, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2)));
    if ((sale.sellerGstin ?? '').isNotEmpty) b.addAll(gen.text('GSTIN ${sale.sellerGstin}', styles: const PosStyles(align: PosAlign.center)));
    if ((sale.sellerPhone ?? '').isNotEmpty) b.addAll(gen.text('Ph ${sale.sellerPhone}', styles: const PosStyles(align: PosAlign.center)));
    b.addAll(gen.hr());
    b.addAll(gen.text('${sale.invoiceNo}   ${sale.dateLabel}'));
    b.addAll(gen.hr());
    for (final l in sale.lines) {
      b.addAll(gen.row([
        PosColumn(text: l.name, width: 6),
        PosColumn(text: 'x${qtyLabel(l.qty)}', styles: const PosStyles(align: PosAlign.right)), // width 2 (default)
        PosColumn(text: _rs(l.amount), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    b.addAll(gen.hr());
    void kv(String k, String v, {bool bold = false}) => b.addAll(gen.row([
          PosColumn(text: k, width: 7, styles: PosStyles(bold: bold)),
          PosColumn(text: v, width: 5, styles: PosStyles(align: PosAlign.right, bold: bold)),
        ]));
    if (sale.discount > 0) kv('Sub-total', _rs(sale.subtotal + sale.discount));
    if (sale.discount > 0) kv('Discount', '- ${_rs(sale.discount)}');
    kv('Taxable', _rs(sale.subtotal));
    kv('CGST', _rs(sale.cgst));
    kv('SGST', _rs(sale.sgst));
    if (sale.otherCharges > 0) kv(sale.chargesLabel.isEmpty ? 'Charges' : sale.chargesLabel, _rs(sale.otherCharges));
    if (sale.roundOff != 0) kv('Round off', _rs(sale.roundOff));
    kv('TOTAL', _rs(sale.total), bold: true);
    b.addAll(gen.text(amountInWords(sale.total), styles: const PosStyles(align: PosAlign.center)));
    b.addAll(gen.hr());
    b.addAll(gen.text('Thank you! Visit again', styles: const PosStyles(align: PosAlign.center)));
    b.addAll(gen.feed(2));
    b.addAll(gen.cut());
    return b;
  }
}
