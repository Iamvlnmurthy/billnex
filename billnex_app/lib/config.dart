/// Operator configuration. Fill these in for your Nexen Labs build.
///
/// Google Drive backup (option B) needs an OAuth client from your Google Cloud
/// project — see docs/GOOGLE_DRIVE.md.
/// - Web / desktop / iOS: set [kGoogleClientId] to that platform's OAuth client id.
/// - Android: leave [kGoogleClientId] empty; set [kGoogleServerClientId] to the
///   *Web* OAuth client id (google_sign_in v7 uses it as the server client id).
const String kGoogleClientId = ''; // set to the Web client id below for web/desktop builds
const String kGoogleServerClientId = '327351912011-2iilb85ng8khpqd8ch5vc41u15pv16f0.apps.googleusercontent.com';

/// Whether to show the integrated "Connect Google Drive" option.
///
/// OFF by default: the OAuth consent screen for [kGoogleServerClientId] is still
/// in Google's "testing" state, so anyone who isn't an added test user hits
/// "Access blocked: billnex has not completed the Google verification process"
/// (Error 403: access_denied). Flip this to `true` only AFTER either
///   (a) adding your testers under Google Cloud Console → OAuth consent screen →
///       Test users, or
///   (b) completing Google's app verification for the Drive scope.
/// Until then, users back up via "Save backup to a file" (which can still target
/// Drive through the system save dialog) and via CSV import/export — both fully
/// offline and unaffected by this flag.
const bool kDriveBackupEnabled = false;
