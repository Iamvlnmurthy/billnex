# BillNex visual asset system

Generated from `tools/generate_billnex_assets.py` and rasterized by
`tools/rasterize_assets.mjs`.

## Tokens

- Grid: 8px; icon grid: 24px
- Stroke: 2px at the 24px source size, round caps and joins
- Corners: 8–16px; pills use a full radius
- Shadow direction: 135 degrees
- Typeface: Inter with system sans fallback
- Palette: `#146CFF`, `#0055D1`, `#111C2D`, `#F4F6FC`, `#FFFFFF`,
  `#F0F3FF`, `#12B76A`, `#E6F6EE`, `#C15700`, `#FBEEDD`,
  `#BA1A1A`, `#C2C6D8`, and dark background `#0B1220`

## Structure

- `icon/`: adaptive foreground/background, legacy, monochrome, Play icon,
  and exact Android density launcher PNGs
- `splash/`: 1080×1920 light/dark launch artwork
- `illustrations/`: onboarding, empty, and status artwork in light/dark
- `biztypes/`: 24 business-category icons in light/dark
- `features/`: product feature and payment-mode icons in light/dark
- `invoice/`: stamps, watermark, QR frame, and print ornaments
- `badges/`: status chips plus neutral placeholders
- `store/`: Play feature graphic and reusable screenshot frame

Every SVG has PNG and lossless WebP exports at 1×, 2×, and 3×. The launcher
also includes exact mdpi–xxxhdpi exports under `icon/android/`.

## Regenerate

```powershell
python tools/generate_billnex_assets.py
node tools/rasterize_assets.mjs
python -c "import sys; sys.path.insert(0,'tools'); import generate_billnex_assets as g; g.contact_sheet()"
```

Review the complete system in `contact-sheet.png`. Icons are rendered at their
native 24px size on that sheet; illustrations are rendered at 120px or larger.
