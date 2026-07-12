/// Operator configuration. Fill these in for your Nexen Labs build.
///
/// Google Drive backup (option B) needs an OAuth client from your Google Cloud
/// project — see docs/GOOGLE_DRIVE.md.
/// - Web / desktop / iOS: set [kGoogleClientId] to that platform's OAuth client id.
/// - Android: leave [kGoogleClientId] empty; set [kGoogleServerClientId] to the
///   *Web* OAuth client id (google_sign_in v7 uses it as the server client id).
const String kGoogleClientId = '';
const String kGoogleServerClientId = '';

/// Whether to show the integrated "Connect Google Drive" option. The plain
/// "Save backup" dialog (which can also target Drive) always works.
const bool kDriveBackupEnabled = true;
