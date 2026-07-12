# BillNex — GPT-Image 2.0 prompt set (raster images)

Ready-to-paste prompts for photorealistic/illustrative **raster** images (store
listing, marketing, hero, onboarding, illustrations) — distinct from the SVG
icon-system brief in `ASSET_GENERATION_PROMPTS.md`. Each prompt is standalone.

## Global style suffix (append to EVERY prompt)
> Style: clean modern SaaS product illustration, flat with subtle depth and soft
> long shadows, geometric shapes, rounded corners, 2px consistent line weight.
> Palette strictly: primary blue #146CFF, deep blue #0055D1, navy #111C2D, cool
> surface #F4F6FC, success green #12B76A, amber #C15700. Indian small-retail
> context, rupee ₹ (never $). No text unless specified, no logos, no watermarks,
> no photoreal 3D, no purple gradients, no clutter, high contrast, accessible.
> Centered subject with generous negative space. Consistent series look.

## Sizing / format notes
- Onboarding & empty states: **1024×1024** (or 1200×900), transparent PNG.
- Store feature graphic: **1024×500** with room for a short headline.
- Hero/marketing: **1600×1000**. Screenshots-in-device: **1290×2796** frame.
- Ask for light **and** dark background versions of illustrations.

---

## A. App store & marketing

1. **Play Store feature graphic (1024×500)**
   > A confident banner for an Indian billing app: on the left a stylized phone
   > showing a POS bill with a green "paid" check; on the right open space for a
   > headline. Blue #146CFF background with a subtle mesh, a small shop and a ₹
   > receipt motif. Leave the right third clean for text. [+global suffix]

2. **Hero image (1600×1000)**
   > A cheerful Indian shopkeeper at a clean counter tapping a tablet that shows
   > a crisp digital bill; a small thermal printer emits a receipt with a ₹
   > total; soft blue ambient light. Warm, trustworthy, modern. [+global suffix]

3. **"Works offline" marketing tile (1200×900)**
   > A phone billing screen glowing while a faint cloud with a slash floats
   > above and a green sync arrow curves back — conveying "bills even without
   > internet, syncs later." Minimal, blue/navy. [+global suffix]

## B. Onboarding (3, 1024×1024, light + dark)

4. **Pick your business**
   > A friendly grid of small Indian shop-front tiles (kirana, pharmacy, cafe,
   > salon, hardware) with one tile highlighted in blue and a check — choosing a
   > business type. [+global suffix]

5. **Bill in seconds**
   > A hand adding items to a POS cart on a phone, a receipt sliding out with a
   > ₹ total and a green paid check; small motion accents. [+global suffix]

6. **Your data, backed up**
   > A phone with a shield/receipt, an upward arrow into a soft cloud and a
   > Google-Drive-style folder — "your shop data, safely backed up to your own
   > cloud." No brand logos. [+global suffix]

## C. Empty-state illustrations (1024×1024, light + dark)

7. **No products yet** — an open, empty shop shelf with a friendly "+" tag,
   inviting to add items. [+global suffix]
8. **No customers yet** — a single outlined person card with a subtle ₹ tag,
   gentle and inviting. [+global suffix]
9. **No bills yet** — a blank receipt with a soft dashed outline and a small
   sparkle. [+global suffix]
10. **No results** — a magnifier over an empty list, calm, not error-like.
    [+global suffix]
11. **Offline** — a small cloud with a slash and a queued-sync arrow; reassuring,
    not alarming. [+global suffix]
12. **No internet / retry** — a friendly plug/wifi motif with a circular retry
    arrow. [+global suffix]

## D. Status illustrations (1024×1024)

13. **Success** — a green circular check with a soft burst; "payment done /
    backup complete." [+global suffix]
14. **Warning / payment due** — an amber triangle with a ₹, calm and clear.
    [+global suffix]
15. **Error** — a soft red circle with an X, non-aggressive. [+global suffix]
16. **Syncing** — two blue circular arrows mid-rotation with a subtle trail.
    [+global suffix]

## E. Feature spotlights (1200×900, for the website/deck)

17. **GST invoice** — a neat A4 tax invoice with visible CGST/SGST lines and a
    ₹ total, a QR in the corner. [+global suffix]
18. **Khata / credit ledger** — a customer card with a running ₹ balance and a
    small "reminder" bell. [+global suffix]
19. **Inventory** — shelves/boxes with a low-stock amber tag and a barcode.
    [+global suffix]
20. **Reports** — a simple dashboard with a bar chart, a payment-mix donut, and
    a ₹ KPI tile, in-brand colors. [+global suffix]

## F. Business-type spot art (optional, 512×512 each)
> A single small, friendly scene per vertical, same series style, blue/navy with
> one accent: kirana grocery counter; pharmacy cross + strip; restaurant table +
> KOT; jewellery scale + ring; salon chair; hardware tools; wholesale cartons;
> electronics phone + IMEI tag; bakery cake; optical glasses; auto garage.
> [+global suffix]

---

### How to keep the set consistent
1. Generate #7 (no-products) first as the **style anchor**; paste it back as a
   reference image for #8–#20 ("match this exact style/palette/line-weight").
2. Always request the light version, then "same illustration on dark navy
   #0B1220 background, strokes/fills brightened for contrast."
3. Export at 3× and downscale for crispness; keep transparent backgrounds.
4. Reject anything with text artifacts, extra fingers, logos, or off-palette
   colors — regenerate rather than accept.

Wire outputs into `billnex_app/assets/illustrations/{light,dark}/` (same naming
as the existing set) and they appear automatically via `BxIllustration`.
