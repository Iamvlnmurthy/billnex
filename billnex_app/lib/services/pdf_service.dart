import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/catalog.dart';
import '../models/sale.dart';
import 'billing.dart';
import 'bt_thermal_service.dart';
import 'integrations.dart';
import 'print_settings.dart';

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

  static String _sellerLine(Sale sale) => [
    if ((sale.sellerGstin ?? '').trim().isNotEmpty) 'GSTIN ${sale.sellerGstin!.trim()}',
    if ((sale.sellerAddress ?? '').trim().isNotEmpty) sale.sellerAddress!.trim(),
    if ((sale.sellerPhone ?? '').trim().isNotEmpty) 'Ph ${sale.sellerPhone!.trim()}',
  ].join(' · ');

  // Bundled Inter faces — loaded once and reused. No network dependency, so
  // reprint/share works fully offline (previously used PdfGoogleFonts, which
  // fetched over the network and failed silently with no connection).
  static pw.Font? _base, _bold;
  static Future<pw.ThemeData> _theme() async {
    _base ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    _bold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
    return pw.ThemeData.withFont(base: _base!, bold: _bold!);
  }

  /// The page geometry a template prints on. Thermal rolls honour the user's
  /// saved roll width (58/80mm) so the print dialog defaults to the roll, not A4.
  static Future<PdfPageFormat> formatFor(InvoiceTemplate tpl) async {
    if (tpl.size == PaperSize.a4) return PdfPageFormat.a4;
    // Template dictates 58 vs 80, but let the saved thermal-width preference win
    // when the template is the generic thermal one.
    final mm = tpl.size == PaperSize.mm58 ? 58.0 : await PrintSettings.thermalWidthMm();
    return PdfPageFormat(mm * PdfPageFormat.mm, double.infinity, marginAll: 6 * PdfPageFormat.mm);
  }

  static Future<pw.Document> build(Sale sale) async {
    final tpl = templateById(sale.templateId);
    final doc = pw.Document(title: 'BillNex ${sale.invoiceNo}');
    final theme = await _theme();

    if (tpl.size == PaperSize.a4) {
      doc.addPage(pw.Page(theme: theme, pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32), build: (c) => _a4Body(sale, tpl)));
    } else {
      doc.addPage(
        pw.Page(
          theme: theme,
          pageFormat: await formatFor(tpl),
          build: (c) => tpl.id == 'kot' ? _kotBody(sale) : _thermalBody(sale),
        ),
      );
    }
    return doc;
  }

  /// Prints a sale. If the merchant has saved a default printer for this output
  /// type (A4 invoice vs thermal receipt) it prints straight there; otherwise it
  /// opens the system dialog — but always pre-set to the correct paper size, so a
  /// thermal receipt no longer defaults to A4.
  static Future<void> printSale(Sale sale) async {
    final tpl = templateById(sale.templateId);
    final isThermal = tpl.size != PaperSize.a4;
    // Direct Bluetooth ESC-POS path for thermal receipts, when configured.
    if (isThermal && tpl.id != 'kot' && await PrintSettings.btEnabled()) {
      final mac = await PrintSettings.btMac();
      final widthMm = (await PrintSettings.thermalWidthMm()).round();
      if (mac != null && await BtThermalService.printSale(sale, mac: mac, widthMm: widthMm)) {
        return; // printed over Bluetooth
      }
      // fall through to the system dialog if the BT print didn't go through
    }
    final doc = await build(sale);
    final format = await formatFor(tpl);
    final saved = await PrintSettings.printerFor(thermal: isThermal);
    if (saved != null) {
      await Printing.directPrintPdf(printer: saved, onLayout: (f) => doc.save(), name: 'BillNex-${sale.invoiceNo}', format: format);
    } else {
      await Printing.layoutPdf(onLayout: (f) => doc.save(), name: 'BillNex-${sale.invoiceNo}', format: format);
    }
  }

  /// Runs a PDF action and surfaces a friendly message on failure instead of
  /// throwing into the void (reprint/share/export are fire-and-forget taps).
  static Future<void> run(BuildContext context, Future<void> Function() action, {String failure = "Couldn't generate the PDF"}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  /// A one-page business summary report (PRD BNX-0311 Excel/PDF export).
  static Future<void> shareReport({
    required String businessName,
    required Map<String, String> summary,
    required Map<String, double> paymentMix,
    required List<({String name, double qty, double value})> items,
  }) async {
    final doc = pw.Document(theme: await _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (c) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                businessName,
                style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0055D1)),
              ),
              pw.Text('Business Report', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
          pw.Divider(color: const PdfColor.fromInt(0xFF146CFF), thickness: 1.5),
          pw.SizedBox(height: 12),
          pw.Text('Summary', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 24,
            runSpacing: 8,
            children: summary.entries
                .map(
                  (e) => pw.Container(
                    width: 150,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(e.key, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        pw.Text(e.value, style: const pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Payment mix', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              for (final e in paymentMix.entries) pw.TableRow(children: [_cell(e.key), _cell(_rupee(e.value), right: true)]),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Item-wise sales', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [_cell('Item'), _cell('Qty', right: true), _cell('Value', right: true)],
              ),
              for (final r in items) pw.TableRow(children: [_cell(r.name), _cell(qtyLabel(r.qty), right: true), _cell(_rupee(r.value), right: true)]),
            ],
          ),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-Report.pdf');
  }

  /// A GST filing aid: GSTR-1 rate-wise (B2C) + HSN-wise summary as one PDF.
  static Future<void> shareGstReport({
    required String businessName,
    String? gstin,
    required List<({double rate, double taxable, double cgst, double sgst, int invoices})> gstr1,
    required List<({String hsn, double rate, double qty, double taxable, double tax})> hsn,
  }) async {
    final doc = pw.Document(theme: await _theme());
    double g(double Function(({double rate, double taxable, double cgst, double sgst, int invoices})) f) => gstr1.fold(0.0, (a, r) => a + f(r));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (c) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(businessName, style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0055D1))),
                  if ((gstin ?? '').isNotEmpty) pw.Text('GSTIN $gstin', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Text('GST Summary', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
          pw.Divider(color: const PdfColor.fromInt(0xFF146CFF), thickness: 1.5),
          pw.SizedBox(height: 12),
          pw.Text('GSTR-1 · Rate-wise outward supplies (B2C)', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [_cell('GST %'), _cell('Taxable', right: true), _cell('CGST', right: true), _cell('SGST', right: true), _cell('Total Tax', right: true), _cell('Invoices', right: true)],
              ),
              for (final r in gstr1)
                pw.TableRow(children: [
                  _cell('${r.rate.toStringAsFixed(0)}%'),
                  _cell(_rupee(r.taxable), right: true),
                  _cell(_rupee(r.cgst), right: true),
                  _cell(_rupee(r.sgst), right: true),
                  _cell(_rupee(r.cgst + r.sgst), right: true),
                  _cell('${r.invoices}', right: true),
                ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _cell('Total'),
                  _cell(_rupee(g((r) => r.taxable)), right: true),
                  _cell(_rupee(g((r) => r.cgst)), right: true),
                  _cell(_rupee(g((r) => r.sgst)), right: true),
                  _cell(_rupee(g((r) => r.cgst + r.sgst)), right: true),
                  _cell('', right: true),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text('Sale summary by HSN/SAC', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [_cell('HSN/SAC'), _cell('GST %', right: true), _cell('Qty', right: true), _cell('Taxable', right: true), _cell('Tax', right: true)],
              ),
              for (final r in hsn)
                pw.TableRow(children: [
                  _cell(r.hsn),
                  _cell('${r.rate.toStringAsFixed(0)}%', right: true),
                  _cell(qtyLabel(r.qty), right: true),
                  _cell(_rupee(r.taxable), right: true),
                  _cell(_rupee(r.tax), right: true),
                ]),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text('Computed from posted sales · B2C (no buyer GSTIN captured) · Generated by BillNex', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-GST-Summary.pdf');
  }

  /// Per-customer account statement (khata) as a shareable PDF: every bill and
  /// payment with a running balance, and the closing due.
  static Future<void> sharePartyStatement({
    required String businessName,
    String? gstin,
    required String customerName,
    String? customerMobile,
    required List<({String date, String particulars, double debit, double credit, double balance})> rows,
    required double closing,
  }) async {
    final doc = pw.Document(theme: await _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (c) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(businessName, style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0055D1))),
                  if ((gstin ?? '').isNotEmpty) pw.Text('GSTIN $gstin', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Text('Account Statement', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
          pw.Divider(color: const PdfColor.fromInt(0xFF146CFF), thickness: 1.5),
          pw.SizedBox(height: 8),
          pw.Text(customerName, style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          if ((customerMobile ?? '').isNotEmpty) pw.Text('Ph $customerMobile', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(4), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(2), 4: const pw.FlexColumnWidth(2.4)},
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [_cell('Date'), _cell('Particulars'), _cell('Debit', right: true), _cell('Credit', right: true), _cell('Balance', right: true)],
              ),
              for (final r in rows)
                pw.TableRow(children: [
                  _cell(r.date),
                  _cell(r.particulars),
                  _cell(r.debit == 0 ? '' : _rupee(r.debit), right: true),
                  _cell(r.credit == 0 ? '' : _rupee(r.credit), right: true),
                  _cell(_rupee(r.balance), right: true),
                ]),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Text('Closing balance: ${_rupee(closing)}', style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Amount in words: ${amountInWords(closing.abs())}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey300),
          pw.Text('Generated by BillNex', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-Statement-$customerName.pdf');
  }

  static pw.Widget _cell(String s, {bool right = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: pw.Text(s, textAlign: right ? pw.TextAlign.right : pw.TextAlign.left, style: const pw.TextStyle(fontSize: 10)),
  );

  static Future<void> shareSale(Sale sale) async {
    final doc = await build(sale);
    await Printing.sharePdf(bytes: await doc.save(), filename: 'BillNex-${sale.invoiceNo}.pdf');
  }

  /// Opens WhatsApp with a prefilled invoice summary. When [phone] is given it
  /// opens that chat directly; otherwise WhatsApp shows the contact picker. The
  /// PDF itself still goes via [shareSale] (WhatsApp appears in that share sheet).
  static Future<void> whatsAppSale(Sale sale, {String? phone, String? message}) async {
    final url = WhatsAppService.invoiceLink(phone: phone ?? '', message: message ?? WhatsAppService.defaultMessage(sale));
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('WhatsApp not available');
    }
  }

  /// Opens WhatsApp with any prefilled text (reorder lists, reminders). When
  /// [phone] is empty, WhatsApp shows the contact picker.
  static Future<void> whatsAppText(String message, {String phone = ''}) async {
    final url = WhatsAppService.invoiceLink(phone: phone, message: message);
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('WhatsApp not available');
    }
  }

  // ------------------------------------------------------------------ A4
  static pw.Widget _a4Body(Sale sale, InvoiceTemplate tpl) {
    final accent = _accent(tpl.id);
    final modern = tpl.id == 'modern';
    final bilingual = tpl.id == 'bilingual';

    pw.Widget header() {
      final left = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            sale.businessName,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: modern ? PdfColors.white : accent),
          ),
          if (_sellerLine(sale).isNotEmpty) pw.Text(_sellerLine(sale), style: pw.TextStyle(fontSize: 9, color: modern ? PdfColors.white : PdfColors.grey700)),
        ],
      );
      final right = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            _title(tpl.id),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: modern ? PdfColors.white : PdfColors.black),
          ),
          pw.Text('${sale.invoiceNo} · ${sale.dateLabel}', style: pw.TextStyle(fontSize: 9, color: modern ? PdfColors.white : PdfColors.grey700)),
        ],
      );
      final row = pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [left, right]);
      if (modern) {
        return pw.Container(color: accent, padding: const pw.EdgeInsets.all(16), child: row);
      }
      return pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2)),
        ),
        child: row,
      );
    }

    final band = _band(tpl.id);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
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
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
              ),
              children: [
                _th(bilingual ? 'Item / वस्तु' : 'Description'),
                _th('Qty', align: pw.TextAlign.center),
                _th(bilingual ? 'Amount / राशि' : 'Amount', align: pw.TextAlign.right),
              ],
            ),
            for (final l in sale.lines)
              pw.TableRow(
                children: [
                  _td(l.name),
                  _td(qtyLabel(l.qty), align: pw.TextAlign.center),
                  _td(_rupee(l.amount), align: pw.TextAlign.right),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 180,
            child: pw.Column(
              children: [
                _kv('Taxable', _rupee(sale.subtotal)),
                if (sale.discount > 0) _kv('Discount', '- ${_rupee(sale.discount)}'),
                _kv('CGST', _rupee(sale.cgst)),
                _kv('SGST', _rupee(sale.sgst)),
                if (sale.roundOff != 0) _kv('Round off', _rupee(sale.roundOff)),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 4),
                  padding: const pw.EdgeInsets.only(top: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: accent, width: 1.5)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        tpl.id == 'quotation' ? 'Est.' : 'Total',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accent),
                      ),
                      pw.Text(
                        _rupee(sale.total),
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        // Amount in words (expected on every Indian invoice).
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300), bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                const pw.TextSpan(text: 'Amount in words: ', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: amountInWords(sale.total), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              ],
            ),
          ),
        ),
        pw.Spacer(),
        // Terms + authorised signatory block.
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Terms & Conditions', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    tpl.id == 'quotation' ? 'Prices valid as quoted · Reply to confirm this order.' : 'Goods once sold will not be taken back or exchanged.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 24),
            pw.Column(
              children: [
                pw.Text('For ${sale.businessName}', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 22),
                pw.Container(width: 130, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey500)))),
                pw.SizedBox(height: 2),
                pw.Text('Authorised Signatory', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey300),
        pw.Text(
          tpl.id == 'quotation' ? 'Thank you — reply to confirm this order.' : 'Thank you for your business · Generated by BillNex',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
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
    return pw.Column(
      children: [
        pw.Text(sale.businessName, style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        if ((sale.sellerGstin ?? '').isNotEmpty) pw.Text('GSTIN ${sale.sellerGstin}', style: const pw.TextStyle(fontSize: 7)),
        if ((sale.sellerPhone ?? '').isNotEmpty) pw.Text('Ph ${sale.sellerPhone}', style: const pw.TextStyle(fontSize: 7)),
        _dash(),
        pw.Text('${sale.invoiceNo}  ${sale.dateLabel}', style: const pw.TextStyle(fontSize: 7)),
        _dash(),
        // Fixed-width qty/amount columns so figures line up cleanly on the roll
        // (spaceBetween + Expanded left them ragged). Right-aligned like a bill.
        for (final l in sale.lines)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: pw.Text(l.name, style: const pw.TextStyle(fontSize: 8))),
              pw.SizedBox(
                width: 26,
                child: pw.Text('x${qtyLabel(l.qty)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(
                width: 54,
                child: pw.Text(_rupee(l.amount), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          ),
        _dash(),
        _thKv('Taxable', _rupee(sale.subtotal)),
        if (sale.discount > 0) _thKv('Discount', '- ${_rupee(sale.discount)}'),
        _thKv('CGST', _rupee(sale.cgst)),
        _thKv('SGST', _rupee(sale.sgst)),
        if (sale.roundOff != 0) _thKv('Round off', _rupee(sale.roundOff)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOTAL', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text(_rupee(sale.total), style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(amountInWords(sale.total), style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
        _dash(),
        pw.SizedBox(height: 4),
        pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: 'upi://pay?pa=billnex@upi&am=${sale.total}', width: 54, height: 54),
        pw.SizedBox(height: 4),
        pw.Text('Scan to pay · Thank you!', style: const pw.TextStyle(fontSize: 7)),
      ],
    );
  }

  static pw.Widget _kotBody(Sale sale) {
    return pw.Column(
      children: [
        pw.Text('KITCHEN — KOT', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text('${sale.invoiceNo} · ${sale.dateLabel}', style: const pw.TextStyle(fontSize: 8)),
        pw.Container(height: 2, color: PdfColors.black, margin: const pw.EdgeInsets.symmetric(vertical: 6)),
        for (final l in sale.lines)
          pw.Row(
            children: [
              pw.Text('${qtyLabel(l.qty)} x  ', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(l.name, style: const pw.TextStyle(fontSize: 11))),
            ],
          ),
        pw.Container(height: 2, color: PdfColors.black, margin: const pw.EdgeInsets.symmetric(vertical: 6)),
        pw.Text('** NO PRICE — KITCHEN COPY **', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  // ---- small helpers ----
  static pw.Widget _th(String s, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      s,
      textAlign: align,
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
  );
  static pw.Widget _td(String s, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(s, textAlign: align, style: const pw.TextStyle(fontSize: 10)),
  );
  static pw.Widget _kv(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(k, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(v, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    ),
  );
  static pw.Widget _thKv(String k, String v) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(k, style: const pw.TextStyle(fontSize: 8)),
      pw.Text(v, style: const pw.TextStyle(fontSize: 8)),
    ],
  );
  static pw.Widget _dash() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Text('------------------------------', style: const pw.TextStyle(fontSize: 8), maxLines: 1, overflow: pw.TextOverflow.clip),
  );
}
