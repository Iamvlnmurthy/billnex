/// Operator configuration. Fill these in for your Nexen Labs build.
///
/// Google Drive backup (option B) needs an OAuth client from your Google Cloud
/// project — see docs/GOOGLE_DRIVE.md. On Android the client is picked up from
/// google-services.json and this can stay empty; web/desktop/iOS need the id.
const String kGoogleClientId = '';

/// Whether to show the integrated "Connect Google Drive" option. The plain
/// "Save backup" dialog (which can also target Drive) always works.
const bool kDriveBackupEnabled = true;
