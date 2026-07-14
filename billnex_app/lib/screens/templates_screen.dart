import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/catalog.dart';
import '../data/catalog_i18n.dart';
import '../state/app_state.dart';
import '../models/sale.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/receipt.dart';

class TemplatesScreen extends StatelessWidget {
  final AppState state;
  const TemplatesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final demo = [RcptLine(l.demoProductLine, 2, 620), RcptLine(l.demoServiceLine, 1, 620)];
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              PageHeader(l.printTemplates, l.templatesSubtitle, trailing: const Badge2('A4 · 80mm · 58mm')),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 900
                      ? 3
                      : c.maxWidth > 560
                      ? 2
                      : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kTemplates.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 336),
                    itemBuilder: (context, i) => _TemplateCard(state: state, template: kTemplates[i], demo: demo),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Sale _sampleSale(BuildContext context, AppState state, String templateId) {
  final l = L.of(context);
  return Sale(
    invoiceNo: '#SAMPLE',
    epochMs: DateTime.now().millisecondsSinceEpoch,
    businessName: state.shopName,
    templateId: templateId,
    lines: [SaleLine(l.demoProductLine, 2, 310), SaleLine(l.demoServiceLine, 1, 620)],
    subtotal: 1240,
    gst: 62,
    total: 1302,
    paymentMode: 'Cash',
  );
}

class _TemplateCard extends StatelessWidget {
  final AppState state;
  final InvoiceTemplate template;
  final List<RcptLine> demo;
  const _TemplateCard({required this.state, required this.template, required this.demo});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final isDefault = state.template == template.id;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // preview
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: bx.surface2,
              border: Border(bottom: BorderSide(color: bx.border)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Bx.radius)),
            ),
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxWidth: 400,
              maxHeight: 400,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Transform.scale(
                  scale: 0.6,
                  alignment: Alignment.topCenter,
                  child: ReceiptView(templateId: template.id, businessName: state.shopName, lines: demo, subtotal: 1240, gst: 62, total: 1302),
                ),
              ),
            ),
          ),
          // info
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(templateName(l, template.id), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(
                        templateDesc(l, template.id),
                        style: TextStyle(fontSize: 11.5, color: bx.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Badge2(template.size.label),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: l.printSample,
                          onPressed: () => PdfService.run(context, () => PdfService.printSale(_sampleSale(context, state, template.id)), failure: l.printSampleFail),
                          icon: Icon(Icons.print_outlined, size: 18, color: bx.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (isDefault)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 15, color: bx.pos),
                          const SizedBox(width: 4),
                          Text(
                            l.defaultLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bx.pos),
                          ),
                        ],
                      )
                    else
                      TextButton(
                        onPressed: () {
                          state.setTemplate(template.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.defaultTemplateSet)));
                        },
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 44)),
                        child: Text(l.setDefault, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
