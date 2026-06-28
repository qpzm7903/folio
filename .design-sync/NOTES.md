# design-sync notes — 小金库 Design System

- Claude Design project: **小金库 Design System** `e8d12aa9-3047-48f9-9a30-75441b21b756`
  (bundle namespace `DesignSystem_e8d12a` — the `e8d12a` prefix matches the project id).
- The design system lives **inside this repo** at `.claude/skills/xiao-jinku-desig/`
  (it is both the Claude skill and the design-sync source/target).
- 2026-06-28: remote project was edited on 2026-06-27, ahead of the local copy
  (last committed 2026-06-16). Ran a **pull** (remote → local). Only the prototype +
  artifacts had changed: `_ds_bundle.js`, the 5 android-app `*.jsx`, `kit.css`,
  `ui_kits/android-app/index.html`, and the app-card subtitle in `_ds_manifest.json`.
  The design-system foundation (tokens, 6 themes, preview cards, README, widgets
  prototype) was already in sync.
- Tool note: `DesignSync.get_file` returns content into the agent (no download-to-disk),
  so a pull is reconstructed via `json.loads` on the exact tool output. JSX byte-exactness
  was verified against the bundle header hashes (`sha256(file)[:12]`).
- 2026-06-29: remote was ahead again. New additions pulled (remote → local):
  1. `styles.css` — entry stylesheet (imports `colors_and_type.css`)
  2. `design_handoff_xiaojinku/` — full design-handoff directory with:
     - `README.md` — complete design spec (8 screens, data model, 6 themes, 9 layouts)
     - `design_files/colors_and_type.css` — all 6 theme token blocks + typography scale
     - `design_files/assets/paper-grain.svg` — SVG paper texture (feTurbulence)
     - `design_files/android-app/` — interactive React prototype:
       `index.html`, `app.jsx`, `components.jsx`, `screens.jsx`,
       `display-layouts.jsx`, `widget-editor.jsx`, `kit.css`
  Screenshots directory (`screenshots/`) skipped — 9 PNG binaries exceed 256KB cap.
