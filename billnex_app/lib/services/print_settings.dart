import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-output-type printer preferences, kept separate for A4 invoices and
/// thermal receipts (a shop often has both a laser/inkjet and a 58/80mm roll
/// printer). Self-contained on SharedPreferences so it doesn't touch the main
/// data store. Values are optional — absent means "ask via the system dialog".
class PrintSettings {
  static const _kWidth = 'print.thermal.width'; // 58 or 80 (mm)
  static const _kBtMac = 'print.bt.mac';
  static const _kBtName = 'print.bt.name';
  static const _kBtOn = 'print.bt.enabled';
  static String _url(bool thermal) => thermal ? 'print.thermal.url' : 'print.a4.url';
  static String _name(bool thermal) => thermal ? 'print.thermal.name' : 'print.a4.name';

  /// Thermal roll width in millimetres (58 or 80). Defaults to 80mm.
  static Future<double> thermalWidthMm() async {
    final p = await SharedPreferences.getInstance();
    final w = p.getDouble(_kWidth);
    return (w == 58.0 || w == 80.0) ? w! : 80.0;
  }

  static Future<void> setThermalWidthMm(double mm) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kWidth, mm == 58.0 ? 58.0 : 80.0);
  }

  /// The saved default printer for this output type, or null if none set.
  static Future<Printer?> printerFor({required bool thermal}) async {
    final p = await SharedPreferences.getInstance();
    final url = p.getString(_url(thermal));
    if (url == null || url.isEmpty) return null;
    return Printer(url: url, name: p.getString(_name(thermal)) ?? url);
  }

  /// The saved printer's display name for this type, or null.
  static Future<String?> printerName({required bool thermal}) async {
    final p = await SharedPreferences.getInstance();
    final url = p.getString(_url(thermal));
    if (url == null || url.isEmpty) return null;
    return p.getString(_name(thermal)) ?? url;
  }

  /// Saves (or clears, when [printer] is null) the default printer for a type.
  static Future<void> setPrinter({required bool thermal, Printer? printer}) async {
    final p = await SharedPreferences.getInstance();
    if (printer == null) {
      await p.remove(_url(thermal));
      await p.remove(_name(thermal));
    } else {
      await p.setString(_url(thermal), printer.url);
      await p.setString(_name(thermal), printer.name);
    }
  }

  // ── Bluetooth ESC-POS printer (direct, for thermal receipts) ──
  /// True when the merchant has chosen to route thermal receipts to a paired
  /// Bluetooth ESC-POS printer instead of the system print dialog.
  static Future<bool> btEnabled() async {
    final p = await SharedPreferences.getInstance();
    return (p.getBool(_kBtOn) ?? false) && (p.getString(_kBtMac)?.isNotEmpty ?? false);
  }

  static Future<String?> btMac() async => (await SharedPreferences.getInstance()).getString(_kBtMac);
  static Future<String?> btName() async => (await SharedPreferences.getInstance()).getString(_kBtName);

  static Future<void> setBt({required bool enabled, String? mac, String? name}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kBtOn, enabled);
    if (mac != null) await p.setString(_kBtMac, mac);
    if (name != null) await p.setString(_kBtName, name);
  }

  static Future<void> clearBt() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kBtMac);
    await p.remove(_kBtName);
    await p.setBool(_kBtOn, false);
  }
}
