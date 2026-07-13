# BillNex — Click-Target Bug Audit + Vyapar UI/UX/Feature Comparison

_Audit date: 2026-07-13 · Reference: Vyapar v27.7.2 (Simply Vyapar Apps)_
_Method: every `onTap`/`onPressed`/`onChanged`/`onSubmitted` across all 18 screens traced end-to-end (handler → state method → persistence → edge cases → touch-target size)._

---

## Part A — Bug audit (ranked)

Severity: **CRITICAL** = data loss / money wrong · **HIGH** = broken flow or dead control · **MEDIUM** = degraded UX / leak / staleness · **LOW** = polish / edge case.

### CRITICAL

| # | Location | Bug | Fix |
|---|---|---|---|
| C1 | `inventory_screen.dart:346` (`app_state.addStockItem`) | SKU = trimmed name; adding a product with an existing name **silently overwrites** the original (batches, cost, barcode, qty gone). | Reject/merge when `_stock.containsKey(name)`; surface error in the add sheet. |
| C2 | `purchasing_screen.dart:196,262` | Duplicate-invoice `errorText` is shown but **not enforced** — Record button only disabled on empty lines, so a duplicate supplier invoice commits double stock-in + double payable. | `onPressed: (_lines.isEmpty \|\| dup) ? null : _record`. |
| C3 | `pos_screen.dart:500` (`CartLine.qty` int) | Quantity is **integer-only**; loose/weighed goods (kg/g/Litre units exist on items) can't be billed — a grocer can't sell 0.5 kg. | Make qty a `double`; add tap-to-edit numeric qty entry. |
| C4 | `pos_screen.dart:235` / `app_state.postSale` | Items sell into **negative stock**; out-of-stock tiles stay tappable; `inc` unbounded. | Disable tile when `item.out`; clamp qty to available in `addProduct`/`inc`/`postSale`. |
| C5 | `customers_screen.dart:272` (`app_state.collect`) | Receive-payment **not clamped to balance** → overpay drives credit balance negative; pre-fill `due.round()` rounds paise **up**, so the default tap itself overpays. | `amt = min(parsed, due)`; pre-fill `due.toStringAsFixed(2)`; guard in `collect()`. |

### HIGH

| # | Location | Bug | Fix |
|---|---|---|---|
| H1 | `dashboard_screen.dart:66` | "Create New Bill" CTA → `billing`, which **accountant role can't access** → silent bounce to dashboard. Primary CTA dead for that role. | Gate CTA on `state.roleCanAccess('billing')`. |
| H2 | `dashboard_screen.dart:277,280,47` | "Add Product"/"View Stock"/"Day Closing"/low-stock banner navigate to tabs **cashier/accountant can't reach** → dead taps. | Render each only when its target is role-accessible. |
| H3 | `inventory_screen.dart:309,335` (`_GstDropdown`) | GST dropdown items are `[0,5,12,18,28]`; a `gstRate` outside the list (purchase-created / imported) throws the **Dropdown "exactly one item" assertion** on Edit. | Snap `gstRate` to nearest slab before passing in. |
| H4 | `inventory_screen.dart:165` | Add form has **no numeric validation** — ₹0/negative price, negative stock/reorder all pass. | Validate price>0, qty≥0, reorder≥0 with inline errors. |
| H5 | `purchasing_screen.dart:264` | `context` used **after `Navigator.pop`** → "deactivated ancestor" throw / wrong scaffold. | Capture `messenger` before pop. |
| H6 | `pos_screen.dart:499,507` | Cart +/- step buttons are **26×26px** (min 44); stray tap on `–` at qty 1 deletes the line. | 44×44 hit area. |

### MEDIUM (selected — full list below)

- **Controller leaks** — `TextEditingController`s never disposed in every dialog/sheet: `pos._manualEntry`, `customers._collect`, `appointments._book`, `inventory._addProduct/_editProduct/_adjust`, `purchasing._addSupplier/_addLine/_pay`, `home_shell._managePin`. (~10 instances.)
- **Fire-and-forget PDF** — `sales_screen.dart:81,86` + `reports_screen.dart:26` reprint/share/export are un-awaited, un-caught, and depend on **network-fetched fonts** (`PdfGoogleFonts.*`) → silent no-op offline. Bundle fonts + catch + snackbar.
- **Bill-discount field** (`pos_screen.dart:334`) — uncontrolled; stale discount text persists after posting, desyncing from state.
- **Empty-cart payment buttons** (`pos_screen.dart:356`) — Cash/UPI/Credit/Charge enabled at ₹0 (KOT correctly disabled). Disable to match.
- **Backup route staleness** (`backup_screen.dart:68,78`) — pushed outside the state `AnimatedBuilder`; local save/restore don't set `_busy` or `setState`, so counts/labels don't refresh.
- **Features "Enable/Disable all"** (`features_screen.dart:46`) — `allOn` counts locked Pro caps but `toggleCategory` skips them → label stuck on "Enable all".
- **Uncapped stock reduction** (`inventory_screen.dart:395`) — reduce path allows negative on-hand.
- **Duplicate barcode** (`inventory_screen.dart:174,337`) — no uniqueness check; breaks scan lookup. Barcode field is numeric-only (blocks alphanumeric/leading-zero EAN).
- **KOT false success** (`pos_screen.dart:412`) — "KOT sent ✓" shown before await; print errors swallowed.
- **Recent Activity rows** (`dashboard_screen.dart:353`) — styled as list items but not tappable.
- **Booking silent-drop** (`appointments_screen.dart:117`) — Confirm pops `true` even with empty customer → nothing booked, no feedback.
- **Scanner torch/switch** (`scanner_screen.dart:39`) — dropped futures throw uncaught on unsupported devices.

### LOW / polish

- Sub-44px targets: `home_shell` "Sync now"/trust-bar toggles, `dashboard` "Details/View all", `pos` customer-clear ×, template chips, `templates` "Set default".
- Purchase GST hard-coded 5% for all items (mixed slabs mis-taxed); displayed total (`×1.05`) vs persisted (rounded) diverge by ~₹1.
- Cost fabricated as `price×0.78` on add (no cost field).
- **HSN & category exist on the model but no form field exposes them** — can never be set via UI (matters for GST invoices).
- Case-sensitive barcode/SKU POS search; supplier auto-selected `.first`; missing `mounted` guards in `lock._submit`, `backup._driveSignOut`.

**Pattern multipliers → 100+ instances:** controller-leak pattern (~10 sheets), sub-44px targets (~9 controls), uncapped amount fields (collect / supplier pay / stock reduce), network-font PDF (3 call sites), role-gated dead taps (~5 dashboard controls), missing `mounted` after await (~4 sites).

---

## Part B — Vyapar vs BillNex: UI / UX / Structure

### Navigation model
- **Vyapar:** 4 bottom tabs only — `HOME · DASHBOARD · ITEMS · MENU`. Everything else lives in a grouped **MENU** hub (My Business / Cash & Bank / Utilities / Others). The bar never changes.
- **BillNex:** up to 10 destinations (side rail on wide, bottom bar + "More" on mobile), gated by role/preset. More discoverable per-tap but busier, and the role-gating causes the dead-tap bugs above.
- **Takeaway:** adopt a stable 4–5 tab bar + a grouped MENU. Keeps BillNex's soul (presets still drive what's *inside* MENU) while matching Vyapar's calm, learnable structure.

### UX depth
- **Vyapar** gives the user **choice**: an "Add Txn" grid exposes every document type (Sale Invoice, Estimate, Sale Order, Delivery Challan, Returns, Payment-In/Out, P2P). Settings expose granular toggles (per invoice column, item behaviour, party fields). This is why it "feels good" — the user feels in control.
- **BillNex** currently offers Sale + Purchase only, with coarser feature toggles.

### Feature comparison

| Area | BillNex today | Vyapar (gap to close) |
|---|---|---|
| Document types | Sale, Purchase | + Estimate/Quotation, Sale Order, Delivery Challan, Sale/Purchase Return, Payment-In/Out, P2P Transfer |
| Settings granularity | Category feature toggles | Per-column invoice-print toggles; item/party/txn sub-settings; Regular/Thermal print tabs |
| Reports | Summary + tax breakup | Day Book, P&L, Balance Sheet, Cashflow, Bill-wise Profit; GSTR-1/2/3B/9; **Sale Summary by HSN**; Low-Stock; Item-wise P&L |
| Party | Credit ledger | + Loyalty points, shipping address, custom fields, grouping |
| Item | GST, barcode, stock | + Secondary units, wholesale/party-wise price, tax-on-MRP |
| Cash & Bank | — | Bank accounts, cheques, loan accounts |
| Multi-firm | Single | Manage multiple companies |
| Print | A4 + thermal, 11 templates | Deeper thermal (auto-cut, cash drawer, copies), per-element header/footer toggles |

**Where BillNex already wins (keep these — the "soul"):** cleaner modern-corporate visual system (Vyapar is utilitarian/dated), business-type presets that auto-allot features, and the per-shop privacy backup model (own device / own Google Drive) vs Vyapar's account sync.

---

## Suggested sequencing

1. **Fix CRITICAL + HIGH bugs** (C1–C5, H1–H6) — data-loss and dead-control class first.
2. **Sweep the MEDIUM patterns** — controller disposal, PDF error-handling + bundled fonts, uncapped amount clamps, backup-route refresh, touch-target minimums.
3. **Structure** — move to a stable 4–5 tab bar + grouped MENU hub.
4. **Feature depth** — add the high-value document types (Estimate, Delivery Challan, Returns) and HSN/Day-Book reports.
