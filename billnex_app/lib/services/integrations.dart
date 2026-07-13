import '../models/sale.dart';

/// Dynamic UPI payment intent (PRD BNX-0119). Builds the `upi://pay` deep link
/// and QR payload for a specific amount — no gateway account needed for the
/// intent itself (the merchant VPA is business config). Launch it with
/// url_launcher, or encode the same string as a QR on the receipt.
class UpiService {
  static String buildIntent({
    required String payeeVpa, // e.g. billnex@upi
    required String payeeName,
    required double amount,
    String? note,
    String? txnRef,
  }) {
    final params = <String, String>{'pa': payeeVpa, 'pn': payeeName, 'am': amount.toStringAsFixed(2), 'cu': 'INR', 'tr': ?txnRef, 'tn': ?note};
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return 'upi://pay?$query';
  }
}

/// WhatsApp invoice share via a wa.me deep link (PRD BNX-0072). Pure string
/// builder — opens the user's WhatsApp with the message prefilled. For the
/// official Business API (templates, delivery status) see docs/INTEGRATIONS.md.
class WhatsAppService {
  /// [phone] in international format without '+', e.g. 9198480xxxxx.
  static String invoiceLink({required String phone, required String message}) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'https://wa.me/$digits?text=${Uri.encodeComponent(message)}';
  }

  static String defaultMessage(Sale sale) => 'Thank you! Invoice ${sale.invoiceNo} · Total ₹${sale.total.toStringAsFixed(2)} from ${sale.businessName}.';
}

/// GST e-invoice (IRP) payload builder (PRD BNX-0111). Produces the JSON body
/// submitted to an approved GSP to obtain an IRN + signed QR. Building the
/// payload needs no account; submission does (see docs/INTEGRATIONS.md).
class EInvoiceService {
  static Map<String, dynamic> buildPayload({
    required Sale sale,
    required String sellerGstin,
    required String sellerLegalName,
    required String sellerStateCode,
    String? buyerGstin,
    String buyerLegalName = 'Walk-in',
    String buyerStateCode = '36',
    String hsnDefault = '9999',
  }) {
    return {
      'Version': '1.1',
      'TranDtls': {'TaxSch': 'GST', 'SupTyp': buyerGstin == null ? 'B2C' : 'B2B'},
      'DocDtls': {'Typ': 'INV', 'No': sale.invoiceNo.replaceAll('#', ''), 'Dt': _ddmmyyyy(sale.epochMs)},
      'SellerDtls': {'Gstin': sellerGstin, 'LglNm': sellerLegalName, 'Stcd': sellerStateCode},
      'BuyerDtls': {'Gstin': buyerGstin ?? 'URP', 'LglNm': buyerLegalName, 'Pos': buyerStateCode, 'Stcd': buyerStateCode},
      'ItemList': [
        for (var i = 0; i < sale.lines.length; i++)
          {
            'SlNo': '${i + 1}',
            'PrdDesc': sale.lines[i].name,
            'IsServc': 'N',
            'HsnCd': hsnDefault,
            'Qty': sale.lines[i].qty,
            'Unit': 'NOS',
            'UnitPrice': sale.lines[i].price,
            'TotAmt': sale.lines[i].amount,
            'AssAmt': sale.lines[i].amount,
            'GstRt': 5.0,
            'TotItemVal': sale.lines[i].amount,
          },
      ],
      'ValDtls': {'AssVal': sale.subtotal, 'CgstVal': _r(sale.gst / 2), 'SgstVal': _r(sale.gst / 2), 'TotInvVal': sale.total},
    };
  }

  static double _r(double v) => (v * 100).round() / 100;
  static String _ddmmyyyy(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

/// ESC/POS thermal printer seam (PRD §15). The app already prints via the
/// `printing` package (PDF → any printer incl. thermal). This interface is for
/// a *direct* ESC/POS byte stream over Bluetooth/USB when a certified model
/// needs raw commands (cutter, drawer kick, code pages). Implement with e.g.
/// `esc_pos_utils` + `print_bluetooth_thermal`; keep it behind this interface.
abstract interface class EscPosPrinter {
  Future<List<String>> discover(); // device ids/names
  Future<bool> connect(String deviceId);
  Future<void> printReceipt(Sale sale, {int widthMm = 58});
  Future<void> openDrawer();
  Future<void> cut();
}
