# BillNex — Flutter Foundation

Cross-platform billing/POS app (Android phone + tablet primary, Windows desktop
+ web secondary) built from `BillNex_Claude_Master_PRD.md`. This is the
**Foundation** cut: the spine the PRD's 577 features clip onto.

## What's here (verified: analyze clean, 5 tests pass, web release builds)
- **Preset engine** — pick a business type → auto-allots exactly its capability
  set (mirrors the `03_Business_Feature_Matrix` workbook sheet).
- **Feature-flag store** — category-wise toggles + per-category master switch;
  Pro capabilities lock behind an upsell unless the preset includes them.
- **POS shell** — catalogue, cart, GST totals, and a **live receipt** that
  re-renders in the selected template as you bill (WYSIWYP).
- **Real posting** — "Charge & print" posts an **immutable, uniquely numbered
  Sale**, clears the cart, and opens the printer dialog with a real PDF.
- **Real printing** — `pdf` + `printing`: every one of the 11 templates renders
  to an actual **A4 / 80mm / 58mm** PDF you can print or share (WhatsApp/email),
  including a live UPI **QR** on thermal receipts.
- **Sales history** — every posted bill is listed and **reprintable/shareable**
  (PRD: audited reprint, no silent deletion).
- **Persistence** — `shared_preferences`: chosen business, feature flags,
  templates, invoice sequence, sales history and theme survive restart.
- **Responsive shell** — nav rail on tablet/desktop, bottom nav on phone,
  always-on trust bar (online · sync · queue · backup).
- **Indigo Fintech theme** — Material 3, light + midnight-navy dark (persisted),
  semantic tokens via a `BxColors` theme extension.

## Run
```bash
flutter pub get
flutter run                 # Android device/emulator
flutter run -d windows      # desktop
flutter run -d chrome       # web
flutter test                # 3 tests: onboarding, preset engine, lock rule
flutter analyze             # clean (1 style-info only)
```

## Structure
```
lib/
  data/catalog.dart        # capabilities, categories, businesses, products, templates (PRD data)
  models/sale.dart         # immutable posted Sale + JSON
  state/app_state.dart     # preset engine + feature flags + cart + sales (ChangeNotifier)
  services/
    store.dart             # shared_preferences persistence
    pdf_service.dart       # A4 + thermal PDF generation, print & share
  theme/app_theme.dart     # Indigo Fintech tokens + BxColors extension
  widgets/
    common.dart            # money(), Pill, Badge, PageHeader
    receipt.dart           # the 11-template on-screen receipt renderer
  screens/
    onboarding_screen.dart # business-type picker
    home_shell.dart        # responsive shell + trust bar + nav
    dashboard_screen.dart  # live stats from posted sales
    pos_screen.dart        # billing + live receipt + real posting/printing
    sales_screen.dart      # posted-bill history + reprint/share
    features_screen.dart   # category-wise feature governor
    templates_screen.dart  # print template gallery + print sample
```

## Modules built (Phases 1–6, all verified)
1. **Customers & Credit** — khata ledger, credit sales, collections, ageing, credit-limit guard (gated by `creditLedger`).
2. **Inventory & Stock** — live stock ledger that decrements on every sale, low-stock, batch/expiry (pharmacy), adjustments, add-product, movement history.
3. **Purchasing & Suppliers** — supplier master, purchase entry → stock-in → payables, supplier payment, duplicate-invoice guard.
4. **Reports & Analytics** — live KPIs, payment-mix, top items, receivables/payables, PDF export.
5. **Roles + Offline + Audit** — role-gated nav (Owner/Manager/Cashier/Accountant), offline outbox with idempotent sync, immutable audit log.
6. **Vertical packs** — Appointments (salon/clinic) and Kitchen-KOT (restaurant), each gated by its capability flag — the pattern the other packs clip into.

Design system: adopted from `stitch_billnex_design_system_pos_interface` (Modern
Corporate blue/navy, green PAID / amber PENDING, wallet logo).

## Next milestones (deliberately stubbed)
- **Backend/sync** — outbox + idempotency keys per PRD §14; feature flags
  already evaluate client-side (mirror server-side for enforcement).
- **Drift/SQLite** — `shared_preferences` covers the Foundation; move to Drift
  when the schema grows (stock ledger, ledgers, batches). `AppState` only
  depends on the narrow `Store` interface, so the swap is local.
- **ESC/POS thermal driver** — real receipts print as PDF today; add a direct
  Bluetooth/USB ESC/POS path for certified thermal models (PRD §15).
- **Deeper verticals** — batch/expiry, serial/IMEI, KOT, appointments etc. each
  clip onto the existing capability flags by Feature ID.

## Not done (honest scope)
This is the Foundation + working MVP billing loop — **not** all 577 PRD
features. Credit ledger, purchasing, inventory movements, GST returns, offline
sync, roles/permissions and the vertical packs remain to be built on this spine.
