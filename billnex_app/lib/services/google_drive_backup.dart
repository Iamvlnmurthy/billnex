import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../state/app_state.dart';
import 'backup_service.dart';

/// One backup file on the merchant's own Google Drive.
class DriveBackupFile {
  final String id;
  final String name;
  final DateTime? modified;
  const DriveBackupFile(this.id, this.name, this.modified);
}

/// Integrated Google Drive backup (option B). The merchant signs in with *their*
/// Google account; backups go to the app's private **appDataFolder** on their
/// Drive (invisible to other apps, doesn't clutter "My Drive"). No server.
///
/// Setup (one-time, operator): a Google Cloud OAuth client + Drive API enabled —
/// see docs/GOOGLE_DRIVE.md. Pass the web/desktop clientId where required.
class GoogleDriveBackup {
  GoogleDriveBackup({String? clientId, String? serverClientId})
      : clientId = (clientId?.isEmpty ?? true) ? null : clientId,
        serverClientId = (serverClientId?.isEmpty ?? true) ? null : serverClientId;
  final String? clientId;
  final String? serverClientId;

  static const _scopes = <String>[drive.DriveApi.driveAppdataScope];

  bool _initialized = false;
  GoogleSignInAccount? _account;

  bool get isSignedIn => _account != null;
  String? get email => _account?.email;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(clientId: clientId, serverClientId: serverClientId);
    _initialized = true;
  }

  /// Interactive sign-in. Returns true on success.
  Future<bool> signIn() async {
    await _ensureInit();
    try {
      _account = await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    _account = null;
  }

  Future<drive.DriveApi?> _api() async {
    final acct = _account;
    if (acct == null) return null;
    final authz = await acct.authorizationClient.authorizeScopes(_scopes);
    return drive.DriveApi(authz.authClient(scopes: _scopes));
  }

  /// Upload a full snapshot to the merchant's Drive appDataFolder.
  Future<void> backup(AppState s) async {
    final api = await _api();
    if (api == null) throw StateError('Not signed in to Google');
    final now = DateTime.now().millisecondsSinceEpoch;
    final bytes = utf8.encode(jsonEncode(s.exportData(nowMs: now)));
    final media = drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/json');
    final file = drive.File()
      ..name = BackupService.fileName(now)
      ..parents = <String>['appDataFolder'];
    await api.files.create(file, uploadMedia: media);
    s.markBackedUp(now);
  }

  /// List backups (newest first).
  Future<List<DriveBackupFile>> list() async {
    final api = await _api();
    if (api == null) return const [];
    final res = await api.files.list(
      spaces: 'appDataFolder',
      $fields: 'files(id,name,modifiedTime)',
      orderBy: 'modifiedTime desc',
      pageSize: 20,
    );
    return (res.files ?? [])
        .map((f) => DriveBackupFile(f.id ?? '', f.name ?? 'backup.json', f.modifiedTime))
        .toList();
  }

  /// Download a backup and restore it (replaces current data).
  Future<void> restore(String fileId, AppState s) async {
    final api = await _api();
    if (api == null) throw StateError('Not signed in to Google');
    final media = await api.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    await s.importData(map);
  }
}
