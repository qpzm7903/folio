---
name: xiao-jinku-design
description: Use this skill to generate well-branded interfaces and assets for 小金库 · Folio — a Chinese-language Android app that displays the user's collected quotes (金句) on screensavers and widgets. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping. Two themes: Paper Realm (warm cream / day) and Night Reading (warm dark).
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.

The brand has two parallel themes that share spacing, type, and component vocabulary:
- **A. 青纸 Tea Paper** — default light, tea-cream paper, moss-ink serif, matcha accent
- **B. 林夜 Forest Night** — `[data-theme="night"]`, deep moss-black bg, cream-green type, mint accent

When working:
- Voice is quiet, literary, second-person 你. Never SaaS-y. No emoji in chrome.
- Type is almost mono-typographic Noto Serif SC; Noto Sans SC only for tiny UI labels.
- Accent color appears at most once per screen.
- Animation is settled — no bounces; signature motion is the 640ms quote crossfade.
- Backgrounds lean warm with paper-grain texture; pure white and pure black are banned.

If creating visual artifacts (slides, mocks, throwaway prototypes), copy assets out of this skill folder and create static HTML files for the user to view. Reference `colors_and_type.css` for tokens and the `ui_kits/` for component patterns.

If working on production code, copy assets and read the rules in README.md to become an expert in designing with this brand. Flag the font and icon substitutions noted in README.md before shipping.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask a few focused questions (which surface? which theme? Chinese-only or bilingual?), and act as an expert designer who outputs HTML artifacts or production code depending on the need.
