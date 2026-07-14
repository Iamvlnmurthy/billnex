import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/print_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

/// Lets the merchant pick a *separate* default printer for A4 invoices and for
/// thermal receipts, plus the thermal roll width. When a default is set, prints
/// go straight there; otherwise the system dialog opens on the correct paper.
class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({super.key});
  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  double _width = 80;
  String? _a4Name;
  String? _thermalName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final w = await PrintSettings.thermalWidthMm();
    final a4 = await PrintSettings.printerName(thermal: false);
    final th = await PrintSettings.printerName(thermal: true);
    if (!mounted) return;
    setState(() {
      _width = w;
      _a4Name = a4;
      _thermalName = th;
      _loading = false;
    });
  }

  Future<void> _pick({required bool thermal}) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final printer = await Printing.pickPrinter(context: context);
    if (printer == null) return; // cancelled
    await PrintSettings.setPrinter(thermal: thermal, printer: printer);
    await _reload();
    messenger.showSnackBar(SnackBar(content: Text(l.printerSaved)));
  }

  Future<void> _clear({required bool thermal}) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await PrintSettings.setPrinter(thermal: thermal);
    await _reload();
    messenger.showSnackBar(SnackBar(content: Text(l.printerCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.printerSettings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PageHeader(l.printerSettings, l.printerSettingsSub),
                        _printerCard(bx, l, thermal: false, label: l.invoicePrinterA4, icon: Icons.description_outlined, name: _a4Name),
                        const SizedBox(height: 14),
                        _printerCard(bx, l, thermal: true, label: l.receiptPrinterThermal, icon: Icons.receipt_outlined, name: _thermalName),
                        const SizedBox(height: 14),
                        // Thermal roll width
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.thermalRollWidth, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                SegmentedButton<double>(
                                  segments: const [
                                    ButtonSegment(value: 58, label: Text('58 mm')),
                                    ButtonSegment(value: 80, label: Text('80 mm')),
                                  ],
                                  selected: {_width},
                                  onSelectionChanged: (s) async {
                                    setState(() => _width = s.first);
                                    await PrintSettings.setThermalWidthMm(s.first);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l.printerSettingsNote, style: TextStyle(fontSize: 12.5, color: bx.faint, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _printerCard(BxColors bx, L l, {required bool thermal, required String label, required IconData icon, required String? name}) {
    final isSet = name != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: bx.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(isSet ? Icons.check_circle : Icons.help_outline, size: 14, color: isSet ? bx.pos : bx.faint),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              isSet ? name : l.printerAskEachTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, color: bx.muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _pick(thermal: thermal),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: Text(l.choosePrinter),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                if (isSet) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: () => _clear(thermal: thermal), child: Text(l.useSystemDialog)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
