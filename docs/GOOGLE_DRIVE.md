# Google Drive backup — one-time setup (operator)

Merchants back up to **their own** Google Drive; you (Nexen Labs) only provide
the OAuth client so the app can request Drive access. Backups go to the app's
private **appDataFolder** — invisible to other apps, never clutters "My Drive".

The plain **"Save backup to a file"** flow needs none of this and always works
(the save dialog can also target the Drive app). This is only for the integrated
**"Connect Google Drive → one-tap backup"** option.

## 1. Google Cloud project
1. https://console.cloud.google.com → create/select a project.
2. **APIs & Services → Enable APIs → Google Drive API** → Enable.
3. **OAuth consent screen** → External → add app name, support email, and the
   scope `.../auth/drive.appdata` → add test users while unverified.

## 2. OAuth clients (one per platform you ship)
**Android**
- Credentials → Create → OAuth client ID → Android.
- Package name: `com.nexenlabs.billnex`.
- SHA-1: `cd billnex_app/android && ./gradlew signingReport` (use the release
  SHA-1 from your keystore, and the debug SHA-1 for testing).
- No client id goes in code for Android — the plugin reads it from the project.

**Web / desktop / iOS** (only if you ship those)
- Create a **Web** OAuth client; put its id in `lib/config.dart` → `kGoogleClientId`.
- iOS: create an iOS client, add the reversed-client-id URL scheme to Info.plist.

## 3. App config
- `lib/config.dart`:
  - `kGoogleClientId` — set for web/desktop/iOS (leave empty for Android-only).
  - `kDriveBackupEnabled` — `true` to show the Drive card (default).
- Scope used: `DriveApi.driveAppdataScope` (app-private folder only — minimal).

## 4. Verify on a device
Backup screen → **Connect Google Drive** → pick account/consent →
**Back up now** → confirm a file appears via `list()` → **Restore** on a second
device signed into the same Google account.

## Notes
- Publishing to Play with a sensitive/restricted scope may require Google
  verification. `drive.appdata` is a **non-sensitive** scope (app-private data),
  which keeps verification light.
- The code lives in `lib/services/google_drive_backup.dart` and is wired into
  `lib/screens/backup_screen.dart`.
