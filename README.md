# BillNex — Billing & Business OS

**Android-first, offline-capable billing & small-business operations platform** for Indian retail and 24 business verticals (kirana, pharmacy, restaurant, jewellery, salon, wholesale…). Built with Flutter from an implementation-grade PRD.

[![CI](https://github.com/Iamvlnmurthy/billnex/actions/workflows/ci.yml/badge.svg)](https://github.com/Iamvlnmurthy/billnex/actions/workflows/ci.yml)

> **Status:** Foundation MVP — 6 working modules, all feature-flag gated. `flutter analyze` clean, 15+ tests passing, builds for Android / tablet / desktop / web. Not yet backed by a server (local persistence today); see [Roadmap](#roadmap).

---

## What it does
- **Business-type presets** — pick a business, it auto-enables exactly the capabilities that trade needs (mirrors the feature matrix in the workbook). Category-wise feature toggles govern everything; Pro features lock behind a plan.
- **POS & billing** — stock-aware catalogue, cart, GST totals, **live receipt** preview, **11 print templates** for regular A4 printers + 58/80mm thermal, rendered to real PDF (print / share to WhatsApp).
- **Customers & Credit** — khata ledger, credit sales, collections, ageing, credit-limit guard.
- **Inventory & Stock** — live stock ledger that decrements on every sale, low-stock alerts, batch/expiry, adjustments, add-product, movement history.
- **Purchasing & Suppliers** — supplier master, purchase entry → stock-in → payables, supplier payment, duplicate-invoice guard.
- **Reports & Analytics** — live KPIs, payment-mix, top items, receivables/payables, PDF export.
- **Roles + Offline + Audit** — role-gated navigation (Owner/Manager/Cashier/Accountant), offline outbox with idempotent sync, immutable audit log.
- **Backup & Restore** — each shop owns its data: export a single portable JSON
  snapshot to its device/PC or its **own Google Drive** (via the save dialog),
  and restore on a new phone/PC in one tap. No central server required.
- **Security** — PIN app-lock (device keystore), Telugu/Hindi/English i18n.
- **Vertical packs** — Appointments (salon/clinic), Kitchen KOT (restaurant) — the flag-gated pattern the remaining packs plug into.

## Design
Adopted from the Stitch **"Modern Corporate"** design system (`stitch_billnex_design_system_pos_interface/`): Deep Navy + Primary Blue, cool grey-blue surfaces, white cards with soft ambient shadow, green **PAID** / amber **PENDING** status chips, 8pt grid. Light + navy dark mode, fully theme-tokenized.

## Repository layout
```
BillNex_Claude_Master_PRD.md              # implementation-grade PRD (577 features)
BillNex_Master_Features_and_Customizations.xlsx   # feature matrix / traceability
stitch_billnex_design_system_pos_interface/       # design system spec + reference screens
billnex_app/                              # the Flutter application
  lib/
    data/        # capabilities, business presets, templates (PRD data)
    models/      # sale, customer, stock, supplier, appointment, system
    services/    # store (persistence), pdf_service (A4+thermal PDF)
    state/       # AppState — preset engine, ledgers, sync, audit
    screens/     # dashboard, pos, sales, customers, inventory, purchasing, reports, features, templates, appointments
    widgets/     # receipt renderer, common UI, customer picker
    theme/       # Indigo/navy design tokens
```

## Run
```bash
cd billnex_app
flutter pub get
flutter run                 # Android device/emulator
flutter run -d windows      # desktop
flutter run -d chrome       # web
flutter test                # unit/widget tests
flutter analyze             # static analysis (clean)
```
Deep links (also used for demos): `?biz=restaurant&tab=1&demo=1&role=cashier&theme=dark`.

## Roadmap (→ v1.0)
| Phase | Scope | Status |
|---|---|---|
| Foundation | Presets, POS, templates, credit, inventory, purchasing, reports, roles/offline/audit, 2 vertical packs | ✅ done |
| P1 | Repo hardening: README, CI, strict lints | ✅ done |
| P2 | Drift/SQLite data layer + migrations | ⏳ |
| P3 | Riverpod + go_router + loading/empty/error states | ⏳ |
| P4 | Auth + cashier PIN/app-lock + encryption-at-rest | ⏳ |
| P5 | Backend (Supabase + RLS + OpenAPI) + real sync | ⏳ needs infra |
| P6 | Integrations: ESC/POS, dynamic UPI, WhatsApp, GST e-invoice | ⏳ needs accounts |
| P7 | Feature completeness + i18n (Telugu/Hindi) | ⏳ |
| P8 | Full test suite, crash reporting, signed release, security review | ⏳ |

## License
Proprietary — © Nexen Labs. All rights reserved.
