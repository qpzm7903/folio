// 小金库 · Folio — Screensaver layout variants
//
// Each layout is a different "page" of the wallpaper experience.
// All assume the SAFE ZONES on a phone home / lock screen:
//   • Top ~120px is taken by the system clock + status bar
//   • Bottom ~120px is taken by the dock / unlock indicator
//   • The MIDDLE BAND is where our type lives.

const LAYOUTS = [
  { key: "page",       label: "页", name: "Page" },
  { key: "vertical",   label: "竖", name: "Vertical" },
  { key: "pull",       label: "引", name: "Pull-quote" },
  { key: "lockscreen", label: "时", name: "Lock screen" },
  { key: "fullbleed",  label: "满", name: "Full bleed" },
  { key: "stamped",    label: "印", name: "Stamped" },
  { key: "ribbon",     label: "条", name: "Ribbon" },
  { key: "card",       label: "片", name: "Card on field" },
  { key: "interleave", label: "织", name: "Interleaved" },
];

// Roman numeral for a tiny "edition" mark
const toRoman = (n) => {
  const m = [["X",10],["IX",9],["V",5],["IV",4],["I",1]];
  let s = "", x = ((n - 1) % 30) + 1;
  for (const [c, v] of m) while (x >= v) { s += c; x -= v; }
  return s;
};

// ── Length tier ──────────────────────────────────────────────
// Chinese char count → a tier that drives a CSS --q-scale multiplier.
// Short quotes get big type; long quotes step down so they always fit.
const lengthTier = (text) => {
  const n = [...(text || "")].length;
  if (n <= 10) return "tiny";
  if (n <= 18) return "short";
  if (n <= 30) return "medium";
  if (n <= 46) return "long";
  return "xlong";
};

// Tiny decorative leaf — used in Lockscreen layout
const LeafSVG = ({ size = 100, opacity = 0.12 }) => (
  <svg viewBox="0 0 100 100" width={size} height={size}
       style={{ position: "absolute", opacity, pointerEvents: "none" }}>
    <path d="M50 5 Q 90 30 75 70 Q 50 95 25 70 Q 10 30 50 5 Z"
          fill="none" stroke="currentColor" strokeWidth="1"/>
    <path d="M50 5 Q 50 50 50 95" fill="none" stroke="currentColor" strokeWidth="0.6"/>
    <path d="M50 25 Q 65 30 70 45 M50 25 Q 35 30 30 45
             M50 50 Q 70 55 75 70 M50 50 Q 30 55 25 70
             M50 75 Q 60 80 62 90 M50 75 Q 40 80 38 90"
          fill="none" stroke="currentColor" strokeWidth="0.5"/>
  </svg>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 1: 页 Page — looks like a single page of a book
// ─────────────────────────────────────────────────────────────
const LayoutPage = ({ quote }) => (
  <div className="ds-layout ds-page" data-len={lengthTier(quote.q)}>
    <div className="ds-page-head">
      <span>no. <em>{toRoman(quote.id)}</em></span>
      <span className="rule" />
      <span className="cat">{quote.tag}</span>
    </div>
    <div className="ds-page-body">
      <div className="ds-page-quote">{quote.q}</div>
    </div>
    <div className="ds-page-foot">
      <span className="rule" />
      <span className="foot-meta">五月 · MMXXVI</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 2: 竖 Vertical — Chinese traditional vertical typesetting
// ─────────────────────────────────────────────────────────────
const LayoutVertical = ({ quote }) => (
  <div className="ds-layout ds-vertical" data-len={lengthTier(quote.q)}>
    <div className="ds-vert-rule" />
    <div className="ds-vert-quote">{quote.q}</div>
    <div className="ds-vert-meta">
      <span className="ds-vert-cat">{quote.tag}</span>
      <span className="ds-vert-seal">金</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 3: 引 Pull-quote — oversized 「 」 brackets
// ─────────────────────────────────────────────────────────────
const LayoutPull = ({ quote }) => {
  // Split into ~2 lines on a comma if available, for breath
  const parts = quote.q.includes("，") ? quote.q.split(/，/) : [quote.q];
  return (
    <div className="ds-layout ds-pull" data-len={lengthTier(quote.q)}>
      <div className="ds-pull-open">「</div>
      <div className="ds-pull-body">
        {parts.map((p, i) => (
          <div key={i} className="ds-pull-line">
            {p}{i < parts.length - 1 ? "，" : ""}
          </div>
        ))}
      </div>
      <div className="ds-pull-foot">
        <span className="ds-pull-attr"><em>{quote.tag}</em></span>
        <span className="ds-pull-close">」</span>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 4: 时 Lock screen — clock + date prominent, quote as caption
// ─────────────────────────────────────────────────────────────
const LayoutLockscreen = ({ quote }) => (
  <div className="ds-layout ds-lockscreen" data-len={lengthTier(quote.q)}>
    <div className="ds-lock-time">
      <div className="ds-lock-clock">9:41</div>
      <div className="ds-lock-date">五月二十四日 · 周六</div>
    </div>
    <div className="ds-lock-leaf"><LeafSVG size={220} opacity={0.10} /></div>
    <div className="ds-lock-caption">
      <div className="ds-lock-quote">{quote.q}</div>
      <div className="ds-lock-attr">— <em>{quote.tag}</em></div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 5: 满 Full bleed — the quote IS the wallpaper
// ─────────────────────────────────────────────────────────────
const LayoutFullbleed = ({ quote }) => (
  <div className="ds-layout ds-fullbleed" data-len={lengthTier(quote.q)}>
    <div className="ds-full-quote">{quote.q}</div>
    <div className="ds-full-attr">— <em>{quote.tag}</em></div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 6: 印 Stamped — first character is a giant matcha seal
// ─────────────────────────────────────────────────────────────
const LayoutStamped = ({ quote }) => {
  const firstChar = quote.q.charAt(0);
  const rest = quote.q.slice(1);
  return (
    <div className="ds-layout ds-stamped" data-len={lengthTier(quote.q)}>
      <div className="ds-stamped-head">
        <span className="ds-stamped-cat">{quote.tag}</span>
      </div>
      <div className="ds-stamped-row">
        <div className="ds-stamped-mark">{firstChar}</div>
        <div className="ds-stamped-body">{rest}</div>
      </div>
      <div className="ds-stamped-foot">五月 · MMXXVI</div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 7: 条 Ribbon — Quote crosses a horizontal cream ribbon
// ─────────────────────────────────────────────────────────────
const LayoutRibbon = ({ quote }) => (
  <div className="ds-layout ds-ribbon" data-len={lengthTier(quote.q)}>
    <div className="ds-ribbon-band">
      <div className="ds-ribbon-cat">— {quote.tag} —</div>
      <div className="ds-ribbon-quote">{quote.q}</div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 8: 片 Card on field — small card floating on textured field
// ─────────────────────────────────────────────────────────────
const LayoutCard = ({ quote }) => (
  <div className="ds-layout ds-card" data-len={lengthTier(quote.q)}>
    <div className="ds-card-field" />
    <div className="ds-card-paper">
      <div className="ds-card-corner ds-card-corner-tl" />
      <div className="ds-card-corner ds-card-corner-tr" />
      <div className="ds-card-corner ds-card-corner-bl" />
      <div className="ds-card-corner ds-card-corner-br" />
      <div className="ds-card-cat">{quote.tag}</div>
      <div className="ds-card-quote">{quote.q}</div>
      <div className="ds-card-rule" />
      <div className="ds-card-foot">小金库 · <em>Folio</em></div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 9: 织 Interleaved — quote interleaved with romanized echo
// ─────────────────────────────────────────────────────────────
const LayoutInterleave = ({ quote }) => {
  // Split quote at the comma if available
  const parts = quote.q.includes("，") ? quote.q.split(/，/) : [quote.q];
  return (
    <div className="ds-layout ds-interleave" data-len={lengthTier(quote.q)}>
      <div className="ds-inter-num">{String(quote.id).padStart(2, "0")}</div>
      <div className="ds-inter-body">
        {parts.map((p, i) => (
          <React.Fragment key={i}>
            <div className="ds-inter-line">{p}{i < parts.length - 1 ? "，" : ""}</div>
            {i < parts.length - 1 && <div className="ds-inter-rule" />}
          </React.Fragment>
        ))}
      </div>
      <div className="ds-inter-foot">
        <span className="ds-inter-cat">{quote.tag}</span>
      </div>
    </div>
  );
};

const LAYOUT_COMPONENTS = {
  page:       LayoutPage,
  vertical:   LayoutVertical,
  pull:       LayoutPull,
  lockscreen: LayoutLockscreen,
  fullbleed:  LayoutFullbleed,
  stamped:    LayoutStamped,
  ribbon:     LayoutRibbon,
  card:       LayoutCard,
  interleave: LayoutInterleave,
};

Object.assign(window, {
  LAYOUTS, LAYOUT_COMPONENTS, toRoman, LeafSVG, lengthTier,
});
