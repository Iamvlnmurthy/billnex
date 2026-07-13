import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../models/sale.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/receipt.dart';

class TemplatesScreen extends StatelessWidget {
  final AppState state;
  const TemplatesScreen({required this.state, super.key});

  static const _demo = [RcptLine('Product one', 2, 620), RcptLine('Service item', 1, 620)];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const PageHeader(
                'Print templates',
                '11 ready designs for regular A4 printers and thermal rolls. Set one default per business — WYSIWYG with the live receipt in Billing.',
                trailing: Badge2('A4 · 80mm · 58mm'),
              ),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 300),
                    itemBuilder: (context, i) => _TemplateCard(state: state, template: kTemplates[i], demo: _demo),
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

Sale _sampleSale(AppState state, String templateId) => Sale(
  invoiceNo: '#SAMPLE',
  epochMs: DateTime.now().millisecondsSinceEpoch,
  businessName: state.shopName,
  templateId: templateId,
  lines: const [SaleLine('Product one', 2, 310), SaleLine('Service item', 1, 620)],
  subtotal: 1240,
  gst: 62,
  total: 1302,
  paymentMode: 'Cash',
);

class _TemplateCard extends StatelessWidget {
  final AppState state;
  final InvoiceTemplate template;
  final List<RcptLine> demo;
  const _TemplateCard({required this.state, required this.template, required this.demo});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
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
                      Text(template.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(
                        template.desc,
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
                          tooltip: 'Print sample',
                          onPressed: () => PdfService.run(context, () => PdfService.printSale(_sampleSale(state, template.id)), failure: "Couldn't print the sample"),
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
                            'Default',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bx.pos),
                          ),
                        ],
                      )
                    else
                      TextButton(
                        onPressed: () {
                          state.setTemplate(template.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Default template set')));
                        },
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 44)),
                        child: const Text('Set default', style: TextStyle(fontSize: 12)),
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
