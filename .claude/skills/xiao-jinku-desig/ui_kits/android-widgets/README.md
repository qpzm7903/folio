# Android Widgets Kit — 小金库 · Folio

Three widget sizes — Small (1×1), Medium (2×1), Large (2×2) — in **Tea Paper** and **Forest Night** themes. The kit has three sections:

1. **尺寸目录 · Catalog** — each tile in isolation.
2. **可拖动缩放 · Resizable** — an interactive widget you drag (bottom-right handle) to resize. It snaps to the Android home grid and demonstrates how content reflows + type auto-fits.
3. **放在主屏上 · In situ** — the widgets on a faux Android home screen for context.

Tap-to-shuffle is implied (the `shuffle` icon). In real Android, tap events route to a `BroadcastReceiver` that rotates the quote — out of scope for this prototype.

## Resizing & long quotes — the design rule

Android home widgets are **user-resizable** (long-press → drag handles; the OS snaps to grid cells). Our widget must respond to *whatever* cell footprint the user drags it to, and to *however many characters* the quote has. Two mechanisms, working together:

**1. Content reflow by footprint** — chrome appears/disappears with available space:

| Footprint | Shows |
|---|---|
| 1×1 | quote only (auto-fit), seal tucked in a corner |
| 2×1 (wide, 1 row) | quote + inline attribution |
| ≥ ?×2 | quote + footer (category + shuffle) |
| ≥ 3×2 | + brand lockup (金 seal · 小金库 · Folio) |

**2. Type auto-fit by box × length** — `fitFont(w, h, charCount, reservedChrome)`:
- Font size ≈ `√(innerArea / charCount) × k`, clamped to **12–30px**.
- Bigger box → bigger type. More characters → smaller type.
- A computed `-webkit-line-clamp` is the **graceful floor**: if a quote is genuinely too long for a short-wide box, it clamps with an ellipsis rather than overflowing. Make the widget taller and the full quote returns at a comfortable size.

**3. Golden vertical anchor on large tiles** — once a widget is large enough to have free vertical space (≥ 4 cells, ≥ 2 rows), the quote no longer centers; it rests on the **upper golden line (≈38.2% from top)** via flex spacers split `0.382 : 0.618`. This matches the screensaver's anchor (see root `README.md → Golden ratio`) and reads as composed rather than static. Small tiles (1×1, 2×1) stay centered — there isn't enough room for the anchor to matter.

This is the **same dual principle as the screensaver** (`ui_kits/android-app/display-layouts.jsx`): scale by container size *and* by text length, with hard min/max bounds.

### Production note (Flutter / Android)
- **Android Glance**: read `OPTION_APPWIDGET_MIN_WIDTH/HEIGHT` (and max) from the options bundle in `provideGlance`, map to a cell count, and pick the reflow tier + font from that. Glance has no `cqw`, so compute font in Kotlin.
- **Flutter `home_widget`**: the native widget is drawn in Glance/SwiftUI; pass the chosen quote + a `sizeCategory` from Flutter via SharedPreferences and let native pick the layout.
- The `auto_size_text` package replicates `fitFont` inside the Flutter app's own preview screens.

## Files
- `index.html` — entry + all kit styles (inline for portability).
- `widgets.jsx` — `SmallWidget`, `MediumWidget`, `LargeWidget`, `ResizableDemo`, `ResizableWidget`, `HomeScreenContext`.

## Notes
- Widget radius is `24–28px` (Material You convention) — larger than in-app card radius. Widgets sit on the wallpaper and need stronger rounding to read as cards.
- The seal (金) uses the bamboo mark color; on Forest Night it brightens.
