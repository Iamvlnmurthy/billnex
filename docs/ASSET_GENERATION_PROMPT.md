# BillNex — UI Graphics & Illustration Generation Prompt

Paste the block below into your image/graphics generator (Codex, GPT‑Image,
Midjourney-for-UI, Figma AI, etc.). It defines the brand, the exact asset list,
technical specs, and quality rules so every asset comes out as **one consistent
system**. Generate assets in the order listed; reuse the same style tokens for all.

---

## MASTER PROMPT

You are a senior product designer + illustrator creating a **cohesive visual
asset system** for **BillNex**, an Android‑first billing & POS app for Indian
small businesses (kirana, pharmacy, restaurant, jewellery, salon, wholesale and
20+ more verticals), made by **Nexen Labs**. Produce polished, production‑ready,
**system‑consistent** graphics — never generic AI clip‑art. Everything must feel
like it came from one design team, in one afternoon.

### 1. Brand & art direction
- **Personality:** modern, trustworthy, efficient, warm‑professional. "A tool a
  shopkeeper relies on every day." Confident, not playful; clean, not sterile.
- **Style:** flat + subtle depth. Geometric shapes, **2px consistent stroke**
  where lines are used, gentle duotone fills, soft long shadows at ~135°. Rounded
  corners everywhere (radius 8–16px on shapes, full‑round on pills). No skeuomorphism,
  no gradients-as-crutch, no drop-shadow overload, no photoreal 3D, no emoji.
- **Grid & geometry:** design on an **8pt grid**; keep icon strokes and shapes on
  a 24px base grid. Optical balance over mathematical centering.
- **Reference feeling:** Stripe/Razorpay illustration clarity + Google Material
  restraint, localized for Indian retail.

### 2. Color system (use ONLY these; semantic, not decorative)
- Primary Blue **#146CFF** (interactive), Deep Blue **#0055D1** (depth/gradient end)
- Deep Navy ink **#111C2D** (text/dark surfaces), Slate **#424655** (secondary)
- Surfaces: app bg **#F4F6FC**, cards **#FFFFFF**, soft fill **#F0F3FF**
- Success / PAID **#12B76A** (with tint **#E6F6EE**)
- Warning / PENDING **#C15700** (tint **#FBEEDD**)
- Error **#BA1A1A** (tint **#FDECEC**)
- Line/outline **#C2C6D8**
- Money/rupee accents use Success green or Primary Blue only.
- Provide a **light theme** and a **dark theme** variant of every illustration
  (dark bg **#0B1220**, cards **#141D30**, brighten strokes/fills for contrast).
- **Accessibility:** all text/icon-on-bg contrast ≥ 4.5:1; never encode meaning by
  color alone (pair with shape/label); colorblind‑safe (don't rely on red/green only).

### 3. Typography (for any text baked into graphics)
- Font: **Inter** (fallback: system sans). Tight, geometric, high legibility.
- Indian numerals grouping and the **₹** symbol must render correctly; keep ₹ the
  same weight as adjacent numbers.
- If Hindi/Telugu appears, use **Noto Sans Devanagari / Noto Sans Telugu**.

### 4. Assets to generate (deliver as a set)

| # | Asset | Spec / notes |
|---|-------|--------------|
| 1 | **App launcher icon** | Master 1024×1024. Blue squircle (gradient #2E7BFF→#0047C7), white receipt with ₹ and a green "paid" check. Provide: adaptive **foreground** (transparent, mark centered in the inner 66% safe zone) + **background** (solid #0F59E6 or subtle gradient), **legacy** icon, **monochrome** silhouette (Android 13 themed icons), **Play Store** 512×512. |
| 2 | **Splash / launch screen** | Centered logo mark on brand bg, minimal. Light + dark. 1080×1920 + vector. |
| 3 | **Onboarding illustrations** (3) | (a) "Pick your business" — shop fronts/verticals; (b) "Bill in seconds" — POS + receipt; (c) "Your data, backed up" — phone→cloud/Drive. 16:10, transparent bg, light+dark. |
| 4 | **Empty‑state illustrations** (6) | no products, no customers, no sales yet, offline, no backup, no search results. Friendly, ~1:1, ≤2 accent colors each. |
| 5 | **Status illustrations** (4) | success (payment done / backup done), warning (payment due), error (something went wrong), syncing/offline. |
| 6 | **Business‑type icon set** (24) | One consistent duotone line set for: kirana, supermarket, pharmacy, restaurant/QSR, cafe‑bakery, hardware, apparel, jewellery, electronics/mobile, stationery, salon/spa, repair centre, wholesale/distribution, auto parts/garage, optical, agri input, fresh produce/meat, laundry, gym/membership, rental, clinic/diagnostic, manufacturing, home services, tuition/institute. 24×24 + 48×48, single-stroke + duotone versions. |
| 7 | **Feature/category icons** | billing/POS, GST/tax, inventory/stock, credit/khata, purchasing/suppliers, reports/analytics, backup, roles/security, appointments, printing. Match set #6's style. |
| 8 | **Payment‑mode icons** (5) | Cash, UPI, Card, Bank, Credit/khata. Simple, monochrome + colored. |
| 9 | **Invoice/receipt graphics** | letterhead flourish, subtle watermark mark, QR‑code frame, "PAID/DUE" stamps (green/amber), thermal + A4 header ornaments. Print‑safe (pure black option, CMYK‑friendly). |
| 10 | **Badges / chips** | PAID, PENDING, LOW STOCK, OUT, OVERDUE, NEW — small pill graphics, low‑saturation bg + high‑saturation text. |
| 11 | **Avatars / placeholders** | neutral customer/supplier avatar, product placeholder, shop placeholder. |
| 12 | **Play Store listing** | feature graphic 1024×500, phone screenshot frames (device mockups), promo banner. On‑brand, shows real UI, adds short value copy ("Bill. Track. Grow."). |

### 5. Technical delivery
- **Formats:** vector **SVG** (primary, editable, layered, named layers) **and**
  raster **PNG** at @1x/@2x/@3x (mdpi→xxxhdpi) **and** **WebP** for app bundling.
- **Backgrounds:** transparent unless the asset is a filled scene.
- **Android densities** for icons: mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192;
  adaptive foreground/background 108dp with 72dp safe zone.
- **Naming:** kebab-case, semantic: `icon-launcher-foreground.svg`,
  `empty-no-products@3x.png`, `biztype-pharmacy-24.svg`, `illus-onboarding-billing-dark.svg`.
- **Folder layout:**
  ```
  assets/
    icon/        launcher + monochrome + play-store
    splash/
    illustrations/  onboarding, empty-states, status  (light/ + dark/)
    biztypes/    24 vertical icons
    features/    feature + payment-mode icons
    invoice/     stamps, watermark, ornaments
    badges/
    store/       play listing graphics
  ```
- Provide a **contact sheet** (all assets on one board) to verify consistency.

### 6. Hard rules (quality gates)
- ONE style across everything: same stroke weight, corner radius, shadow angle,
  color set, level of detail. If two assets could be from different apps, redo.
- No generic AI aesthetics: no purple‑on‑white gradients, no melty 3D blobs, no
  stock‑photo people, no random flourishes, no lorem shapes.
- Indian context: ₹ not $, local shop character, culturally neutral (no religious
  or regional bias, inclusive), realistic small‑retail scenes.
- Legible at small sizes: test every icon at 24px; every illustration at 120px.
- Ship light + dark variants; keep file sizes small (optimize SVG, compress PNG/WebP).
- Every asset must pass the contrast + colorblind‑safe checks in §2.

### 7. Output
For each asset, return: the SVG source, a short rationale (1 line), and the export
sizes. Start with the launcher icon and the onboarding + empty‑state illustrations
(highest impact), then the icon sets, then invoice/store graphics.
