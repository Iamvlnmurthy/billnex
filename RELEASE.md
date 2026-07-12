# Release runbook (Android)

## 1. One-time: signing key
```bash
keytool -genkey -v -keystore ~/billnex-release.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias billnex
cp billnex_app/android/key.properties.template billnex_app/android/key.properties
# edit key.properties with your passwords + absolute storeFile path
```
`key.properties` and `*.jks` are git-ignored — **back the keystore up securely**;
losing it means you can never update the app on Play.

## 2. Version bump
Edit `billnex_app/pubspec.yaml` → `version: X.Y.Z+build` (build = versionCode).

## 3. Build
```bash
cd billnex_app
flutter build appbundle --release   # Play Store (.aab)
flutter build apk --release         # sideload / direct (.apk)
```
Output: `build/app/outputs/bundle/release/app-release.aab`.

## 4. Pre-submit checklist
- [ ] App icon + splash set (`flutter_launcher_icons` / `flutter_native_splash`)
- [ ] `applicationId` final (`com.nexenlabs.billnex`)
- [ ] Test on a real device: thermal + A4 print, offline sale, restart persistence, PIN lock
- [ ] Privacy policy URL (required — collects customer data)
- [ ] Data-safety form filled (customer name/mobile, on-device + optional cloud)
- [ ] R8: to enable, add keep-rules for `pdf`, `printing`, `flutter_secure_storage`
      in `android/app/proguard-rules.pro`, set `isMinifyEnabled = true`, and
      verify a release build installs + prints on-device before shipping.

## 5. Play Console
Create app → internal testing track → upload `.aab` → complete store listing,
content rating, data safety → roll out to internal testers → then production.

CI (`.github/workflows/ci.yml`) already gates every push on analyze + test + web build.
