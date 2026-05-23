# 小金库 Design System

> 小金库 · Folio (xiǎo jīn kù) is a personal collection of golden sayings (金句).
> Random, intimate, paced. Built to slow you down for a moment.

## What is the product?

小金库 displays the user's collected quotes — one at a time — on phone widgets, lock-screen wallpapers, and a desktop screensaver. Quotes rotate on a user-chosen cadence (every 5 min, every hour, etc.). Users write their own quotes, paste them in bulk, attach custom background images, and revisit a private library.

**Core features**

1. Screensaver / wallpaper mode that randomly displays a quote over a custom background.
2. Phone widget (Android, small / medium / large) rotating from the user's library.
3. Adjustable rotation cadence — "switch every N minutes."
4. Bulk import — paste a block of text and split into many quotes at once.

**Primary platform**: Android (with Android-style widget conventions)
**Primary language**: Simplified Chinese (简体中文). UI strings are Chinese-first; English appears only as italic Latin flourishes and labels.
**Audience**: Readers, students, and knowledge workers (18–35) who already keep quote collections — in Notes, screenshots, or notebooks — and want them somewhere they'll actually re-encounter.

## Sources & references

This design system was invented from scratch — **no codebase, Figma, or existing brand was provided.** Direction emerged from the product description and user-chosen mood ("warm, paper-textured, journal/zine") + palette (soft pastel — peach / dusty blue / slate).

If/when real product code, brand assets, or competitor benchmarks exist, replace the foundations and re-derive UI kits from the actual source.

## Two parallel directions

This system carries **two contrasting themes** that share spacing, type, and component vocabulary:

| | **A. 青纸 Tea Paper** (default) | **B. 林夜 Forest Night** |
|---|---|---|
| Mood | Soft afternoon, garden, fresh paper | Bamboo forest, late evening, lamp-light |
| Surface | Tea cream `#eef0df` | Deep forest `#0e1612` |
| Type color | Moss ink `#1d2a1f` | Cream-green `#e6ebd9` |
| Primary action | Matcha `#7ba05b` | Bright mint `#9ec88a` |
| Accent 2 | Jade water `#7ea8a3` | Brighter jade |
| Mark / seal | Bamboo `#b8a866` | Warm bamboo `#d4c47e` |
| Activation | default | `[data-theme="night"]` or `prefers-color-scheme: dark` |

The product itself should let users switch — these aren't separate brands, they're the same product at different times of day.

---

## Content fundamentals

**Voice.** Quiet, literary, second-person (你). Like a friend who reads a lot, not a self-help app. Never preachy. Never exclamation marks in UI copy — the quotes themselves do the talking; the chrome stays out of the way.

**Casing & punctuation.**
- Chinese: full-width punctuation (，。：「」).
- No emoji anywhere in product copy. They break the "old-paper" feeling.
- English appears italicized, lowercase, sparingly — like a footnote or a marginal note (`*Folio*`, `*est. 2026*`).
- UI labels (small caps) are Latin only, e.g. `LIBRARY`, `SETTINGS`. Chinese labels stay normal weight, never small-caps.

**I vs. you.** Always 你 (you). The app refers to itself as 小金库 ("treasury"), never "I" / "我" / "我们".

**Specific copy examples** (use these as templates):
- Onboarding: `欢迎来到你的小金库。` / `先放一句你最近读到的话吧。`
- Empty state: `这里还很空。` / `贴一句话进来，让它有一天突然出现在屏幕上。`
- Save toast: `已收入金库。` (NOT "保存成功！" — too SaaS.)
- Delete confirm: `从金库取出这句话？` (NOT "确定删除？")
- Time picker: `每 30 分钟更换一次。`
- Bulk import header: `把一整段话粘进来，会自动分行。`
- Settings sections: `屏保`, `小组件`, `字体与颜色`, `导入与导出`.
- Error toast: `没能保存，再试一次？` (questioning, not stern)

**What we never say.** "立即体验" / "解锁更多" / "升级 PRO" / "AI 智能" — anything that sounds like a SaaS landing page. Promotional language breaks the trust.

**Quote length.** Quotes are 8–200 Chinese characters typically. The display layout adapts: short quotes get larger type and more whitespace; long quotes get tighter line-height and a slightly smaller scale.

---

## Visual foundations

### Type

| Token | Family | Used for |
|---|---|---|
| `--serif-display` | **Noto Serif SC** | Quote display, all headings, body |
| `--serif-italic` | **EB Garamond Italic** | Latin marginalia, attributions, "est. 2026" |
| `--sans-ui` | **Noto Sans SC** | UI labels, button text, settings rows |

We are nearly mono-typographic — one serif does almost all the work. The italic Latin appears only as a "wax-seal flourish" on chrome (title bars, footer, splash). Sans-serif is reserved for *tiny* UI labels where the serif would feel ornamental — buttons in settings, tab labels, badges. **A whole screen of Noto Sans SC is wrong.**

Hierarchy comes from **size and weight**, not color. Color stays in a narrow ink palette.

Sizes (Android 390pt design width):
- Quote hero (screensaver): `44px / 1.8`
- Quote in card: `28px / 1.8`
- H1: `26px / 1.15` weight 600
- H2: `20px / 1.35` weight 500
- Body: `15px / 1.55`
- Small / caption: `13px`
- Label (small-caps Latin): `11px` letter-spacing 0.16em

### Colors

See `colors_and_type.css` for the full token list. Two key principles:

- **Surfaces stay soft.** No cool greys, no pure white. Tea Paper bg is `#eef0df` (cream with a green undertone, like rice paper held to light); Forest Night bg is `#0e1612` (deep moss-black). Pure white and pure black are banned — they kill the softness.
- **Accent is rare.** Matcha `#7ba05b` (Paper) and Mint `#9ec88a` (Night) appear on at most one element per screen — the primary action, or the seal. Bamboo `#b8a866` is the warm-counter to keep things from feeling cold.

### Backgrounds

The screensaver / widget background is **user-provided** — that's the whole point. The system supplies:
- A library of curated **calm photographs** (landscape, paper, fabric, sky — never people, never branded).
- Solid colors drawn from the palette (paper, ink, dusk).
- An **abstract paper-grain texture** (`assets/paper-grain.svg`) overlaid at 40% on solid surfaces to keep them from feeling flat.

Full-bleed photographs always carry a **protection gradient** (top + bottom, `linear-gradient(to bottom, rgba(0,0,0,0.5), transparent 30%, transparent 70%, rgba(0,0,0,0.5))`) so type stays legible regardless of image.

### Spacing

4-based scale: `4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80`. Cards default to `16px` internal padding; section padding is `24px`. Whitespace is generous — quotes need air.

### Radii

Modest. Paper has edges.
- Buttons: `8px`
- Cards: `14px`
- Big media tiles: `22px`
- Pills (chips, badges only): `999px`

We do **not** use heavily-rounded "squircle" radii. A quote card should look like it could be a slip of paper.

### Shadows

Warm-tinted, low-spread. Paper doesn't cast long shadows.
- `--shadow-1`: hairline, used on settings rows
- `--shadow-2`: card lift on hover/press
- `--shadow-3`: modal / sheet only
- `--shadow-inset`: thin inner border on cards — gives the paper edge

Night mode shadows are darker but stay short; emphasis comes from value contrast, not blur.

### Borders

- `--border-1`: `1px solid var(--paper-300)` — default divider on light, used on settings rows, cards.
- `--divider`: `rgba(28, 26, 23, 0.08)` — soft divider for in-card splits.
- Borders are present, not hidden. The whole system has a slight "ruled-notebook" precision.

### Hover / press states

**Hover** (desktop screensaver UI, web): `opacity: 0.7` on icon buttons; on filled buttons, darken background by ~6% (e.g. peach-500 → peach-700 mix).

**Press** (mobile): `transform: scale(0.97)` + 50ms ease — physical, like pressing a key. Background darkens to `--accent-pressed` for primary actions. **No ripple** (Android default ripple feels wrong here — too tech-y).

### Animation

- **Default duration**: 240ms. Page transitions: 480ms. Quote crossfade: 640ms.
- **Easing**: `cubic-bezier(0.4, 0, 0.2, 1)` — settled, no overshoot. We never bounce. Bouncing is for products that want to feel fun; this product wants to feel composed.
- The signature animation is the **quote crossfade** — one quote dissolves through the background to the next, like a slow page turn. ~640ms, with the new quote also drifting 8px upward as it appears.
- We don't use spinners. Loading states are either skeleton paper (a faint grain block) or simply absent (most state is local).

### Transparency / blur

- Modal scrim: `rgba(28, 26, 23, 0.55)` — never fully opaque.
- Sticky headers blur their background: `backdrop-filter: blur(20px) saturate(140%)` over a 75%-opaque surface.
- We do **not** use frosted-glass cards in the body — that's an Apple-design tic and feels wrong on a warm-paper product.

### Imagery direction

Photographs lean **warm, low-saturation, grain-y**. Think Japanese photo books, 35mm film, magic-hour light. Never crisp commercial stock photography. When we don't have a photo, we use a **solid paper color with grain overlay** rather than a gradient — gradients feel digital.

### Layout rules

- Mobile screens use a **safe inset of 20px** left/right. Quote display screens go full-bleed.
- Sticky top header is **56px** tall, blurred. Bottom nav (when present) is 64px tall + safe area.
- Content max-width on tablet/desktop: **640px** (single column, generously spaced) — we are not a dashboard.
- The quote display is always **vertically centered** with at least 80px breathing room top/bottom.

---

## Iconography

We use **Lucide** icons (ISC license) via CDN — `https://unpkg.com/lucide-static@latest/icons/<name>.svg`. Lucide's stroke style (1.5px, rounded caps) fits the literary mood better than filled or duotone systems. They never compete with the type.

A curated subset is documented in `assets/icons/MANIFEST.json` — about 28 icons cover the whole app. Common ones: `book-open`, `sparkles`, `shuffle`, `timer`, `pencil`, `bookmark`, `chevron-right`, `search`, `settings`, `sun`, `moon`, `image`, `upload`.

**Rules:**
- Stroke `1.5px`, color inherits from `currentColor` (almost always `--fg-2`).
- Default size: `20px` for inline, `24px` for tab bar.
- The accent color (`--accent`) is used on icons **only** when an icon is the primary action of a screen (e.g. the floating "add quote" button).
- **No emoji anywhere in product chrome.** A quote can quote an emoji if the user typed one, but the UI never does.
- **No unicode characters** as icons (no `★`, `♥`, etc.).

For the brand mark we render **the character 金** inside a gold-tinted seal (`assets/logo-seal.svg`). It functions as app icon, header lockup, and the smallest possible identifier — like a wax seal on a letter.

**Substitution flag.** We did not have time to ship self-hosted Lucide SVGs in this system; the manifest references CDN. For production: download the 28 icons listed and serve from `assets/icons/`.

### Fonts — substitution flag

We reference **Noto Serif SC**, **Noto Sans SC**, and **EB Garamond** from Google Fonts (`@import` in `colors_and_type.css`). These are open-licensed (SIL/OFL) and excellent fits, but **we did not ship the .woff2 files** with the project. For production:

1. Download from `https://fonts.google.com/noto/specimen/Noto+Serif+SC` (weights 300/400/500/600/700), `https://fonts.google.com/specimen/EB+Garamond` (regular + italic, 400/500), and `https://fonts.google.com/noto/specimen/Noto+Sans+SC` (400/500/700).
2. Self-host in `fonts/` and replace the Google Fonts `@import` with `@font-face` declarations.
3. Subset Noto Serif SC by frequency (the full Chinese Serif files are ~10MB each) — use the `glyphhanger`/`pyftsubset` tool against your actual quote corpus.

We are *flagging this* — if you have a brand-licensed display face you'd rather use for the quote hero (e.g. 思源宋体 / Source Han Serif Heavy), tell us and we'll swap it in.

---

## File index

```
小金库 Design System/
├── README.md                       ← this file
├── SKILL.md                        ← Claude Code agent-skill manifest
├── colors_and_type.css             ← all tokens (colors, type, spacing, radii, shadows)
│
├── assets/
│   ├── logo-wordmark.svg           ← horizontal lockup (Tea Paper)
│   ├── logo-wordmark-night.svg     ← horizontal lockup (Forest Night)
│   ├── logo-seal.svg               ← standalone "金" seal mark / app icon foundation
│   ├── paper-grain.svg             ← noise overlay for solid surfaces
│   └── icons/MANIFEST.json         ← Lucide icon subset reference
│
├── preview/                        ← Design System tab cards (700×variable px)
│   ├── card-type-display.html
│   ├── card-type-scale.html
│   ├── card-colors-paper.html
│   ├── card-colors-night.html
│   ├── card-colors-semantic.html
│   ├── card-spacing.html
│   ├── card-radii.html
│   ├── card-shadows.html
│   ├── card-buttons.html
│   ├── card-cards.html
│   ├── card-tags.html
│   ├── card-inputs.html
│   ├── card-logo.html
│   └── card-iconography.html
│
└── ui_kits/
    ├── android-app/                ← Mobile app prototype
    │   ├── index.html              ← interactive click-thru (home → editor → screensaver)
    │   ├── kit.css
    │   ├── app.jsx                 ← App shell + routing
    │   ├── screens.jsx             ← Library, Editor, Screensaver, Settings
    │   └── components.jsx          ← Button, Card, TopBar, BottomNav, Sheet, etc.
    │
    └── android-widgets/            ← Home-screen widget mockups
        ├── index.html              ← Three sizes on a tiled wallpaper
        └── widgets.jsx             ← Small / Medium / Large widget components
```

---

## Caveats (read me)

- **Brand was invented from scratch.** Direction is a real design opinion, not a copy of an existing app. If you've seen a competitor whose vibe you prefer (一言, 句读, Stoic, etc.) we should pivot to that reference before going further.
- **Fonts referenced via Google Fonts** — see flag above.
- **Icons referenced via Lucide CDN** — substitute the closest match list locally for production.
- **No real photography included** — UI kits use solid color blocks with grain overlays as photo placeholders. Drop in real images and the system was built to support them.
- **Logo is a typographic seal**, not a custom drawn mark. If you want a real illustrated mark, we should commission one.
