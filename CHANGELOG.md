# Changelog

All notable changes to BillNex. Format loosely follows Keep a Changelog.

## [0.2.0] — Production hardening
### Added
- **P1** Top-level README, GitHub Actions CI (analyze + test + web build), strict lints.
- **P2** `Persistence` abstraction seam + `InMemoryPersistence` + restart round-trip test.
- **P4** App-lock: PIN via device keystore, escalating lockout, fail-safe launch.
- **P7** i18n — English / Hindi / Telugu with a persisted language switcher.
- **P5** Backend artifacts: Postgres schema, RLS policies, OpenAPI sync contract,
  `SyncService` seam + deploy runbook (`backend/`).
- **P6** Integration services (UPI intent, WhatsApp link, GST e-invoice payload,
  ESC/POS interface) + runbook (`docs/INTEGRATIONS.md`).
- **P8** Global crash/error reporting hook, Android release signing config
  (`key.properties`), `RELEASE.md`, `SECURITY.md`.

### Notes
- 19 tests passing; `flutter analyze` clean; web release builds.
- Backend deploy, payment/GSP/WhatsApp providers, and Play publishing require
  the operator's accounts (see the runbooks).

## [0.1.0] — Foundation MVP
- Business-type presets → auto-allotted, feature-flag-gated capabilities.
- POS with live receipt + 11 print templates (A4 + 58/80mm thermal, real PDF).
- Modules: Customers & Credit, Inventory & Stock, Purchasing & Suppliers,
  Reports & Analytics, Roles + offline outbox + audit, Appointments + KOT packs.
- Stitch "Modern Corporate" design system; local persistence; Android/tablet/desktop/web.
