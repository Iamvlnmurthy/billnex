import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/catalog.dart';
import '../models/sale.dart';

/// Turns a posted [Sale] into a printable/shareable PDF for any of the 11
/// templates. A4 templates use a page; thermal templates use a narrow roll
/// (80mm / 58mm) with the same layout model as the on-screen receipt.
class PdfService {
  static PdfColor _accent(String id) => switch (id) {
        'classic' => const PdfColor.fromInt(0xFF0F766E),
        'minimal' => const PdfColor.fromInt(0xFF111111),
        'modern' => const PdfColor.fromInt(0xFFD97706),
        'bilingual' => const PdfColor.fromInt(0xFF4338CA),
        'wholesale' => const PdfColor.fromInt(0xFF0369A1),
        'service' => const PdfColor.fromInt(0xFF7C3AED),
        'quotation' => const PdfColor.fromInt(0xFF0D9488),
        'delivery' => const PdfColor.fromInt(0xFF475569),
        _ => const PdfColor.fromInt(0xFF0F766E),
      };

  static String _title(String id) => switch (id) {
        'minimal' => 'Invoice',
        'bilingual' => 'TAX INVOICE / कर बिल',
        'wholesale' => 'WHOLESALE INVOICE',
        'service' => 'SERVICE INVOICE',
        'quotation' => 'QUOTATION',
        'delivery' => 'DELIVERY CHALLAN',
        'modern' => 'INVOICE',
        _ => 'TAX INVOICE',
      };

  static String _rupee(num n) {
    final s = n.round().toString();
    if (s.length <= 3) return 'Rs $s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return 'Rs ${parts.join(',')},$last3';
  }

  static Future<pw.Document> build(Sale sale) async {
    final tpl = templateById(sale.templateId);
    final doc = pw.Document(title: 'BillNex ${sale.invoiceNo}');
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);

    if (tpl.size == PaperSize.a4) {
      doc.addPage(pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (c) => _a4Body(sale, tpl),
      ));
    } else {
      final width = tpl.size == PaperSize.mm58 ? 58 * PdfPageFormat.mm : 80 * PdfPageFormat.mm;
      doc.addPage(pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(width, double.infinity, marginAll: 6 * PdfPageFormat.mm),
        build: (c) => tpl.id == 'kot' ? _kotBody(sale) : _thermalBody(sale),
      ));
    }
    return doc;
  }

  static Future<void> printSale(Sale sale) async {
    final doc = await build(sale);
    await Printing.layoutPdf(onLayout: (f) => doc.save(), name: 'BillNex-${sale.invoiceNo}');
  }

  /// A one-page business summary report (PRD BNX-0311 Excel/PDF export).
  static Future<void> shareReport({
    required String businessName,
    required Map<String, String> summary,
    required Map<String, double> paymentMix,
    required List<({String name, int qty, double value})> items,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: font, bold: bold));
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (c) => [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(businessName, style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0055D1))),
          pw.Text('Business Report', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        ]),
        pw.Divider(color: const PdfColor.fromInt(0xFF146CFF), thickness: 1.5),
        pw.SizedBox(height: 12),
        pw.Text('Summary', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Wrap(spacing: 24, runSpacing: 8, children: summary.entries.map((e) => pw.Container(
          width: 150,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(e.key, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.Text(e.value, style: const pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          ]),
        )).toList()),
        pw.SizedBox(height: 16),
        pw.Text('Payment mix', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300), children: [
          for (final e in paymentMix.entries)
            pw.TableRow(children: [_cell(e.key), _cell(_rupee(e.value), right: true)]),
        ]),
        pw.SizedBox(height: 16),
        pw.Text('Item-wise sales', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300), children: [
          pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: [_cell('Item'), _cell('Qty', right: true), _cell('Value', right: true)]),
          for (final r in items) pw.TableRow(children: [_cell(r.name), _cell('${r.qty}', right: true), _cell(_rupee(r.value), right: true)]),
        ]),
      ],
    ));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-Report.pdf');
  }

  static pw.Widget _cell(String s, {bool right = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(s, textAlign: right ? pw.TextAlign.right : pw.TextAlign.left, style: const pw.TextStyle(fontSize: 10)));

  static Future<void> shareSale(Sale sale) async {
    final doc = await build(sale);
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-${sale.invoiceNo}.pdf');
  }

  // ------------------------------------------------------------------ A4
  static pw.Widget _a4Body(Sale sale, InvoiceTemplate tpl) {
    final accent = _accent(tpl.id);
    final modern = tpl.id == 'modern';
    final bilingual = tpl.id == 'bilingual';

    pw.Widget header() {
      final left = pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(sale.businessName,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: modern ? PdfColors.white : accent)),
        pw.Text('GSTIN 36ABCDE1234F1Z5 · Telangana',
            style: pw.TextStyle(fontSize: 9, color: modern ? PdfColors.white : PdfColors.grey700)),
      ]);
      final right = pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Text(_title(tpl.id),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: modern ? PdfColors.white : PdfColors.black)),
        pw.Text('${sale.invoiceNo} · ${sale.dateLabel}',
            style: pw.TextStyle(fontSize: 9, color: modern ? PdfColors.white : PdfColors.grey700)),
      ]);
      final row = pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [left, right]);
      if (modern) {
        return pw.Container(color: accent, padding: const pw.EdgeInsets.all(16), child: row);
      }
      return pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2))),
        child: row,
      );
    }

    final band = _band(tpl.id);

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
      header(),
      if (band != null)
        pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(band, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        ),
      pw.SizedBox(height: 14),
      pw.Table(
        border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey300)),
        columnWidths: {0: const pw.FlexColumnWidth(4), 1: const pw.FlexColumnWidth(), 2: const pw.FlexColumnWidth(1.4)},
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400))),
            children: [
              _th(bilingual ? 'Item / वस्तु' : 'Description'),
              _th('Qty', align: pw.TextAlign.center),
              _th(bilingual ? 'Amount / राशि' : 'Amount', align: pw.TextAlign.right),
            ],
          ),
          for (final l in sale.lines)
            pw.TableRow(children: [
              _td(l.name),
              _td('${l.qty}', align: pw.TextAlign.center),
              _td(_rupee(l.amount), align: pw.TextAlign.right),
            ]),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.SizedBox(
          width: 180,
          child: pw.Column(children: [
            _kv('Subtotal', _rupee(sale.subtotal)),
            _kv('GST @5%', _rupee(sale.gst)),
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 4),
              padding: const pw.EdgeInsets.only(top: 6),
              decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: accent, width: 1.5))),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(tpl.id == 'quotation' ? 'Est.' : 'Total',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accent)),
                pw.Text(_rupee(sale.total),
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accent)),
              ]),
            ),
          ]),
        ),
      ),
      pw.Spacer(),
      pw.Divider(color: PdfColors.grey300),
      pw.Text(
        tpl.id == 'quotation' ? 'Thank you — reply to confirm this order.' : 'Thank you for your business · Generated by BillNex',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    ]);
  }

  static String? _band(String id) => switch (id) {
        'service' => 'Device: Redmi 13C · IMEI 3548…921 · Technician: Suresh · Warranty: 90 days',
        'wholesale' => 'Buyer: Sri Traders · Credit 30 days · Route R-04 · Scheme: 10+1',
        'quotation' => 'Valid till 25 Jul 2026 · Prices subject to stock · Not a tax invoice',
        'delivery' => 'Dispatch to: MG Road branch · Vehicle TS09 AB 1234 · Invoice to follow',
        _ => null,
      };

  // -------------------------------------------------------------- thermal
  static pw.Widget _thermalBody(Sale sale) {
    return pw.Column(children: [
      pw.Text(sale.businessName, style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.Text('GSTIN 36ABCDE1234F1Z5', style: const pw.TextStyle(fontSize: 7)),
      pw.Text('Ph 98480 00000', style: const pw.TextStyle(fontSize: 7)),
      _dash(),
      pw.Text('${sale.invoiceNo}  ${sale.dateLabel}', style: const pw.TextStyle(fontSize: 7)),
      _dash(),
      for (final l in sale.lines)
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Expanded(child: pw.Text(l.name, style: const pw.TextStyle(fontSize: 8))),
          pw.Text(' ${l.qty} ', style: const pw.TextStyle(fontSize: 8)),
          pw.Text(_rupee(l.amount), style: const pw.TextStyle(fontSize: 8)),
        ]),
      _dash(),
      _thKv('GST', _rupee(sale.gst)),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('TOTAL', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text(_rupee(sale.total), style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ]),
      _dash(),
      pw.SizedBox(height: 4),
      pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: 'upi://pay?pa=billnex@upi&am=${sale.total}', width: 54, height: 54),
      pw.SizedBox(height: 4),
      pw.Text('Scan to pay · Thank you!', style: const pw.TextStyle(fontSize: 7)),
    ]);
  }

  static pw.Widget _kotBody(Sale sale) {
    return pw.Column(children: [
      pw.Text('KITCHEN — KOT', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.Text('${sale.invoiceNo} · ${sale.dateLabel}', style: const pw.TextStyle(fontSize: 8)),
      pw.Container(height: 2, color: PdfColors.black, margin: const pw.EdgeInsets.symmetric(vertical: 6)),
      for (final l in sale.lines)
        pw.Row(children: [
          pw.Text('${l.qty} x  ', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(child: pw.Text(l.name, style: const pw.TextStyle(fontSize: 11))),
        ]),
      pw.Container(height: 2, color: PdfColors.black, margin: const pw.EdgeInsets.symmetric(vertical: 6)),
      pw.Text('** NO PRICE — KITCHEN COPY **', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
    ]);
  }

  // ---- small helpers ----
  static pw.Widget _th(String s, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(s, textAlign: align, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
  static pw.Widget _td(String s, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3), child: pw.Text(s, textAlign: align, style: const pw.TextStyle(fontSize: 10)));
  static pw.Widget _kv(String k, String v) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(k, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(v, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ]));
  static pw.Widget _thKv(String k, String v) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(k, style: const pw.TextStyle(fontSize: 8)),
        pw.Text(v, style: const pw.TextStyle(fontSize: 8)),
      ]);
  static pw.Widget _dash() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text('------------------------------', style: const pw.TextStyle(fontSize: 8), maxLines: 1, overflow: pw.TextOverflow.clip));
}
