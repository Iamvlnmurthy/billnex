# Codex work order — Visual restyle of BillNex (Flutter)

**Goal:** upgrade the visual style of the target screen(s) to match the provided reference
image(s). Aim for high fidelity (realistically 95–98% on the shown viewport — a literal
100% pixel match to an AI-generated concept is not promised: it contains approximations,
unavailable exact icons/photos, and no formal dimensions/responsive specs).

**Before you start, you MUST have:** (a) the actual reference image(s), and (b) the exact
screen(s) they map to (e.g. Dashboard, POS, Sales). If either is missing, ask — do not guess.

---

## Golden rule
**Change presentation, never behavior, data shape, or localization.** Every visible string
must remain a localized lookup. Every `toJson`/`fromJson` key must stay byte-identical.
Every business calculation must be untouched. All tests must stay green **without being
weakened**.

Work **tokens-first**: change `lib/theme/app_theme.dart` (colors, type scale, radii,
shadows, spacing) so the whole app reflows from the design system. Only override per-screen
where the mock genuinely diverges from the token cascade.

---

## ✅ TOUCHABLES (presentation only)
- `lib/theme/app_theme.dart` — `BxColors` tokens, `BxText` type scale, `ThemeData`, radii,
  shadows, `_tabularFigures`. **This is the primary place to make global visual changes.**
- `lib/screens/*.dart` — layout, spacing, card/section styling, visual composition.
  You may re-arrange widgets and restyle, but keep intact: every `L.of(context)` / `l.<key>`
  string, every `state.<...>` call, every `goTo(NavId.x)` / `onTap` / callback, and every
  `roleCanAccess(...)` / `isOn(...)` conditional.
- `lib/widgets/*.dart` — shared presentational components: `common.dart`
  (`Money`, `PageHeader`, `Badge2`, `Pill`, `EmptyState`, `ErrorState`, `confirmDialog`
  chrome), `empty_state.dart`, `receipt.dart` (visual only — not the totals math),
  `customer_picker.dart` chrome.
- `lib/screens/splash_screen.dart`, onboarding visuals, illustrations.
- `assets/**` — you may ADD image/illustration/icon assets; register them in `pubspec.yaml`.

## ⛔ UNTOUCHABLES (do not modify — changing these breaks logic, saved data, or i18n)
- **State / logic:** `lib/state/app_state.dart` — cart, `postSale`, feature flags, returns,
  ledger, reports math. You may READ existing getters; do not change logic or add business rules.
- **Services:** `lib/services/*` — `persistence.dart`, `store.dart`, **`buffered_store.dart`
  (durability/flush)**, `sync_service.dart`, `billing.dart` (GST/rounding math),
  `pdf_service.dart`, `auth_service.dart`, `error_reporter.dart`.
- **Models:** `lib/models/*` — do **not** rename/add/remove any `toJson`/`fromJson` field or
  JSON key. These serialize saved data and user backups; a change corrupts existing installs.
- **Localization:** `lib/l10n/*.arb`, `l10n.yaml`, generated `app_localizations*`. Do **not**
  hardcode English back into a screen. If the redesign needs NEW copy, ADD keys to **all three**
  ARBs (`app_en`, `app_hi`, `app_te`) following existing conventions — never name a key
  `override` (or a Dart reserved word); use a **String** placeholder (not int `plural`) for any
  quantity that can be fractional — then run `flutter gen-l10n`. See
  `docs`/memory `i18n-conventions` for the two gotchas.
- **Catalog:** `lib/data/catalog.dart` and `lib/data/catalog_i18n.dart` (feature/business/
  template definitions + their localization helpers).
- **Navigation contracts:** `NavId` enum and `navLabel(...)` in `screens/nav.dart`,
  `home_shell.dart` tab-selection/role-gating logic (you may restyle the bar; keep the logic).
- **Tests:** `test/**`. The smoke suite renders every screen in EN/HI/dark/empty and asserts
  **no exceptions and no RenderFlex overflows**; `widget_test.dart` covers billing, returns,
  and persistence-across-restart. Do not delete, skip, or loosen any test to make a redesign pass.
- **Platform/security:** `android/app/src/main/AndroidManifest.xml`
  (`allowBackup=false`, permissions), `analysis_options.yaml` (`formatter: page_width: 200`).

---

## Design guardrails (keep these true after the restyle)
- **Theme-aware:** style both light AND dark (`AppTheme.light()` / `AppTheme.dark()`); the
  reference may show one mode — don't break the other.
- **Touch & a11y:** interactive targets ≥ 44×44 with ≥ 8px gaps; text contrast ≥ 4.5:1
  (3:1 for large); keep icon-only buttons' `Semantics`/tooltips; honor `prefers-reduced-motion`.
- **Layout:** 8pt spacing grid; no horizontal page scroll (wide tables/charts scroll inside
  their own `overflow`-scroll container); keep the Dashboard fitting ~one phone viewport.
- **Money:** keep the `Money` widget (de-emphasized ₹ + tabular figures) — don't inline `'₹...'`.
- **Motion:** 150–300ms, meaningful; never animate width/height for layout.

---

## Definition of done (run all; do not skip)
1. `flutter gen-l10n` (if any ARB changed)
2. `dart format .`
3. `flutter analyze` → must print **"No issues found!"**
4. `flutter test` → **all** tests pass (currently 92). Fix the code, never the test.
5. Build the APK only from the clean clone `C:\dev\billnex` (spaces in the working-dir path
   break the Kotlin/Gradle build). Never interact with emulator-5554 (a different app).

---

## ⚠️ Required reporting (Codex must include this in its final message)
1. **Diff summary grouped by file.**
2. A section titled **"⚠️ Untouchables touched"** that explicitly lists ANY change to a file
   or contract in the UNTOUCHABLES list, with justification — **or states "None."** Do not bury
   such changes; call them out.
3. Confirmations: (a) no hardcoded user-facing strings introduced — all via `l10n`;
   (b) every `toJson`/`fromJson` key unchanged; (c) `flutter analyze` clean and `flutter test`
   green (state the pass count); (d) both light and dark render; (e) EN and HI both render.
4. An honest fidelity note: where the implementation diverges from the reference and why
   (missing exact icons/photos, approximations, responsive gaps).
