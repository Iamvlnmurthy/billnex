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
/// ON now that the OAuth consent screen for [kGoogleServerClientId] has passed
/// Google verification. If you ever see "Access blocked: … has not completed the
/// Google verification process" (Error 403: access_denied) again, it means the
/// consent screen was reverted to "testing" — either add the signing-in account
/// under Google Cloud Console → OAuth consent screen → Test users, or set this
/// back to `false`. The "Save backup to a file" and CSV paths work regardless.
const bool kDriveBackupEnabled = true;
