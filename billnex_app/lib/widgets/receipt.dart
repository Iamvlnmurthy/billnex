import 'package:flutter/material.dart';
import '../data/catalog.dart';
import 'common.dart';

/// A single line on a receipt.
class RcptLine {
  final String name;
  final int qty;
  final double amount;
  const RcptLine(this.name, this.qty, this.amount);
}

/// Renders any of the 11 invoice templates as an on-screen preview.
///
/// This is the same layout model the PDF/ESC-POS export will follow, so the
/// live receipt on POS is a true WYSIWYP preview of what prints.
class ReceiptView extends StatelessWidget {
  final String templateId;
  final String businessName;
  final String? gstin;
  final String? phone;
  final String? address;
  final List<RcptLine> lines;
  final double subtotal;
  final double gst;
  final double total;

  const ReceiptView({
    super.key,
    required this.templateId,
    required this.businessName,
    this.gstin,
    this.phone,
    this.address,
    required this.lines,
    required this.subtotal,
    required this.gst,
    required this.total,
  });

  String get _subline => [
        if ((gstin ?? '').trim().isNotEmpty) 'GSTIN ${gstin!.trim()}',
        if ((phone ?? '').trim().isNotEmpty) 'Ph ${phone!.trim()}',
        if ((gstin ?? '').trim().isEmpty && (phone ?? '').trim().isEmpty && (address ?? '').trim().isNotEmpty) address!.trim(),
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final t = templateById(templateId);
    final content = switch (t.id) {
      'thermal58' || 'thermal80' => _thermal(t.id == 'thermal58'),
      'kot' => _kot(),
      _ => _a4(t),
    };
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFF111111), fontSize: 12, height: 1.35),
          child: content,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- thermal
  Widget _thermal(bool narrow) {
    const dash = Color(0xFF999999);
    return Container(
      width: narrow ? 200 : 280,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(businessName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), textAlign: TextAlign.center),
        if (_subline.isNotEmpty) Text(_subline, style: const TextStyle(fontSize: 9.5), textAlign: TextAlign.center),
        const _Dashed(dash),
        ...lines.map((l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(children: [
                Expanded(child: Text(l.name, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                Text('${l.qty}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                SizedBox(width: 64, child: Text(money(l.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
              ]),
            )),
        const _Dashed(dash),
        _kv('GST', money(gst), false),
        _kv('TOTAL', money(total), true),
        const _Dashed(dash),
        Container(
          width: 52, height: 52,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: CustomPaint(painter: _QrPainter()),
        ),
        const Text('Scan to pay · Thank you!', style: TextStyle(fontSize: 9.5)),
      ]),
    );
  }

  Widget _kot() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('KITCHEN — KOT #204', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const Text('Table 6 · Steward: Ravi · 7:42 PM', style: TextStyle(fontSize: 9.5)),
        Container(height: 2, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 8)),
        ...lines.map((l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Text('${l.qty} ×  ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Expanded(child: Text(l.name, style: const TextStyle(fontSize: 13))),
              ]),
            )),
        Container(height: 2, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 8)),
        const Text('** NO PRICE — KITCHEN COPY **', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  // ------------------------------------------------------------------- A4
  Widget _a4(InvoiceTemplate t) {
    final accent = _accentFor(t.id);
    final title = _titleFor(t.id);
    final modern = t.id == 'modern';
    final bilingual = t.id == 'bilingual';

    final header = modern
        ? Container(
            color: accent,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: _headerRow(title, accent, onColor: Colors.white),
          )
        : Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: accent, width: 2))),
            child: _headerRow(title, accent),
          );

    final extra = _extraBand(t.id);

    return Container(
      width: 340,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        header,
        if (extra != null) extra else const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _tableHeader(bilingual),
            const Divider(height: 8, color: Color(0xFFDDDDDD)),
            ...lines.map((l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(child: Text(l.name, style: const TextStyle(fontSize: 11))),
                    SizedBox(width: 28, child: Text('${l.qty}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                    SizedBox(width: 70, child: Text(money(l.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11))),
                  ]),
                )),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: Column(children: [
                  _kvGrey('Subtotal', money(subtotal)),
                  _kvGrey('GST @5%', money(gst)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: accent, width: 1.5))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(t.id == 'quotation' ? 'Est.' : 'Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: accent)),
                      Text(money(total), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: accent)),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.id == 'quotation' ? 'Thank you — reply to confirm this order.' : 'Thank you for your business · Goods once sold…',
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF888888)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _headerRow(String title, Color accent, {Color? onColor}) {
    final nameColor = onColor ?? accent;
    final subColor = onColor?.withValues(alpha: 0.85) ?? const Color(0xFF555555);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(businessName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: nameColor)),
          if (_subline.isNotEmpty) Text(_subline, style: TextStyle(fontSize: 9.5, color: subColor)),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1, color: onColor ?? const Color(0xFF111111))),
        Text('#INV-2048 · 11 Jul 2026', style: TextStyle(fontSize: 9.5, color: subColor)),
      ]),
    ]);
  }

  Widget? _extraBand(String id) {
    final (text, bg) = switch (id) {
      'service' => ('Device: Redmi 13C · IMEI 3548…921 · Technician: Suresh · Warranty: 90 days', const Color(0xFFFAF7FF)),
      'wholesale' => ('Buyer: Sri Traders · Credit 30 days · Route R-04 · Scheme: 10+1', const Color(0xFFF0F7FB)),
      'quotation' => ('Valid till 25 Jul 2026 · Prices subject to stock · Not a tax invoice', const Color(0xFFF0FAF8)),
      'delivery' => ('Dispatch to: MG Road branch · Vehicle TS09 AB 1234 · Invoice to follow', const Color(0xFFF6F7F9)),
      _ => (null, Colors.white),
    };
    if (text == null) return null;
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text, style: const TextStyle(fontSize: 9.5, color: Color(0xFF555555))),
    );
  }

  Widget _tableHeader(bool bilingual) {
    final th = bilingual ? ['Item / वस्तु', 'Qty', 'Amount / राशि'] : ['Description', 'Qty', 'Amount'];
    return Row(children: [
      Expanded(child: Text(th[0], style: const TextStyle(fontSize: 10.5, color: Color(0xFF666666)))),
      SizedBox(width: 28, child: Text(th[1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: Color(0xFF666666)))),
      SizedBox(width: 70, child: Text(th[2], textAlign: TextAlign.right, style: const TextStyle(fontSize: 10.5, color: Color(0xFF666666)))),
    ]);
  }

  static Widget _kv(String k, String v, bool bold) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(fontSize: bold ? 13 : 11, fontWeight: bold ? FontWeight.w800 : FontWeight.w400, fontFamily: 'monospace')),
          Text(v, style: TextStyle(fontSize: bold ? 13 : 11, fontWeight: bold ? FontWeight.w800 : FontWeight.w400, fontFamily: 'monospace')),
        ],
      );

  static Widget _kvGrey(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
          Text(v, style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
        ]),
      );

  static Color _accentFor(String id) => switch (id) {
        'classic' => const Color(0xFF0F766E),
        'minimal' => const Color(0xFF111111),
        'modern' => const Color(0xFFD97706),
        'bilingual' => const Color(0xFF4338CA),
        'wholesale' => const Color(0xFF0369A1),
        'service' => const Color(0xFF7C3AED),
        'quotation' => const Color(0xFF0D9488),
        'delivery' => const Color(0xFF475569),
        _ => const Color(0xFF0F766E),
      };

  static String _titleFor(String id) => switch (id) {
        'classic' => 'TAX INVOICE',
        'minimal' => 'Invoice',
        'modern' => 'INVOICE',
        'bilingual' => 'TAX INVOICE / कर बिल',
        'wholesale' => 'WHOLESALE INVOICE',
        'service' => 'SERVICE INVOICE',
        'quotation' => 'QUOTATION',
        'delivery' => 'DELIVERY CHALLAN',
        _ => 'TAX INVOICE',
      };
}

class _Dashed extends StatelessWidget {
  final Color color;
  const _Dashed(this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomPaint(size: const Size(double.infinity, 1), painter: _DashPainter(color)),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0, gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// A tiny faux-QR block so the receipt reads as "has a QR".
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF111111);
    const n = 7;
    final cell = size.width / n;
    // deterministic pattern
    const bits = [
      0x7F, 0x41, 0x5D, 0x5D, 0x41, 0x7F, 0x2A,
    ];
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final on = ((bits[y] >> x) & 1) == 1 || ((x + y) % 3 == 0);
        if (on) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
