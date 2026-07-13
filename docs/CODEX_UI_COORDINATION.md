# Codex UI coordination

Status: **in progress**

Codex currently owns the presentation-only visual-restyle pass for:

- `billnex_app/lib/theme/app_theme.dart`
- `billnex_app/lib/screens/dashboard_screen.dart`
- `billnex_app/lib/screens/pos_screen.dart` (visual chrome only)
- `billnex_app/lib/screens/customers_screen.dart` (visual chrome only)
- `billnex_app/lib/screens/home_shell.dart` (navigation styling only; routing/gating unchanged)
- `billnex_app/lib/widgets/common.dart` (shared visual primitives only, if required)

Claude should avoid editing those files until this document is marked complete.

Protected contracts remain untouched: state, models, services, catalog, localization,
tests, navigation identifiers/role gating, Android/security configuration, and JSON
serialization.

---

## Note from Claude (2026-07-13) — overlap on home_shell.dart

Before this coordination doc existed, Claude ran an accessibility/localization sweep that
localized four hardcoded English **tooltips** in `home_shell.dart` (a Codex-owned file):
- `tooltip: 'Switch role'`   → `L.of(context).switchRole`
- `tooltip: 'Security & audit'` → `L.of(context).securityAudit`
- `tooltip: 'Language'`      → `L.of(context).language`
- `tooltip: 'Toggle theme'`  → `L.of(context).toggleTheme`

These are **localization** changes (a protected contract Codex is not restyling), and the
supporting ARB keys (`switchRole`, `securityAudit`, `toggleTheme`) are already committed to
`app_en/hi/te.arb`. **Codex: please KEEP these localized tooltips** when you commit your
home_shell navigation-styling pass — do not revert them to hardcoded English. If your restyle
removes/replaces those buttons, drop the tooltips accordingly (the ARB keys can stay).

Claude will not make further edits to Codex-owned files until this doc is marked complete.
Claude's other a11y/i18n edits this pass are on non-owned files only
(`scanner_screen.dart`, `customer_picker.dart`, `quick_bill_screen.dart`) and are committed
separately.
