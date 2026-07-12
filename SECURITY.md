# Security overview

Aligned to PRD §16 (Security, Privacy & Compliance).

## In the app today
- **App-lock**: 4-digit PIN, salted SHA-256 hash in the platform keystore
  (`flutter_secure_storage`), escalating lockout after 5 failed attempts.
  Launch is fail-safe — a keystore read error never bricks the app.
- **Roles**: Owner / Manager / Cashier / Accountant gate navigation and
  cost/margin visibility client-side (BNX-0277).
- **Audit log**: immutable record of sales, collections, purchases, stock
  adjustments (BNX-0268).
- **No sensitive card data** is ever stored (PRD non-goal); payments keep only
  mode + reference.
- **Local persistence** is on-device (shared_preferences today; Drift/SQLite
  planned). No customer data leaves the device until a backend is configured.

## When the backend is enabled (P5)
- **Tenant isolation** via Postgres Row-Level Security — every table scoped to
  the user's `business_id` (`backend/policies.sql`).
- **Least privilege**: the `service_role` key never ships in the app; the client
  holds only a short-lived JWT + the public merchant VPA.
- **Encryption in transit** (TLS, Supabase default); enable Point-in-Time
  Recovery for backups.
- **Provider secrets** (GSP, WhatsApp BSP, PSP) live server-side only.

## Hardening backlog (before GA)
- Encrypt the local data blob at rest (key in keystore) — BNX-0347.
- Server-side role enforcement mirroring the client gates.
- Consent/retention workflow (BNX-0354–0359) and support-access expiry.
- Dependency scanning in CI; supported-version policy (BNX-0353).

## Reporting
Email security reports to **security@nexenlabs** (placeholder) — do not open
public issues for vulnerabilities.
