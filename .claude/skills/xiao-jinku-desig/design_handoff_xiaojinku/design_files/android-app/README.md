# Android App UI Kit — 小金库

Interactive mobile prototype showing the core screens:

- **Library** (`library`) — your collected quotes, with today's pick at top, tag filter, and FAB to add.
- **Editor** (`editor`) — single-quote composer + bulk import bottom sheet.
- **Widget** (`widget`) — customizable home-screen widget: size (incl. 4×4), background, opacity, text scale, cadence.
- **Settings** (`settings`) — cadence, theme, fonts, import/export.

Both themes (Paper Realm + Night Reading) are mounted side-by-side in `index.html` so you can compare directly. Toggle between them inside the phone via Settings → 主题.

## Files
- `index.html` — entry, loads React + the three scripts below.
- `kit.css` — kit-local component styles. Inherits tokens from `../../colors_and_type.css`.
- `components.jsx` — `Phone`, `TopBar`, `BottomNav`, `QuoteCard`, `SettingRow`, `Fab`, `Icon`.
- `screens.jsx` — `LibraryScreen`, `EditorScreen`, `SettingsScreen`, `ImportSheet`.
- `widget-editor.jsx` — `WidgetEditorScreen` + live preview widget.
- `app.jsx` — App shell, state, screen switching.

## Try it
1. Click the **+** FAB → type a quote → 收入金库.
2. From the top bar of the editor, tap **↑** → bulk-paste multiple lines.
3. Bottom nav → 组件 to customize the home-screen widget.
4. Bottom nav → 设置 to flip theme.
