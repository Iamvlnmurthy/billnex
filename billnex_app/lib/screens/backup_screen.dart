import 'package:flutter/material.dart';
import '../config.dart';
import '../state/app_state.dart';
import '../services/backup_service.dart';
import '../services/google_drive_backup.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

/// Backup & Restore — each merchant owns their data: a local file (device / PC /
/// Google Drive via the save dialog) OR one-tap to their own Google Drive.
class BackupScreen extends StatefulWidget {
  final AppState state;
  const BackupScreen({required this.state, super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _drive = GoogleDriveBackup(clientId: kGoogleClientId, serverClientId: kGoogleServerClientId);
  bool _busy = false;
  List<DriveBackupFile> _driveFiles = const [];

  AppState get state => widget.state;

  String _ago(L l, int? ms) {
    if (ms == null) return l.backupNeverBackedUp;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final mins = DateTime.now().difference(d).inMinutes;
    if (mins < 1) return l.backupJustNow;
    if (mins < 60) return l.backupMinAgo('$mins');
    final hrs = mins ~/ 60;
    if (hrs < 24) return l.backupHoursAgo('$hrs');
    return l.backupDaysAgo('${hrs ~/ 24}');
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final counts = <(String, int)>[
      (l.backupCountSales, state.billCount),
      (l.backupCountCustomers, state.customers.length),
      (l.backupCountProducts, state.stockItems.length),
      (l.backupCountSuppliers, state.suppliers.length),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(l.backupRestoreTitle, l.backupRestoreSubtitle),
              // ── Local file ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _icon(bx, Icons.cloud_done_outlined, bx.pos),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_ago(l, state.lastBackupMs), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                Text(l.backupDataSummary('${state.billCount}', '${state.customers.length}', '${state.stockItems.length}'), style: TextStyle(fontSize: 12.5, color: bx.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _save(context),
                        icon: const Icon(Icons.save_alt, size: 18),
                        label: Text(l.saveBackupToFile),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Text(l.saveDialogHint, style: TextStyle(fontSize: 12, color: bx.faint)),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => _restoreFile(context),
                        icon: Icon(Icons.restore, size: 18, color: bx.danger),
                        label: Text(l.restoreFromFile, style: TextStyle(color: bx.danger)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: bx.danger.withValues(alpha: 0.4))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (kDriveBackupEnabled) _driveCard(bx, l),
              if (kDriveBackupEnabled) const SizedBox(height: 16),
              // ── What's inside ──
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l.inThisBackup, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    for (final (label, n) in counts)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: bx.border)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Text('$n', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(l.backupRestoreFootnote, style: TextStyle(fontSize: 12.5, color: bx.faint, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon(BxColors bx, IconData i, Color c) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
    child: Icon(i, color: c),
  );

  Widget _driveCard(BxColors bx, L l) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _icon(bx, Icons.add_to_drive, bx.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.googleDrive, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(_drive.isSignedIn ? (_drive.email ?? l.driveConnected) : l.driveConnectPrompt, style: TextStyle(fontSize: 12.5, color: bx.muted)),
                    ],
                  ),
                ),
                if (_busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 14),
            if (!_drive.isSignedIn)
              FilledButton.icon(
                onPressed: _busy ? null : _connect,
                icon: const Icon(Icons.login, size: 18),
                label: Text(l.connectGoogleDrive),
                style: FilledButton.styleFrom(backgroundColor: bx.accent, foregroundColor: bx.onAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(onPressed: _busy ? null : _driveBackup, icon: const Icon(Icons.backup, size: 18), label: Text(l.backUpNow)),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: _busy ? null : _driveSignOut, child: Text(l.disconnect)),
                ],
              ),
              const SizedBox(height: 10),
              if (_driveFiles.isEmpty)
                Text(l.noDriveBackups, style: TextStyle(fontSize: 12.5, color: bx.faint))
              else ...[
                Text(
                  l.backupsOnYourDrive,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bx.faint),
                ),
                for (final f in _driveFiles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.description_outlined, color: bx.muted),
                    title: Text(f.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: f.modified != null ? Text('${f.modified!.toLocal()}'.split('.').first) : null,
                    trailing: TextButton(onPressed: _busy ? null : () => _driveRestore(f), child: Text(l.restore)),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ── local ──
  Future<void> _save(BuildContext context) async {
    final l = L.of(context);
    final m = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final ok = await BackupService.saveToFile(state);
      m.showSnackBar(SnackBar(content: Text(ok ? l.backupSavedCheck : l.saveCancelled)));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(l.backupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false); // refresh counts / last-backup label
    }
  }

  Future<void> _restoreFile(BuildContext context) async {
    if (!await _confirmRestore(context)) return;
    if (!context.mounted) return;
    final l = L.of(context);
    final m = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final ok = await BackupService.restoreFromFile(state);
      m.showSnackBar(SnackBar(content: Text(ok ? l.dataRestored : l.restoreCancelled)));
    } on FormatException {
      m.showSnackBar(SnackBar(content: Text(l.notBillnexBackup)));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(l.restoreFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false); // refresh after restore
    }
  }

  // ── drive ──
  Future<void> _connect() async {
    setState(() => _busy = true);
    final l = L.of(context);
    final m = ScaffoldMessenger.of(context);
    try {
      final ok = await _drive.signIn();
      if (ok) _driveFiles = await _drive.list();
      if (!ok) m.showSnackBar(SnackBar(content: Text(l.googleSignInCancelled)));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(l.signInFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _driveBackup() async {
    setState(() => _busy = true);
    final l = L.of(context);
    final m = ScaffoldMessenger.of(context);
    try {
      await _drive.backup(state);
      _driveFiles = await _drive.list();
      m.showSnackBar(SnackBar(content: Text(l.backedUpToDrive)));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(l.driveBackupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _driveRestore(DriveBackupFile f) async {
    if (!await _confirmRestore(context)) return;
    if (!mounted) return;
    setState(() => _busy = true);
    final l = L.of(context);
    final m = ScaffoldMessenger.of(context);
    try {
      await _drive.restore(f.id, state);
      m.showSnackBar(SnackBar(content: Text(l.restoredFromDrive)));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(l.driveRestoreFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _driveSignOut() async {
    await _drive.signOut();
    if (!mounted) return;
    setState(() => _driveFiles = const []);
  }

  Future<bool> _confirmRestore(BuildContext context) {
    final l = L.of(context);
    return confirmDialog(context, title: l.restoreFromBackupTitle, message: l.restoreFromBackupBody, confirmLabel: l.restore, destructive: true);
  }
}
