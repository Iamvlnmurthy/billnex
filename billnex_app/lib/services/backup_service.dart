import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';

/// Per-merchant backup & restore (PRD BNX-0343/0344). No central server: each
/// shop exports a single portable JSON snapshot to its own device/PC, or shares
/// it to its own Google Drive / WhatsApp / email, and restores from it.
class BackupService {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static String fileName(int nowMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(nowMs);
    return 'billnex-backup-${d.year}${_two(d.month)}${_two(d.day)}-${_two(d.hour)}${_two(d.minute)}.json';
  }

  static Uint8List _bytes(AppState s, int nowMs) => Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(s.exportData(nowMs: nowMs))));

  /// Save the backup to a location the merchant chooses (device / PC / a
  /// Drive-synced folder). Returns true if a file was written.
  static Future<bool> saveToFile(AppState s) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final path = await FilePicker.platform.saveFile(dialogTitle: 'Save BillNex backup', fileName: fileName(now), bytes: _bytes(s, now), type: FileType.custom, allowedExtensions: const ['json']);
    if (path != null) {
      s.markBackedUp(now);
      return true;
    }
    return false;
  }

  /// Pick a backup file and restore it (replaces all current data).
  /// Returns true on success; throws [FormatException] for a non-BillNex file.
  static Future<bool> restoreFromFile(AppState s) async {
    final res = await FilePicker.platform.pickFiles(dialogTitle: 'Choose a BillNex backup', type: FileType.custom, allowedExtensions: const ['json'], withData: true);
    final bytes = res?.files.single.bytes;
    if (bytes == null) return false;
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    await s.importData(map);
    return true;
  }
}
