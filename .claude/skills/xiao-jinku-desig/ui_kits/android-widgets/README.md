# Android Widgets Kit — 小金库

Three widget sizes — Small (1×1), Medium (2×1), Large (2×2) — in both Paper Realm and Night Reading themes. The catalog at the top of the kit shows each tile in isolation; below it, the widgets are placed on a faux Android home screen so you can judge them in context.

Tap-to-shuffle is implied (the small `shuffle` icon at the bottom-right of the Large tile). In real Android, tap-target events route to a `BroadcastReceiver` that rotates the quote — out of scope for this prototype.

## Files
- `index.html` — entry + all kit styles (inline for portability).
- `widgets.jsx` — `SmallWidget`, `MediumWidget`, `LargeWidget`, `HomeScreenContext`.

## Notes
- Widget radius is `28px` (Material You convention) — larger than in-app card radius. Widgets sit on the wallpaper and need stronger rounding to read as cards.
- Text scale shrinks per size (large 19px → medium 16px → small 14px).
- Source attribution truncates if too long; the seal mark stays.
