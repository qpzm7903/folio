// 小金库 · Folio — 首页 (Home) layout variants
//
// Each layout is a different "page" of the home / wallpaper experience.
// They share .ds-layout (base) + a per-layout class defined in kit.css.
// The MIDDLE BAND is where our type lives.

const LAYOUTS = [
  { key: "page",       label: "页", name: "Page" },
  { key: "vertical",   label: "竖", name: "Vertical" },
  { key: "pull",       label: "引", name: "Pull" },
  { key: "lockscreen", label: "时", name: "Lock" },
  { key: "fullbleed",  label: "满", name: "Fullbleed" },
  { key: "stamped",    label: "印", name: "Stamped" },
  { key: "ribbon",     label: "条", name: "Ribbon" },
  { key: "card",       label: "片", name: "Card" },
  { key: "interleave", label: "织", name: "Interleaved" },
];

// ─────── Helpers ───────
// Length tier drives --q-scale in CSS so long quotes step down to fit.
const lengthTier = (q) => {
  const n = (q || "").length;
  if (n <= 10) return "tiny";
  if (n <= 16) return "short";
  if (n <= 26) return "medium";
  if (n <= 40) return "long";
  return "xlong";
};

const toRoman = (num) => {
  const map = [[10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]];
  let n = num, out = "";
  for (const [v, s] of map) while (n >= v) { out += s; n -= v; }
  return out || "I";
};

const LeafSVG = ({ size = 40 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round">
    <path d="M11 20A7 7 0 0 1 4 13C4 7 9 3 20 3c0 9-4 14-9 14a7 7 0 0 1-7-7Z" />
    <path d="M2 22c4-5 7-8 12-10" />
  </svg>
);

// Split a Chinese quote into clauses at punctuation (keeps the mark).
const clauses = (q) => {
  const segs = [];
  let buf = "";
  for (const ch of (q || "")) {
    buf += ch;
    if ("，。！？；、".includes(ch)) { segs.push(buf); buf = ""; }
  }
  if (buf) segs.push(buf);
  return segs.length ? segs : [q];
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 1: 页 Page
// ─────────────────────────────────────────────────────────────
const LayoutPage = ({ quote }) => (
  <div className="ds-layout ds-page" data-len={lengthTier(quote.q)}>
    <div className="ds-page-head">
      <span className="cat">{(quote.tags && quote.tags[0]) || quote.tag}</span>
      <span className="rule" />
      <em>金句</em>
    </div>
    <div className="ds-page-body">
      <div className="ds-page-quote">{quote.q}</div>
    </div>
    <div className="ds-page-foot">
      <span className="rule" />
      <span className="foot-meta">{quote.date}</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 2: 竖 Vertical
// ─────────────────────────────────────────────────────────────
const LayoutVertical = ({ quote }) => (
  <div className="ds-layout ds-vertical" data-len={lengthTier(quote.q)}>
    <div className="ds-vert-quote">{quote.q}</div>
    <div className="ds-vert-rule" />
    <div className="ds-vert-meta">
      <span className="ds-vert-cat">{(quote.tags && quote.tags[0]) || quote.tag}</span>
      <span className="ds-vert-seal">金</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 3: 引 Pull-quote
// ─────────────────────────────────────────────────────────────
const LayoutPull = ({ quote }) => (
  <div className="ds-layout ds-pull" data-len={lengthTier(quote.q)}>
    <div className="ds-pull-open">“</div>
    <div className="ds-pull-body">
      <div className="ds-pull-line">{quote.q}</div>
    </div>
    <div className="ds-pull-foot">
      <span className="ds-pull-attr">{(quote.tags && quote.tags[0]) || quote.tag}</span>
      <span className="ds-pull-close">”</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 4: 时 Lock screen
// ─────────────────────────────────────────────────────────────
const LayoutLockscreen = ({ quote }) => (
  <div className="ds-layout ds-lockscreen" data-len={lengthTier(quote.q)}>
    <div className="ds-lock-time">
      <div className="ds-lock-clock">9:41</div>
      <div className="ds-lock-date">{quote.date} · 周五</div>
    </div>
    <div className="ds-lock-leaf"><LeafSVG size={120} /></div>
    <div className="ds-lock-caption">
      <div className="ds-lock-quote">{quote.q}</div>
      <div className="ds-lock-attr">— {(quote.tags && quote.tags[0]) || quote.tag}</div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 5: 满 Full bleed
// ─────────────────────────────────────────────────────────────
const LayoutFullbleed = ({ quote }) => (
  <div className="ds-layout ds-fullbleed" data-len={lengthTier(quote.q)}>
    <div className="ds-full-quote">{quote.q}</div>
    <div className="ds-full-attr">— {(quote.tags && quote.tags[0]) || quote.tag}</div>
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
        <span className="ds-stamped-cat">{(quote.tags && quote.tags[0]) || quote.tag}</span>
      </div>
      <div className="ds-stamped-row">
        <div className="ds-stamped-mark">{firstChar}</div>
        <div className="ds-stamped-body">{rest}</div>
      </div>
      <div className="ds-stamped-foot">{quote.date}</div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 7: 条 Ribbon
// ─────────────────────────────────────────────────────────────
const LayoutRibbon = ({ quote }) => (
  <div className="ds-layout ds-ribbon" data-len={lengthTier(quote.q)}>
    <div className="ds-ribbon-band">
      <div className="ds-ribbon-cat">{(quote.tags && quote.tags[0]) || quote.tag}</div>
      <div className="ds-ribbon-quote">{quote.q}</div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 8: 片 Card on field
// ─────────────────────────────────────────────────────────────
const LayoutCard = ({ quote }) => (
  <div className="ds-layout ds-card" data-len={lengthTier(quote.q)}>
    <div className="ds-card-field" />
    <div className="ds-card-paper">
      <span className="ds-card-corner ds-card-corner-tl" />
      <span className="ds-card-corner ds-card-corner-tr" />
      <span className="ds-card-corner ds-card-corner-bl" />
      <span className="ds-card-corner ds-card-corner-br" />
      <div className="ds-card-cat">{(quote.tags && quote.tags[0]) || quote.tag}</div>
      <div className="ds-card-quote">{quote.q}</div>
      <div className="ds-card-rule" />
      <div className="ds-card-foot">小金库 · <em>Folio</em></div>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// LAYOUT 9: 织 Interleaved — index number + clauses on hairlines
// ─────────────────────────────────────────────────────────────
const LayoutInterleave = ({ quote }) => {
  const parts = clauses(quote.q);
  return (
    <div className="ds-layout ds-interleave" data-len={lengthTier(quote.q)}>
      <div className="ds-inter-num">{toRoman(quote.id)}</div>
      <div className="ds-inter-body">
        {parts.map((p, i) => (
          <React.Fragment key={i}>
            {i > 0 && <div className="ds-inter-rule" />}
            <div className="ds-inter-line">{p}</div>
          </React.Fragment>
        ))}
      </div>
      <div className="ds-inter-foot">
        <span className="ds-inter-cat">{(quote.tags && quote.tags[0]) || quote.tag}</span>
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
