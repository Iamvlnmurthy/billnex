import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_io.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

/// Data import / export — CSV in and out for the shop owner. Export mirrors the
/// Reports screen's save-file pattern; import picks a file, parses it safely and
/// applies rows through AppState's existing public mutators (no business logic
/// lives here). Nothing here can crash on a malformed file.
class DataIoScreen extends StatefulWidget {
  final AppState state;
  const DataIoScreen({required this.state, super.key});
  @override
  State<DataIoScreen> createState() => _DataIoScreenState();
}

class _DataIoScreenState extends State<DataIoScreen> {
  bool _busy = false;
  AppState get state => widget.state;

  // ── Export ───────────────────────────────────────────────────────────────
  Future<void> _export(String fileName, String csv, bool hasData) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!hasData) {
      messenger.showSnackBar(SnackBar(content: Text(l.exportNothing)));
      return;
    }
    setState(() => _busy = true);
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: l.saveFileTitle(fileName),
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(csv)),
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      messenger.showSnackBar(SnackBar(content: Text(path == null ? l.exportCancelled : l.savedFile(fileName))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.exportFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Import ─────────────────────────────────────────────────────────────────
  Future<void> _import({required String Function(String) run}) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await confirmDialog(context, title: l.importConfirmTitle, message: l.importConfirmBody, confirmLabel: l.importConfirmBtn);
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      final res = await FilePicker.platform.pickFiles(dialogTitle: l.importConfirmTitle, type: FileType.custom, allowedExtensions: const ['csv'], withData: true);
      final bytes = res?.files.single.bytes;
      if (bytes == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.exportCancelled)));
        return;
      }
      // Decode leniently — a stray non-UTF8 byte must not crash the import.
      final text = utf8.decode(bytes, allowMalformed: true);
      final summary = run(text);
      if (!mounted) return;
      await _showSummary(summary);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.csvImportFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _importInventory(String csv) {
    final l = L.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    final res = importInventoryCsv(
      csv,
      add: (row) {
        final added = state.addStockItem(
          name: row.name,
          unit: row.unit,
          price: row.price,
          cost: row.cost,
          qty: row.qty,
          reorder: row.reorder,
          gstRate: row.gstRate,
          barcode: row.barcode,
          category: row.category,
          hsn: row.hsn,
          stockTracked: row.stockTracked,
          nowMs: now + i++,
        );
        return added != null; // null == duplicate SKU → skipped
      },
    );
    return _summaryText(l, res);
  }

  String _importCustomers(String csv) {
    final l = L.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    final existing = state.customers.map((c) => (c.name.toLowerCase(), c.mobile.trim())).toSet();
    final res = importCustomersCsv(
      csv,
      add: (row) {
        // addCustomer has no duplicate guard — dedupe here on name+mobile so a
        // re-import doesn't pile up copies.
        final key = (row.name.toLowerCase(), row.mobile.trim());
        if (existing.contains(key)) return false;
        existing.add(key);
        state.addCustomer(name: row.name, mobile: row.mobile, gstin: row.gstin, creditLimit: row.creditLimit, consent: row.consent, nowMs: now + i++);
        return true;
      },
    );
    return _summaryText(l, res);
  }

  String _summaryText(L l, ImportResult res) {
    if (res.isEmpty) return l.importNothing;
    return l.importSummary(res.added, res.skipped, res.failed);
  }

  Future<void> _showSummary(String summary) async {
    final l = L.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.importResultTitle),
        content: Text(summary),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(MaterialLocalizations.of(ctx).okButtonLabel))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(l.dataIoTitle, l.dataIoSubtitle),
              _sectionCard(
                bx,
                icon: Icons.ios_share,
                color: bx.brand,
                title: l.dataIoExportSection,
                hint: l.dataIoExportHint,
                children: [
                  _actionButton(bx, Icons.inventory_2_outlined, l.exportInventoryCsv, () => _export('billnex-inventory.csv', inventoryToCsv(state.stockItems), state.stockItems.isNotEmpty)),
                  _actionButton(bx, Icons.groups_outlined, l.exportCustomersCsv, () => _export('billnex-customers.csv', customersToCsv(state.customers), state.customers.isNotEmpty)),
                  _actionButton(bx, Icons.receipt_long_outlined, l.exportSalesCsv, () => _export('billnex-sales.csv', salesToCsv(state.sales), state.sales.isNotEmpty)),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                bx,
                icon: Icons.file_download_outlined,
                color: bx.accent,
                title: l.dataIoImportSection,
                hint: l.dataIoImportHint,
                children: [
                  _actionButton(bx, Icons.inventory_2_outlined, l.importInventoryCsv, () => _import(run: _importInventory), filled: false),
                  _actionButton(bx, Icons.groups_outlined, l.importCustomersCsv, () => _import(run: _importCustomers), filled: false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(BxColors bx, {required IconData icon, required Color color, required String title, required String hint, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(hint, style: TextStyle(fontSize: 12.5, color: bx.faint, height: 1.4)),
            const SizedBox(height: 14),
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 10), children[i]],
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BxColors bx, IconData icon, String label, VoidCallback onTap, {bool filled = true}) {
    final style = ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)));
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: filled ? FilledButton(onPressed: _busy ? null : onTap, style: style, child: child) : OutlinedButton(onPressed: _busy ? null : onTap, style: style, child: child),
    );
  }
}
