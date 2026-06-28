# Handoff: 小金库 (Xiǎo Jīnkù) — Quote-keeper Android App

## Overview
小金库 ("little treasury") is a personal quote-keeping Android app. The user collects short
quotes ("金句"), organizes them with tags, browses a full-screen "首页 (Home)" wallpaper view
that cycles quotes through 9 typographic layouts, and configures a home-screen widget that
surfaces one quote at a time. The aesthetic is a calm, literary "小清新绿" (fresh-green)
direction built on serif Chinese typography, paper textures, and classical-color (传统色) themes.

The app has three bottom-nav destinations — **首页 (Home)**, **金库 (Library)**, **我的 (Profile)** —
plus two pushed sub-screens: the **Editor** (compose / add a quote) and the **Widget editor**
(reached from Profile → 自定义小组件).

## About the Design Files
The files in `design_files/` are **design references created in HTML/CSS/React-via-Babel** —
runnable prototypes that demonstrate the intended look, layout, and interaction. **They are not
production code to copy directly.** The Babel-in-the-browser setup, the `window.*` global sharing
between `.jsx` files, and the `<img>`-based Lucide icons are prototype conveniences, not
production patterns.

Your task is to **recreate these designs in the target codebase's environment** using its
established patterns and libraries (React Native, Jetpack Compose, Flutter, etc.). If no codebase
exists yet, choose the most appropriate framework for an Android-first app and implement there.
Reproduce the visual design faithfully (see Fidelity) while using idiomatic components, real icon
assets, and a proper state/store layer instead of the prototype's in-memory React state.

## Fidelity
**High-fidelity.** Colors, typography, spacing, radii, shadows, and interactions are all final and
specified via design tokens (see `design_files/colors_and_type.css`). Recreate the UI
pixel-faithfully using the exact token values. The phone bezel/notch/status-bar chrome in the
prototype is only a presentation frame — ignore it; build the screens, not the mock device.

---

## Design Tokens
All tokens live in `design_files/colors_and_type.css` as CSS custom properties. Components
reference **semantic** roles (`--fg-1`, `--bg-card`, `--accent`, …), and each theme remaps the
raw palette behind those roles. Port this two-layer structure (raw palette → semantic roles →
6 themes) into the target platform's theming system.

### Semantic roles (what components actually use)
- Surfaces: `--bg-page`, `--bg-surface`, `--bg-card`, `--bg-raised`, `--bg-overlay`
- Text: `--fg-1` (primary), `--fg-2`, `--fg-3`, `--fg-muted`, `--fg-on-accent`
- Accent: `--accent`, `--accent-pressed`, `--accent-soft`, `--accent-2`, `--mark` (seal color)
- Lines: `--border-1`, `--border-2`, `--divider`
- Status: `--success`, `--warning`, `--danger` (`#a04030`)

### Themes (6) — set via `data-theme` on the screen root
| key | name | en | mode |
|---|---|---|---|
| `paper` (default, no attr) | 青纸 | Tea Paper | light |
| `celadon` | 天青 | Celadon | light |
| `moonwhite` | 月白 | Moon White | light |
| `cinnabar` | 绛霞 | Cinnabar | warm light |
| `night` | 林夜 | Forest Night | dark |
| `dai` | 青黛 | Ink Indigo | dark |

Default light palette (青纸): page `#eef0df`, card `#e2e6cf`, raised `#fbfcf3`, primary ink
`#1d2a1f`, accent matcha `#7ba05b` (pressed `#4a6b35`). Each theme overrides the full palette —
read the `[data-theme="…"]` blocks for exact hex per theme. Dark themes (`night`, `dai`) also
override the shadow tokens.

### Typography
- Display / body serif: `--serif-display` / `--serif-body` = `"Noto Serif SC", "EB Garamond", "Songti SC", Georgia, serif`
- Italic (attributions, captions): `--serif-italic` = `"EB Garamond", "Noto Serif SC", Georgia, serif`
- UI sans (labels, tags, controls): `--sans-ui` = `"Noto Sans SC", -apple-system, "PingFang SC", sans-serif`
- Type scale: hero quote 44px · quote 28px · h1 26px · h2 20px · h3 17px · body 15px · small 13px · label 11px
- Line-heights: tight 1.15 · snug 1.35 · normal 1.55 · loose 1.8 (quotes use **loose**)
- Tracking: tight −0.02em · wide 0.08em · label 0.16em (uppercase labels)

### Spacing scale
4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 64 / 80 px (`--space-1` … `--space-20`).

### Radii
xs 2 · sm 4 · md 8 · lg 14 · xl 22 · pill 999 px. Cards use ~14–18px; widget cards 28px; chips/pills `pill`.

### Shadows (green-tinted, low spread)
- `--shadow-1`: `0 1px 0 rgba(29,42,31,.04), 0 1px 2px rgba(29,42,31,.06)`
- `--shadow-2`: `0 2px 4px rgba(29,42,31,.06), 0 4px 12px rgba(29,42,31,.05)`
- `--shadow-3`: `0 8px 24px rgba(29,42,31,.10), 0 2px 6px rgba(29,42,31,.06)`

### Motion
- Easing: `--ease-out` cubic-bezier(.22,.61,.36,1) · `--ease-paper` cubic-bezier(.4,0,.2,1)
- Durations: fast 160ms · base 240ms · slow 480ms · page 640ms

### Golden-ratio anchoring
Home-layout quote blocks rest on the **upper golden line (≈38.2% from top)**, not dead-center
(`--phi-minor: 0.382`). Preserve this optical anchor in full-screen layouts.

---

## Data Model
A single entity, **Quote**:
```
Quote {
  id:    number/uuid
  q:     string        // the quote text
  tags:  string[]      // ZERO-OR-MORE tags; empty falls back to ["未分类"] (Uncategorized)
  src:   string        // attribution source (currently "—" placeholder)
  date:  string        // display date, e.g. "5月 20日" or "刚刚" (just now)
}
```
Plus a separate ordered **tags** list (`string[]`) of all known tag names. `"全部"` (All) is a
reserved virtual tag used only as a filter — it is never stored on a quote and never deletable.

> **A quote can have multiple tags.** This is core. All tag UI is multi-select; all filtering uses
> `quote.tags.includes(tag)`; layouts that show a single category use the **first** tag
> (`tags[0]`, falling back to "未分类").

Seed data: 10 quotes across tags 坚持与回响 / 完整而非完美 / 旅程与抵达 / 自我接纳 (several quotes carry 2 tags).
See `SEED_QUOTES` in `design_files/android-app/screens.jsx`.

---

## Screens / Views

### 1. 金库 — Library  (`screens.jsx` → `LibraryScreen`)
**Purpose:** browse, filter, and bulk-manage the quote collection. The app's home tab.

**Layout (top→bottom):**
- **TopBar**: title "小金库", italic subtitle "est. 2026", trailing icon buttons: `search`, `check-square` (enter multi-select).
- **Hero**: small italic label "今天的金句" (Today's quote) then a **dark** QuoteCard (variant=dark) showing the first quote; tapping it navigates to 首页 (Home).
- **Section header**: "你的金库" left, "N 句" count right (sans, 11px, `--fg-3`).
- **Tag filter row** (`.tag-row`, flex-wrap, gap 6px): one pill per tag (incl. "全部"), the active one filled (`.tag.active` → bg `--ink-900` / on dark themes `--accent`, text `--paper-50`). Last pill is a dashed **"✎ 管理"** (manage) pill that opens the Tag Sheet.
- **Quote list**: a QuoteCard per filtered quote (excluding the hero).
- **FAB** (bottom-right, accent circle, `plus` icon) → Editor.
- **BottomNav**.

**QuoteCard** (`components.jsx` → `QuoteCard`):
- Container: `--bg-card` (dark variant uses a gradient/inverted treatment), radius ~14–18px, padding ~16px, `--shadow-1`.
- `.q`: serif-display 18px, line-height loose, `text-wrap: pretty`, color `--fg-1`.
- `.qmeta` row (sans 11px, `--fg-3`): **left = tag list**, right = date.
  - Multiple tags render as italic `.qtag` spans separated by a "·" bullet (e.g. *坚持与回响 · 自我接纳*). Single/no tags fall back to the `source` string.
- Select mode adds a leading circular checkbox `.qcheck` (22px; `.on` = filled accent with white `check`); whole card toggles selection; selected card gets accent border.

### 2. Library — Multi-select (batch delete quotes)
Triggered by the TopBar `check-square` action.
- TopBar becomes a **select bar**: leading `x` (cancel), center count ("选择金句" / "已选 N 句"), trailing text button "全选 / 取消全选".
- Today's hero card folds into the selectable list so everything is selectable.
- Each card shows the `.qcheck`; tapping toggles.
- **Bottom action bar**: full-width danger button "取出 N 句" (`trash-2` icon), disabled (40% opacity) when nothing selected.
- Confirm via centered **ConfirmDialog**: title "从金库取出这 N 句？", body "取出后将不再出现在首页和组件里。", actions 取消 / 取出. On confirm: remove those ids, exit select mode.
- Copy note: the product uses the gentle metaphor **"取出" (take out)** rather than "delete" for quotes.

### 3. Tag Sheet — add + batch-delete tags  (`screens.jsx` → `TagSheet`)
Bottom sheet (scrim + bottom-anchored panel, grabber handle), opened from Library's "管理" pill.
- Title "管理标签", italic help "添加新标签，或勾选后批量删除。".
- **Add row** (`.tag-add`): text input (placeholder "新标签…", maxLength 8, Enter submits) + accent "＋ 添加" button. Button disabled when empty or duplicate. Duplicate shows warning "「X」已存在".
- **Manage head**: left "共 N 个标签" / "已选 N 个" · right "全选 / 取消全选".
- **Tag chip list** (`.tag-manage-list`, wrap, max-height 180 scroll): each tag is a selectable chip with a leading circular check `.tcheck` (16px; `.on` filled accent). Picked chip = accent-tinted bg + accent border. "全部" is excluded (not editable).
- **Danger button** "删除 N 个标签" (`trash-2`), disabled when none picked → ConfirmDialog ("删除这 N 个标签？", body "标签下的金句会移到「未分类」，不会被删除。").

### 4. Editor — compose / add a quote  (`screens.jsx` → `EditorScreen`)
Pushed screen (from FAB).
- **TopBar**: title "新的一句", actions `upload` (批量导入 → Import Sheet) and `x` (close → Library).
- **Composer**: large auto-focus `textarea` (serif, placeholder "写下一句你最近读到的话…").
- **Tag picker** — multi-select:
  - Label "贴标签（可多选）".
  - Row of existing-tag pills (`.tag`); tapping toggles `.active` (can light up several at once).
  - A dashed **"＋ 新标签"** pill; tapping turns it into an inline input (autofocus, maxLength 8). Enter/blur commits: creates the tag (or selects it if it already exists) AND adds it to the current quote's selection. Esc cancels. Duplicate shows "「X」已存在，将直接选用".
- **Footer tools** row: italic hint — "已选 N 个标签" or "未选标签将归入「未分类」" — plus an `image` icon button (attach image; visual only).
- **Primary button** (block): "收入金库", disabled (40% opacity) until text is non-empty. On save: create quote with chosen tags (or `["未分类"]`), register any new tags, return to Library.

### 5. Import Sheet — bulk add  (`screens.jsx` → `ImportSheet`)
Bottom sheet. Title "批量导入", help "把一整段话粘进来，会自动分行。", multiline textarea, live "识别到 N 句" count (splits on blank lines, trims, drops empties), block button "全部收入金库". Imported quotes get tag `["导入"]`.

### 6. 首页 — Home  (`screens.jsx` → `DisplayScreen`, layouts in `display-layouts.jsx`)
**Purpose:** a full-screen, distraction-free wallpaper that displays one quote at a time and can
cycle through 9 different typographic layouts. First bottom-nav tab.
- Optional photo background (gradient stand-in) toggled by the `image` control; a paper-grain `.grain` overlay always sits on top.
- A **layout pip** (top area) briefly names the current layout (e.g. "页 · Page") then fades.
- Center: the active layout component renders `current` quote; switching layout or quote re-keys the node to trigger a crossfade.
- **Controls** (floating row, above the nav): `shuffle` (next quote, no-repeat — see State), layout glyph (cycle layout), `image` (toggle photo bg), `bookmark` (save; visual only).
- **BottomNav**.

**The 9 layouts** (`LAYOUTS` / `LAYOUT_COMPONENTS`) — each uses the quote's **primary tag** as its
category label and steps type size down for longer quotes via a `data-len` tier
(`tiny ≤10 / short ≤16 / medium ≤26 / long ≤40 / xlong`):
1. **页 Page** — header (category · rule · "金句"), centered quote body, footer (rule · date).
2. **竖 Vertical** — vertical-writing quote, rule, category + "金" seal.
3. **引 Pull** — giant open-quote, body line, attribution + close-quote.
4. **时 Lock** — lockscreen: big clock "9:41" + date, leaf glyph, quote caption + attribution.
5. **满 Fullbleed** — oversized quote filling the frame + "— tag".
6. **印 Stamped** — first character as a large matcha "seal", remaining text beside it.
7. **条 Ribbon** — quote inside a horizontal accent band.
8. **片 Card** — paper card with corner ticks on a colored field; category, quote, rule, "小金库 · Folio" footer.
9. **织 Interleaved** — Roman-numeral index + quote split into clauses on hairline rules.

### 7. 我的 — Profile / Settings  (`screens.jsx` → `SettingsScreen`)
TopBar "我的" / "profile". Grouped `SettingRow`s under section headers:
- **小组件**: 自定义小组件 (→ Widget editor), 更换频率 (value "30 分钟"), 不重复轮播 (toggle), 显示出处 (toggle), 背景图片 (value).
- **字体与外观**: 主题 (value = current theme name+en; tapping **cycles** through the 6 themes and re-themes the whole app), 字号, 字体.
- **导入与导出**: 批量导入, 导出金库 (.txt), 从备忘录导入.
- **关于**: app blurb, 给作者写一句. Footer "v 0.1 · 共 N 句已入库".

`SettingRow` = leading label + optional sub caption, optional right-aligned value, optional iOS-style toggle (`.toggle`/`.dot`, `.on` = accent), optional chevron.

### 8. Widget editor  (`widget-editor.jsx` → `WidgetEditorScreen`)
**Purpose:** configure the home-screen widget; left = live preview, below = controls. Reached from
Profile. (Theme is intentionally NOT here — it's global, in Profile — to avoid duplicating the
背景/主题 concepts.)

- **Live preview** (`PreviewWidget`): a rounded card (radius 28) rendering the current quote at the
  chosen size/background/opacity/scale. Background is a separate absolutely-positioned layer so its
  **opacity** can drop and let the home screen show through.
- **Controls** (segmented `Seg` + chip `ChipRow` + slider):
  - **尺寸 (Size)** segmented — `小 1×1` (160×160) · `中 2×1` (320×156) · `大 2×2` (320×320) · `巨 4×4` (340×340). Larger sizes show a top brand mark and more text lines.
  - **字号 (Text scale)** — segmented (`TEXT_SCALES`).
  - **背景 (Background)** chips — `纸面 paper` (theme raised surface) · `留白 white` (#ffffff / ink #1f1d1a) · `米白 rice` (#f3ecda / #2a2620) · `纸白 paperwhite` (#f7f6f1 / #26241f) · `墨色 ink` · `绿叶 leaf` (accent gradient) · `照片 photo` (gradient stand-in).
  - **卡片不透明度 (Card opacity)** — slider 40–100% (step 5), default 100%; controls the background layer's opacity only.
  - **来源/频率** (source = which tag pool to draw from; cadence) and a **显示出处** toggle (`showSource`).
- Source filtering is multi-tag aware: a quote qualifies if its `tags` include the chosen source.

---

## Interactions & Behavior
- **Navigation**: bottom nav swaps 首页 / 金库 / 我的; FAB and TopBar actions push Editor / sheets; sheets and the ConfirmDialog are overlays dismissable by tapping the scrim.
- **Theme switching**: changing theme (Profile → 主题) sets `data-theme` on the screen root and recolors everything live, including all 6 themes; default `paper` uses no attribute.
- **Multi-select (quotes)**: enter via TopBar; tap cards to toggle; 全选/取消全选; delete via bottom bar + confirm; exit restores normal Library.
- **Tag add**: inline in Editor (dashed pill → input) and in the Tag Sheet (add row). Enter commits; duplicates are reused, not duplicated; tag names capped at 8 chars.
- **Tag delete**: single (Tag Sheet chip + confirm) or batch (Tag Sheet multi-select). Deleting a tag **removes it from every quote**; a quote left with no tags falls back to `["未分类"]` (which is auto-added to the tag list). Quotes are never deleted by tag deletion.
- **Home cycling**: `shuffle` advances with a **no-repeat shuffle** (`useNoRepeatShuffle`) — every quote shows once per round before any repeats; layout cycling re-keys for crossfade.
- **Crossfades / pips**: layout name pip fades after ~1.5s; quote/layout changes crossfade via React `key` remount.
- **Disabled states**: primary/danger buttons drop to 40% opacity and are non-interactive when their precondition isn't met (empty text, nothing selected).

## State Management
Prototype keeps everything in React state at the app root (`app.jsx`); port to the codebase's
store/persistence layer:
- `quotes: Quote[]` (seeded) — CRUD: `onSave(text, tags[])`, `onImport(lines[])`, `onDeleteQuotes(ids[])`.
- `tags: string[]` — `onAddTag(name)`, `onDeleteTag(name)`, `onDeleteTags(names[])`. Deletion uses a shared `stripTags(quote, killSet)` that removes the tags and falls back to 未分类.
- `theme: themeKey` — global, cycled from Profile.
- Per-screen local UI state: Library filter tag + select-mode + picked-set; Tag Sheet add-text/picked/confirm; Editor text/picked-tags/new-tag-input; Home layout index + shuffle position; Widget editor size/bg/opacity/scale/source.
- **Persistence**: the real app should persist quotes, tags, theme, and widget config to local storage / DB. Widget config must be readable by the OS widget process.

## Assets
- **Icons**: prototype loads **Lucide** icons as remote SVGs (`lucide-static`). Names used: `search`, `check-square`, `check`, `x`, `plus`, `pencil`, `trash-2`, `upload`, `image`, `bookmark`, `shuffle`, `chevron-left`, `home`, `book-open`, `user-round`, `settings`. Use a bundled Lucide (or the platform's icon set mapped to these) in production.
- **Paper grain**: `design_files/assets/paper-grain.svg` — tiled texture overlay (page bg, widget card, Home `.grain`), low opacity, multiply blend.
- **Fonts**: Google Fonts **Noto Serif SC**, **Noto Sans SC**, **EB Garamond** (imported at top of `colors_and_type.css`). Bundle these (or platform equivalents: Songti/PingFang SC) for offline use.
- No raster photos — the "photo" background is a CSS gradient placeholder; wire to a real wallpaper/photo picker.

## Files
In `design_files/`:
- `colors_and_type.css` — **all design tokens** + the 6 themes + base element typography. Start here.
- `assets/paper-grain.svg` — texture asset.
- `android-app/index.html` — entry; mounts the prototype (open in a browser to interact with it).
- `android-app/app.jsx` — app shell, root state, all CRUD handlers, two side-by-side phone instances.
- `android-app/components.jsx` — primitives: `Icon`, `Phone`, `StatusBar`, `TopBar`, `BottomNav`, `QuoteCard`, `SettingRow`, `SettingsGroup`, `Fab`, theme helpers.
- `android-app/screens.jsx` — `SEED_QUOTES`, `qTags`/`qPrimary` helpers, `useNoRepeatShuffle`, `ConfirmDialog`, `LibraryScreen`, `EditorScreen`, `DisplayScreen` (Home), `SettingsScreen`, `TagSheet`, `ImportSheet`.
- `android-app/display-layouts.jsx` — the 9 Home layout components + `LAYOUTS` registry + length-tier helper.
- `android-app/widget-editor.jsx` — `WidgetEditorScreen` + `PreviewWidget` + size/bg/scale option tables.
- `android-app/kit.css` — all component-level styling (the layout/visual source of truth alongside the tokens).
- `android-app/README.md` — short prototype-local notes.

To run the prototype: open `design_files/android-app/index.html` in a browser (needs internet for the CDN React/Babel/fonts/icons).
