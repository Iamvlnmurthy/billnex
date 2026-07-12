import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Backup & Restore — each merchant owns their data (device/PC or their own
/// Google Drive via the share sheet). No central server.
class BackupScreen extends StatelessWidget {
  final AppState state;
  const BackupScreen({required this.state, super.key});

  String _ago(int? ms) {
    if (ms == null) return 'Never backed up';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final mins = DateTime.now().difference(d).inMinutes;
    if (mins < 1) return 'Backed up just now';
    if (mins < 60) return 'Backed up $mins min ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return 'Backed up $hrs h ago';
    return 'Backed up ${hrs ~/ 24} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final counts = <(String, int)>[
      ('Sales', state.billCount),
      ('Customers', state.customers.length),
      ('Products', state.stockItems.length),
      ('Suppliers', state.suppliers.length),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const PageHeader('Backup & Restore', 'Your shop data stays yours. Save a backup to your device, PC, or your own Google Drive — and restore anytime.'),
            // status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: bx.pos.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.cloud_done_outlined, color: bx.pos),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_ago(state.lastBackupMs), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        Text('${state.billCount} bills · ${state.customers.length} customers · ${state.stockItems.length} products', style: TextStyle(fontSize: 12.5, color: bx.muted)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _save(context),
                    icon: const Icon(Icons.save_alt, size: 18),
                    label: const Text('Save backup'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text('Choose Google Drive, your PC, or Files in the save dialog.', style: TextStyle(fontSize: 12, color: bx.faint)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _restore(context),
                    icon: Icon(Icons.restore, size: 18, color: bx.danger),
                    label: Text('Restore from backup', style: TextStyle(color: bx.danger)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: bx.danger.withValues(alpha: 0.4))),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            // what's in the backup
            Card(
              child: Column(children: [
                const Padding(padding: EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('In this backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))),
                for (final (label, n) in counts)
                  Container(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: bx.border))),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text('$n', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            Text('Tip: keep a copy on Google Drive so you can move to a new phone or PC and restore in one tap. Restoring replaces the current data on this device.',
                style: TextStyle(fontSize: 12.5, color: bx.faint, height: 1.5)),
          ]),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final m = ScaffoldMessenger.of(context);
    try {
      final ok = await BackupService.saveToFile(state);
      m.showSnackBar(SnackBar(content: Text(ok ? 'Backup saved ✓' : 'Save cancelled')));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text('This replaces ALL current data on this device with the backup file. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final m = ScaffoldMessenger.of(context);
    try {
      final ok = await BackupService.restoreFromFile(state);
      m.showSnackBar(SnackBar(content: Text(ok ? 'Data restored ✓' : 'Restore cancelled')));
    } on FormatException {
      m.showSnackBar(const SnackBar(content: Text('That file is not a BillNex backup')));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }
}
