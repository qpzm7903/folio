/* @ds-bundle: {"format":3,"namespace":"DesignSystem_e8d12a","components":[],"sourceHashes":{"ui_kits/android-app/app.jsx":"073ec1973e51","ui_kits/android-app/components.jsx":"a6ceb28f82da","ui_kits/android-app/display-layouts.jsx":"c035adad0a19","ui_kits/android-app/screens.jsx":"4444ca579bad","ui_kits/android-app/widget-editor.jsx":"c9cf97fed550","ui_kits/android-widgets/widgets.jsx":"cbb55b3d29f9"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.DesignSystem_e8d12a = window.DesignSystem_e8d12a || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// ui_kits/android-app/app.jsx
try { (() => {
// 小金库 — Top-level app shell

const App = () => /*#__PURE__*/React.createElement("div", {
  style: {
    minHeight: "100vh",
    padding: "60px 40px 80px",
    display: "flex",
    gap: 56,
    justifyContent: "center",
    alignItems: "flex-start",
    flexWrap: "wrap",
    background: "var(--paper-100)",
    backgroundImage: "url(../../assets/paper-grain.svg)",
    backgroundSize: "240px 240px"
  }
}, /*#__PURE__*/React.createElement(PhoneApp, {
  initialTheme: "paper",
  initialScreen: "display",
  label: "\u9752\u7EB8 \xB7 \u9996\u9875\uFF08\u9996\u9875 / \u91D1\u5E93 / \u6211\u7684\uFF09"
}), /*#__PURE__*/React.createElement(PhoneApp, {
  initialTheme: "dai",
  initialScreen: "library",
  label: "\u9752\u9EDB \xB7 Ink Indigo"
}));
const PhoneApp = ({
  initialTheme = "paper",
  initialScreen = "library",
  label
}) => {
  const [theme, setTheme] = React.useState(initialTheme);
  const [screen, setScreen] = React.useState(initialScreen);
  const [sheetOpen, setSheetOpen] = React.useState(false);
  const [quotes, setQuotes] = React.useState(SEED_QUOTES);
  const [tags, setTags] = React.useState(TAGS);
  const onSave = (q, src) => {
    const tag = src || "未分类";
    setQuotes(qs => [{
      id: Date.now(),
      q,
      tag,
      src: "—",
      date: "刚刚"
    }, ...qs]);
    setTags(ts => ts.includes(tag) ? ts : [...ts, tag]);
  };
  const onImport = lines => {
    setQuotes(qs => [...lines.map((l, i) => ({
      id: Date.now() + i,
      q: l,
      tag: "导入",
      src: "—",
      date: "刚刚"
    })), ...qs]);
    setTags(ts => ts.includes("导入") ? ts : [...ts, "导入"]);
  };
  // Batch remove quotes by id
  const onDeleteQuotes = ids => {
    const kill = new Set(ids);
    setQuotes(qs => qs.filter(q => !kill.has(q.id)));
  };
  // Remove a tag: its quotes fall back to 未分类
  const onDeleteTag = t => {
    setQuotes(qs => qs.map(q => q.tag === t ? {
      ...q,
      tag: "未分类"
    } : q));
    setTags(ts => ts.filter(x => x !== t));
  };
  return /*#__PURE__*/React.createElement(Phone, {
    theme: theme,
    label: label
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      display: "flex",
      flexDirection: "column",
      flex: 1,
      overflow: "hidden"
    }
  }, screen === "library" && /*#__PURE__*/React.createElement(LibraryScreen, {
    go: setScreen,
    openSheet: () => setSheetOpen(true),
    quotes: quotes,
    tags: tags,
    onDeleteQuotes: onDeleteQuotes,
    onDeleteTag: onDeleteTag
  }), screen === "editor" && /*#__PURE__*/React.createElement(EditorScreen, {
    go: setScreen,
    onSave: onSave,
    openSheet: () => setSheetOpen(true)
  }), screen === "display" && /*#__PURE__*/React.createElement(DisplayScreen, {
    go: setScreen,
    quotes: quotes
  }), screen === "widget" && /*#__PURE__*/React.createElement(WidgetEditorScreen, {
    go: setScreen,
    theme: theme,
    onTheme: setTheme,
    quotes: quotes
  }), screen === "settings" && /*#__PURE__*/React.createElement(SettingsScreen, {
    go: setScreen,
    theme: theme,
    onTheme: setTheme
  }), /*#__PURE__*/React.createElement(ImportSheet, {
    open: sheetOpen,
    onClose: () => setSheetOpen(false),
    onImport: onImport
  })));
};
ReactDOM.createRoot(document.getElementById("root")).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-app/app.jsx", error: String((e && e.message) || e) }); }

// ui_kits/android-app/components.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
// 小金库 — Android app UI Kit, shared primitives
// Exports to window for cross-script sharing.

const ICON_BASE = "https://unpkg.com/lucide-static@latest/icons/";
const Icon = ({
  name,
  size = 20,
  style = {},
  ...rest
}) => /*#__PURE__*/React.createElement("img", _extends({
  src: `${ICON_BASE}${name}.svg`,
  width: size,
  height: size,
  alt: "",
  style: style
}, rest));

// ─────────────────────────────────────────────────────────────
// Themes — 2 fresh-green + 4 classical (传统色). Order =晨→昏.
// `dark:true` themes get the structural dark-mode styling in kit.css.
// ─────────────────────────────────────────────────────────────
const THEMES = [{
  key: "paper",
  name: "青纸",
  en: "Tea Paper",
  dark: false
}, {
  key: "celadon",
  name: "天青",
  en: "Celadon",
  dark: false
}, {
  key: "moonwhite",
  name: "月白",
  en: "Moon White",
  dark: false
}, {
  key: "cinnabar",
  name: "绛霞",
  en: "Cinnabar",
  dark: false
}, {
  key: "night",
  name: "林夜",
  en: "Forest Night",
  dark: true
}, {
  key: "dai",
  name: "青黛",
  en: "Ink Indigo",
  dark: true
}];
const themeByKey = k => THEMES.find(t => t.key === k) || THEMES[0];
const nextTheme = k => THEMES[(THEMES.findIndex(t => t.key === k) + 1) % THEMES.length].key;

// ─────────────────────────────────────────────────────────────
// Phone shell — bezel + status bar + content + gesture nav
// ─────────────────────────────────────────────────────────────
const Phone = ({
  theme = "paper",
  children,
  label
}) => {
  return /*#__PURE__*/React.createElement("div", {
    className: "phone-wrap",
    style: {
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 14
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "phone"
  }, /*#__PURE__*/React.createElement("div", {
    className: "phone-notch"
  }), /*#__PURE__*/React.createElement("div", {
    className: "phone-screen",
    "data-theme": theme === "paper" ? undefined : theme
  }, /*#__PURE__*/React.createElement(StatusBar, null), children, /*#__PURE__*/React.createElement(GestureBar, null))), label && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--serif-italic)",
      fontStyle: "italic",
      fontSize: 13,
      color: "var(--fg-3)"
    }
  }, label));
};
const StatusBar = () => /*#__PURE__*/React.createElement("div", {
  className: "status-bar"
}, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("div", {
  className: "sb-icons"
}, /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 16 16",
  fill: "currentColor"
}, /*#__PURE__*/React.createElement("path", {
  d: "M8 13.3L.67 5.97a10.37 10.37 0 0114.66 0L8 13.3z"
})), /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 16 16",
  fill: "currentColor"
}, /*#__PURE__*/React.createElement("path", {
  d: "M14.67 14.67V1.33L1.33 14.67h13.34z"
})), /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 18 16",
  fill: "currentColor"
}, /*#__PURE__*/React.createElement("rect", {
  x: "1",
  y: "4",
  width: "13",
  height: "8",
  rx: "1.5",
  fillOpacity: "0.3"
}), /*#__PURE__*/React.createElement("rect", {
  x: "2",
  y: "5",
  width: "9",
  height: "6",
  rx: "0.5"
}), /*#__PURE__*/React.createElement("rect", {
  x: "15",
  y: "6",
  width: "1.5",
  height: "4",
  rx: "0.5"
}))));
const GestureBar = () => /*#__PURE__*/React.createElement("div", {
  className: "gesture-bar"
});

// ─────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────
const TopBar = ({
  title,
  subtitle,
  actions = [],
  leading = null
}) => /*#__PURE__*/React.createElement("div", {
  className: "topbar"
}, /*#__PURE__*/React.createElement("div", {
  className: "title-wrap"
}, leading, /*#__PURE__*/React.createElement("span", {
  className: "title"
}, title), subtitle && /*#__PURE__*/React.createElement("span", {
  className: "sub"
}, subtitle)), /*#__PURE__*/React.createElement("div", {
  className: "actions"
}, actions.map((a, i) => /*#__PURE__*/React.createElement("button", {
  key: i,
  className: "icon-btn",
  onClick: a.onClick,
  "aria-label": a.label
}, /*#__PURE__*/React.createElement(Icon, {
  name: a.icon
})))));

// ─────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────
const BottomNav = ({
  current,
  onChange
}) => {
  const items = [{
    key: "display",
    icon: "home",
    label: "首页"
  }, {
    key: "library",
    icon: "book-open",
    label: "金库"
  }, {
    key: "settings",
    icon: "user-round",
    label: "我的"
  }];
  return /*#__PURE__*/React.createElement("div", {
    className: "bottom-nav"
  }, items.map(it => /*#__PURE__*/React.createElement("button", {
    key: it.key,
    className: "nav-item" + (current === it.key ? " active" : ""),
    onClick: () => onChange(it.key)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: it.icon,
    size: 22
  }), /*#__PURE__*/React.createElement("span", null, it.label))));
};

// ─────────────────────────────────────────────────────────────
// Quote card  (supports multi-select mode)
// ─────────────────────────────────────────────────────────────
const QuoteCard = ({
  quote,
  source,
  date,
  variant = "default",
  onClick,
  selectable = false,
  selected = false,
  onToggle
}) => /*#__PURE__*/React.createElement("div", {
  className: "quote-card" + (variant === "dark" ? " dark" : "") + (selectable ? " selectable" : "") + (selected ? " selected" : ""),
  onClick: selectable ? onToggle : onClick
}, selectable && /*#__PURE__*/React.createElement("span", {
  className: "qcheck" + (selected ? " on" : "")
}, selected && /*#__PURE__*/React.createElement(Icon, {
  name: "check",
  size: 13
})), /*#__PURE__*/React.createElement("div", {
  className: "qbody"
}, /*#__PURE__*/React.createElement("div", {
  className: "q"
}, quote), /*#__PURE__*/React.createElement("div", {
  className: "qmeta"
}, /*#__PURE__*/React.createElement("span", null, source && /*#__PURE__*/React.createElement("em", null, source)), /*#__PURE__*/React.createElement("span", null, date))));

// ─────────────────────────────────────────────────────────────
// Setting row
// ─────────────────────────────────────────────────────────────
const SettingRow = ({
  label,
  sub,
  value,
  toggle,
  onToggle,
  chev = true,
  onClick
}) => /*#__PURE__*/React.createElement("div", {
  className: "setting-row",
  onClick: onClick
}, /*#__PURE__*/React.createElement("div", {
  className: "lead"
}, /*#__PURE__*/React.createElement("div", {
  className: "lbl"
}, label), sub && /*#__PURE__*/React.createElement("div", {
  className: "sub"
}, sub)), value && /*#__PURE__*/React.createElement("span", {
  className: "val"
}, value), toggle !== undefined && /*#__PURE__*/React.createElement("div", {
  className: "toggle" + (toggle ? " on" : ""),
  onClick: e => {
    e.stopPropagation();
    onToggle && onToggle(!toggle);
  }
}, /*#__PURE__*/React.createElement("div", {
  className: "dot"
})), chev && toggle === undefined && /*#__PURE__*/React.createElement(Icon, {
  name: "chevron-right",
  size: 14,
  style: {
    opacity: 0.4
  },
  className: "chev"
}));
const SettingsGroup = ({
  children
}) => /*#__PURE__*/React.createElement("div", {
  className: "settings-group"
}, children);

// ─────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────
const SectionH = ({
  children,
  count
}) => /*#__PURE__*/React.createElement("div", {
  className: "section-h"
}, /*#__PURE__*/React.createElement("span", null, children), count !== undefined && /*#__PURE__*/React.createElement("span", {
  className: "ct"
}, count, " \u53E5"));

// ─────────────────────────────────────────────────────────────
// Floating action button
// ─────────────────────────────────────────────────────────────
const Fab = ({
  icon = "plus",
  onClick
}) => /*#__PURE__*/React.createElement("button", {
  className: "fab",
  onClick: onClick,
  "aria-label": "add"
}, /*#__PURE__*/React.createElement(Icon, {
  name: icon,
  size: 22
}));
Object.assign(window, {
  Icon,
  Phone,
  StatusBar,
  GestureBar,
  TopBar,
  BottomNav,
  QuoteCard,
  SettingRow,
  SettingsGroup,
  SectionH,
  Fab,
  THEMES,
  themeByKey,
  nextTheme
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-app/components.jsx", error: String((e && e.message) || e) }); }

// ui_kits/android-app/display-layouts.jsx
try { (() => {
// 小金库 · Folio — 首页 (Home) layout variants
//
// Each layout is a different "page" of the home / wallpaper experience.
// They share .ds-layout (base) + a per-layout class defined in kit.css.
// The MIDDLE BAND is where our type lives.

const LAYOUTS = [{
  key: "page",
  label: "页",
  name: "Page"
}, {
  key: "vertical",
  label: "竖",
  name: "Vertical"
}, {
  key: "pull",
  label: "引",
  name: "Pull"
}, {
  key: "lockscreen",
  label: "时",
  name: "Lock"
}, {
  key: "fullbleed",
  label: "满",
  name: "Fullbleed"
}, {
  key: "stamped",
  label: "印",
  name: "Stamped"
}, {
  key: "ribbon",
  label: "条",
  name: "Ribbon"
}, {
  key: "card",
  label: "片",
  name: "Card"
}, {
  key: "interleave",
  label: "织",
  name: "Interleaved"
}];

// ─────── Helpers ───────
// Length tier drives --q-scale in CSS so long quotes step down to fit.
const lengthTier = q => {
  const n = (q || "").length;
  if (n <= 10) return "tiny";
  if (n <= 16) return "short";
  if (n <= 26) return "medium";
  if (n <= 40) return "long";
  return "xlong";
};
const toRoman = num => {
  const map = [[10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]];
  let n = num,
    out = "";
  for (const [v, s] of map) while (n >= v) {
    out += s;
    n -= v;
  }
  return out || "I";
};
const LeafSVG = ({
  size = 40
}) => /*#__PURE__*/React.createElement("svg", {
  width: size,
  height: size,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: "1.3",
  strokeLinecap: "round",
  strokeLinejoin: "round"
}, /*#__PURE__*/React.createElement("path", {
  d: "M11 20A7 7 0 0 1 4 13C4 7 9 3 20 3c0 9-4 14-9 14a7 7 0 0 1-7-7Z"
}), /*#__PURE__*/React.createElement("path", {
  d: "M2 22c4-5 7-8 12-10"
}));

// Split a Chinese quote into clauses at punctuation (keeps the mark).
const clauses = q => {
  const segs = [];
  let buf = "";
  for (const ch of q || "") {
    buf += ch;
    if ("，。！？；、".includes(ch)) {
      segs.push(buf);
      buf = "";
    }
  }
  if (buf) segs.push(buf);
  return segs.length ? segs : [q];
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 1: 页 Page
// ─────────────────────────────────────────────────────────────
const LayoutPage = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-page",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-page-head"
}, /*#__PURE__*/React.createElement("span", {
  className: "cat"
}, quote.tag), /*#__PURE__*/React.createElement("span", {
  className: "rule"
}), /*#__PURE__*/React.createElement("em", null, "\u91D1\u53E5")), /*#__PURE__*/React.createElement("div", {
  className: "ds-page-body"
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-page-quote"
}, quote.q)), /*#__PURE__*/React.createElement("div", {
  className: "ds-page-foot"
}, /*#__PURE__*/React.createElement("span", {
  className: "rule"
}), /*#__PURE__*/React.createElement("span", {
  className: "foot-meta"
}, quote.date)));

// ─────────────────────────────────────────────────────────────
// LAYOUT 2: 竖 Vertical
// ─────────────────────────────────────────────────────────────
const LayoutVertical = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-vertical",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-vert-quote"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "ds-vert-rule"
}), /*#__PURE__*/React.createElement("div", {
  className: "ds-vert-meta"
}, /*#__PURE__*/React.createElement("span", {
  className: "ds-vert-cat"
}, quote.tag), /*#__PURE__*/React.createElement("span", {
  className: "ds-vert-seal"
}, "\u91D1")));

// ─────────────────────────────────────────────────────────────
// LAYOUT 3: 引 Pull-quote
// ─────────────────────────────────────────────────────────────
const LayoutPull = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-pull",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-pull-open"
}, "\u201C"), /*#__PURE__*/React.createElement("div", {
  className: "ds-pull-body"
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-pull-line"
}, quote.q)), /*#__PURE__*/React.createElement("div", {
  className: "ds-pull-foot"
}, /*#__PURE__*/React.createElement("span", {
  className: "ds-pull-attr"
}, quote.tag), /*#__PURE__*/React.createElement("span", {
  className: "ds-pull-close"
}, "\u201D")));

// ─────────────────────────────────────────────────────────────
// LAYOUT 4: 时 Lock screen
// ─────────────────────────────────────────────────────────────
const LayoutLockscreen = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-lockscreen",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-time"
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-clock"
}, "9:41"), /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-date"
}, quote.date, " \xB7 \u5468\u4E94")), /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-leaf"
}, /*#__PURE__*/React.createElement(LeafSVG, {
  size: 120
})), /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-caption"
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-quote"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "ds-lock-attr"
}, "\u2014 ", quote.tag)));

// ─────────────────────────────────────────────────────────────
// LAYOUT 5: 满 Full bleed
// ─────────────────────────────────────────────────────────────
const LayoutFullbleed = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-fullbleed",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-full-quote"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "ds-full-attr"
}, "\u2014 ", quote.tag));

// ─────────────────────────────────────────────────────────────
// LAYOUT 6: 印 Stamped — first character is a giant matcha seal
// ─────────────────────────────────────────────────────────────
const LayoutStamped = ({
  quote
}) => {
  const firstChar = quote.q.charAt(0);
  const rest = quote.q.slice(1);
  return /*#__PURE__*/React.createElement("div", {
    className: "ds-layout ds-stamped",
    "data-len": lengthTier(quote.q)
  }, /*#__PURE__*/React.createElement("div", {
    className: "ds-stamped-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "ds-stamped-cat"
  }, quote.tag)), /*#__PURE__*/React.createElement("div", {
    className: "ds-stamped-row"
  }, /*#__PURE__*/React.createElement("div", {
    className: "ds-stamped-mark"
  }, firstChar), /*#__PURE__*/React.createElement("div", {
    className: "ds-stamped-body"
  }, rest)), /*#__PURE__*/React.createElement("div", {
    className: "ds-stamped-foot"
  }, quote.date));
};

// ─────────────────────────────────────────────────────────────
// LAYOUT 7: 条 Ribbon
// ─────────────────────────────────────────────────────────────
const LayoutRibbon = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-ribbon",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-ribbon-band"
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-ribbon-cat"
}, quote.tag), /*#__PURE__*/React.createElement("div", {
  className: "ds-ribbon-quote"
}, quote.q)));

// ─────────────────────────────────────────────────────────────
// LAYOUT 8: 片 Card on field
// ─────────────────────────────────────────────────────────────
const LayoutCard = ({
  quote
}) => /*#__PURE__*/React.createElement("div", {
  className: "ds-layout ds-card",
  "data-len": lengthTier(quote.q)
}, /*#__PURE__*/React.createElement("div", {
  className: "ds-card-field"
}), /*#__PURE__*/React.createElement("div", {
  className: "ds-card-paper"
}, /*#__PURE__*/React.createElement("span", {
  className: "ds-card-corner ds-card-corner-tl"
}), /*#__PURE__*/React.createElement("span", {
  className: "ds-card-corner ds-card-corner-tr"
}), /*#__PURE__*/React.createElement("span", {
  className: "ds-card-corner ds-card-corner-bl"
}), /*#__PURE__*/React.createElement("span", {
  className: "ds-card-corner ds-card-corner-br"
}), /*#__PURE__*/React.createElement("div", {
  className: "ds-card-cat"
}, quote.tag), /*#__PURE__*/React.createElement("div", {
  className: "ds-card-quote"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "ds-card-rule"
}), /*#__PURE__*/React.createElement("div", {
  className: "ds-card-foot"
}, "\u5C0F\u91D1\u5E93 \xB7 ", /*#__PURE__*/React.createElement("em", null, "Folio"))));

// ─────────────────────────────────────────────────────────────
// LAYOUT 9: 织 Interleaved — index number + clauses on hairlines
// ─────────────────────────────────────────────────────────────
const LayoutInterleave = ({
  quote
}) => {
  const parts = clauses(quote.q);
  return /*#__PURE__*/React.createElement("div", {
    className: "ds-layout ds-interleave",
    "data-len": lengthTier(quote.q)
  }, /*#__PURE__*/React.createElement("div", {
    className: "ds-inter-num"
  }, toRoman(quote.id)), /*#__PURE__*/React.createElement("div", {
    className: "ds-inter-body"
  }, parts.map((p, i) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "ds-inter-rule"
  }), /*#__PURE__*/React.createElement("div", {
    className: "ds-inter-line"
  }, p)))), /*#__PURE__*/React.createElement("div", {
    className: "ds-inter-foot"
  }, /*#__PURE__*/React.createElement("span", {
    className: "ds-inter-cat"
  }, quote.tag)));
};
const LAYOUT_COMPONENTS = {
  page: LayoutPage,
  vertical: LayoutVertical,
  pull: LayoutPull,
  lockscreen: LayoutLockscreen,
  fullbleed: LayoutFullbleed,
  stamped: LayoutStamped,
  ribbon: LayoutRibbon,
  card: LayoutCard,
  interleave: LayoutInterleave
};
Object.assign(window, {
  LAYOUTS,
  LAYOUT_COMPONENTS,
  toRoman,
  LeafSVG,
  lengthTier
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-app/display-layouts.jsx", error: String((e && e.message) || e) }); }

// ui_kits/android-app/screens.jsx
try { (() => {
// 小金库 — Screens (Home/Library/Editor/Settings/Widget editor/Import sheet)

// ─────────────────────────────────────────────────────────────
// REAL CORPUS — provided by user
// ─────────────────────────────────────────────────────────────
const SEED_QUOTES = [{
  id: 1,
  q: "你在心里种下的种子，时间会帮它找出口。",
  src: "—",
  tag: "坚持与回响",
  date: "5月 20日"
}, {
  id: 2,
  q: "所有的执着，最终都会以你意想不到的方式，轻轻拥抱你。",
  src: "—",
  tag: "坚持与回响",
  date: "5月 19日"
}, {
  id: 3,
  q: "真正的强大不是没有裂痕，而是光从裂痕里照进来。",
  src: "—",
  tag: "完整而非完美",
  date: "5月 18日"
}, {
  id: 4,
  q: "你不必完美，你只需要真实且完整地活着。",
  src: "—",
  tag: "完整而非完美",
  date: "5月 17日"
}, {
  id: 5,
  q: "允许自己有时候走得慢，有时候想回头，这才是完整的人。",
  src: "—",
  tag: "完整而非完美",
  date: "5月 16日"
}, {
  id: 6,
  q: "走得慢的人，只要不丢失目标，也比漫无目的奔跑的人更早到达。",
  src: "—",
  tag: "旅程与抵达",
  date: "5月 12日"
}, {
  id: 7,
  q: "不必急着去对岸，此刻的波浪也是风景。",
  src: "—",
  tag: "旅程与抵达",
  date: "5月 10日"
}, {
  id: 8,
  q: "人生不是冲刺，是一场深呼吸就能继续的远行。",
  src: "—",
  tag: "旅程与抵达",
  date: "5月 8日"
}, {
  id: 9,
  q: "你不需要成为别人，你只需要成为自己，一个不断在完整中的自己。",
  src: "—",
  tag: "自我接纳",
  date: "5月 5日"
}, {
  id: 10,
  q: "接纳自己的阴影，才能拥抱真正的光明。",
  src: "—",
  tag: "自我接纳",
  date: "5月 3日"
}];
const TAGS = ["全部", "坚持与回响", "完整而非完美", "旅程与抵达", "自我接纳"];

// ─────────────────────────────────────────────────────────────
// Fisher-Yates shuffle (returns NEW array)
// ─────────────────────────────────────────────────────────────
const shuffleArr = arr => {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
};

// "No-repeat shuffle" hook: every round visits every item exactly once,
// then re-shuffles. Returns { current, next, round, posInRound, totalInRound }.
const useNoRepeatShuffle = items => {
  const [round, setRound] = React.useState(1);
  const [order, setOrder] = React.useState(() => shuffleArr(items.map((_, i) => i)));
  const [pos, setPos] = React.useState(0);

  // Re-shuffle when the underlying list changes length
  React.useEffect(() => {
    setOrder(shuffleArr(items.map((_, i) => i)));
    setPos(0);
    setRound(1);
  }, [items.length]);
  const safeOrder = order.length ? order : [0];
  const current = items[safeOrder[pos % safeOrder.length]] || items[0];
  const next = () => {
    if (pos + 1 >= safeOrder.length) {
      // Reshuffle next round; avoid immediate repeat of the last item by
      // re-rolling if the new first item equals the last shown.
      const last = safeOrder[pos];
      let nextOrder = shuffleArr(items.map((_, i) => i));
      let guard = 0;
      while (nextOrder[0] === last && nextOrder.length > 1 && guard++ < 8) {
        nextOrder = shuffleArr(nextOrder);
      }
      setOrder(nextOrder);
      setPos(0);
      setRound(r => r + 1);
    } else {
      setPos(p => p + 1);
    }
  };
  return {
    current,
    next,
    round,
    posInRound: pos + 1,
    totalInRound: safeOrder.length
  };
};

// ─────────────────────────────────────────────────────────────
// Confirm dialog — small centered sheet
// ─────────────────────────────────────────────────────────────
const ConfirmDialog = ({
  open,
  title,
  body,
  confirmLabel = "删除",
  danger = true,
  onConfirm,
  onCancel
}) => {
  if (!open) return null;
  return /*#__PURE__*/React.createElement("div", {
    className: "confirm-scrim",
    onClick: onCancel
  }, /*#__PURE__*/React.createElement("div", {
    className: "confirm-box",
    onClick: e => e.stopPropagation()
  }, /*#__PURE__*/React.createElement("div", {
    className: "confirm-title"
  }, title), body && /*#__PURE__*/React.createElement("div", {
    className: "confirm-body"
  }, body), /*#__PURE__*/React.createElement("div", {
    className: "confirm-actions"
  }, /*#__PURE__*/React.createElement("button", {
    className: "btn ghost",
    onClick: onCancel
  }, "\u53D6\u6D88"), /*#__PURE__*/React.createElement("button", {
    className: "btn" + (danger ? " danger" : ""),
    onClick: onConfirm
  }, confirmLabel))));
};

// ─────────────────────────────────────────────────────────────
// LIBRARY
// ─────────────────────────────────────────────────────────────
const LibraryScreen = ({
  go,
  openSheet,
  quotes,
  tags,
  onDeleteQuotes,
  onDeleteTag
}) => {
  const [tag, setTag] = React.useState("全部");
  const [selecting, setSelecting] = React.useState(false);
  const [picked, setPicked] = React.useState(() => new Set());
  const [managingTags, setManagingTags] = React.useState(false);
  const [confirm, setConfirm] = React.useState(null); // {type, ...}

  // Reset selection when leaving select mode or changing filter
  React.useEffect(() => {
    if (!selecting) setPicked(new Set());
  }, [selecting]);
  const filtered = tag === "全部" ? quotes : quotes.filter(q => q.tag === tag);
  // In select mode the "today" card is folded into the list so everything is selectable
  const today = !selecting ? filtered[0] || quotes[0] : null;
  const rest = today ? filtered.filter(q => q.id !== today.id) : filtered;
  const togglePick = id => setPicked(p => {
    const n = new Set(p);
    n.has(id) ? n.delete(id) : n.add(id);
    return n;
  });
  const allPicked = rest.length > 0 && rest.every(q => picked.has(q.id));
  const toggleAll = () => setPicked(allPicked ? new Set() : new Set(rest.map(q => q.id)));
  const doDeleteQuotes = () => {
    onDeleteQuotes([...picked]);
    setConfirm(null);
    setSelecting(false);
  };

  // ── Select-mode header ──
  if (selecting) {
    return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
      className: "topbar select-bar"
    }, /*#__PURE__*/React.createElement("button", {
      className: "icon-btn",
      onClick: () => setSelecting(false),
      "aria-label": "cancel"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "x"
    })), /*#__PURE__*/React.createElement("span", {
      className: "select-count"
    }, picked.size > 0 ? `已选 ${picked.size} 句` : "选择金句"), /*#__PURE__*/React.createElement("button", {
      className: "text-btn",
      onClick: toggleAll
    }, allPicked ? "取消全选" : "全选")), /*#__PURE__*/React.createElement("div", {
      className: "content"
    }, rest.map(q => /*#__PURE__*/React.createElement(QuoteCard, {
      key: q.id,
      quote: q.q,
      source: q.tag,
      date: q.date,
      selectable: true,
      selected: picked.has(q.id),
      onToggle: () => togglePick(q.id)
    })), rest.length === 0 && /*#__PURE__*/React.createElement("div", {
      className: "empty-note"
    }, "\u8FD9\u4E2A\u6807\u7B7E\u4E0B\u8FD8\u6CA1\u6709\u91D1\u53E5\u3002"), /*#__PURE__*/React.createElement("div", {
      style: {
        height: 90
      }
    })), /*#__PURE__*/React.createElement("div", {
      className: "action-bar"
    }, /*#__PURE__*/React.createElement("button", {
      className: "btn danger block",
      disabled: picked.size === 0,
      style: {
        opacity: picked.size === 0 ? 0.4 : 1
      },
      onClick: () => setConfirm({
        type: "quotes"
      })
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "trash-2",
      size: 18
    }), " \u53D6\u51FA ", picked.size > 0 ? picked.size : "", " \u53E5")), /*#__PURE__*/React.createElement(ConfirmDialog, {
      open: confirm?.type === "quotes",
      title: `从金库取出这 ${picked.size} 句？`,
      body: "\u53D6\u51FA\u540E\u5C06\u4E0D\u518D\u51FA\u73B0\u5728\u9996\u9875\u548C\u7EC4\u4EF6\u91CC\u3002",
      confirmLabel: "\u53D6\u51FA",
      onConfirm: doDeleteQuotes,
      onCancel: () => setConfirm(null)
    }));
  }

  // ── Normal header ──
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u5C0F\u91D1\u5E93",
    subtitle: "est. 2026",
    actions: [{
      icon: "search",
      label: "搜索"
    }, {
      icon: "check-square",
      label: "多选",
      onClick: () => setSelecting(true)
    }]
  }), /*#__PURE__*/React.createElement("div", {
    className: "content"
  }, /*#__PURE__*/React.createElement("div", {
    className: "hero"
  }, /*#__PURE__*/React.createElement("div", {
    className: "hi"
  }, "\u4ECA\u5929\u7684\u91D1\u53E5")), today && /*#__PURE__*/React.createElement(QuoteCard, {
    variant: "dark",
    quote: today.q,
    source: today.tag,
    date: today.date,
    onClick: () => go("display")
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h",
    style: {
      marginTop: 24
    }
  }, /*#__PURE__*/React.createElement("span", null, "\u4F60\u7684\u91D1\u5E93"), /*#__PURE__*/React.createElement("span", {
    className: "ct"
  }, quotes.length, " \u53E5")), /*#__PURE__*/React.createElement("div", {
    className: "tag-row"
  }, tags.map(t => {
    const removable = managingTags && t !== "全部";
    return /*#__PURE__*/React.createElement("span", {
      key: t,
      className: "tag" + (t === tag ? " active" : "") + (removable ? " removable" : ""),
      onClick: () => removable ? setConfirm({
        type: "tag",
        tag: t
      }) : setTag(t)
    }, t, removable && /*#__PURE__*/React.createElement("span", {
      className: "tag-x"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "x",
      size: 12
    })));
  }), /*#__PURE__*/React.createElement("span", {
    className: "tag manage-tag",
    onClick: () => setManagingTags(m => !m)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: managingTags ? "check" : "pencil",
    size: 12
  }), managingTags ? " 完成" : " 管理")), rest.map(q => /*#__PURE__*/React.createElement(QuoteCard, {
    key: q.id,
    quote: q.q,
    source: q.tag,
    date: q.date
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 80
    }
  })), /*#__PURE__*/React.createElement(Fab, {
    onClick: () => go("editor")
  }), /*#__PURE__*/React.createElement(BottomNav, {
    current: "library",
    onChange: go
  }), /*#__PURE__*/React.createElement(ConfirmDialog, {
    open: confirm?.type === "tag",
    title: `删除标签「${confirm?.tag}」？`,
    body: "\u6807\u7B7E\u4E0B\u7684\u91D1\u53E5\u4F1A\u79FB\u5230\u300C\u672A\u5206\u7C7B\u300D\uFF0C\u4E0D\u4F1A\u88AB\u5220\u9664\u3002",
    confirmLabel: "\u5220\u9664\u6807\u7B7E",
    onConfirm: () => {
      onDeleteTag(confirm.tag);
      if (tag === confirm.tag) setTag("全部");
      setConfirm(null);
    },
    onCancel: () => setConfirm(null)
  }));
};

// ─────────────────────────────────────────────────────────────
// EDITOR
// ─────────────────────────────────────────────────────────────
const EditorScreen = ({
  go,
  onSave,
  openSheet
}) => {
  const [text, setText] = React.useState("");
  const [src, setSrc] = React.useState("");
  const canSave = text.trim().length > 0;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u65B0\u7684\u4E00\u53E5",
    actions: [{
      icon: "upload",
      label: "批量导入",
      onClick: openSheet
    }, {
      icon: "x",
      label: "关闭",
      onClick: () => go("library")
    }]
  }), /*#__PURE__*/React.createElement("div", {
    className: "content",
    style: {
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "composer"
  }, /*#__PURE__*/React.createElement("textarea", {
    placeholder: "\u5199\u4E0B\u4E00\u53E5\u4F60\u6700\u8FD1\u8BFB\u5230\u7684\u8BDD\u2026",
    value: text,
    onChange: e => setText(e.target.value),
    autoFocus: true
  }), /*#__PURE__*/React.createElement("div", {
    className: "footer-tools"
  }, /*#__PURE__*/React.createElement("input", {
    className: "src-input",
    placeholder: "\u2014 \u51FA\u5904 / \u6807\u7B7E\uFF08\u53EF\u7559\u7A7A\uFF09",
    value: src,
    onChange: e => setSrc(e.target.value)
  }), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "image"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "image"
  }))), /*#__PURE__*/React.createElement("button", {
    className: "btn block",
    disabled: !canSave,
    onClick: () => {
      onSave(text, src);
      go("library");
    },
    style: {
      opacity: canSave ? 1 : 0.4,
      marginTop: 12
    }
  }, "\u6536\u5165\u91D1\u5E93"))));
};

// ─────────────────────────────────────────────────────────────
// 首页 HOME — full-screen, no-repeat shuffle, switchable layouts
// ─────────────────────────────────────────────────────────────
const DisplayScreen = ({
  go,
  quotes
}) => {
  const [withPhoto, setWithPhoto] = React.useState(false);
  const [layoutIdx, setLayoutIdx] = React.useState(0);
  const {
    current,
    next
  } = useNoRepeatShuffle(quotes);
  const [fadeKey, setFadeKey] = React.useState(0);
  const advance = () => {
    next();
    setFadeKey(k => k + 1);
  };
  const layout = LAYOUTS[layoutIdx];
  const LayoutComp = LAYOUT_COMPONENTS[layout.key];
  return /*#__PURE__*/React.createElement("div", {
    className: "display-screen"
  }, withPhoto && /*#__PURE__*/React.createElement("div", {
    className: "display-bg protect",
    style: {
      background: "linear-gradient(135deg, #5e7263 0%, #324638 60%, #1d2a1f 100%)"
    }
  }), /*#__PURE__*/React.createElement("div", {
    className: "grain"
  }), /*#__PURE__*/React.createElement("div", {
    className: "layout-pip" + (withPhoto ? " on-photo" : ""),
    key: "pip-" + layoutIdx
  }, layout.label, " \xB7 ", /*#__PURE__*/React.createElement("em", null, layout.name)), /*#__PURE__*/React.createElement("div", {
    className: "display-content layout-host" + (withPhoto ? " on-photo" : ""),
    key: fadeKey + "-" + layoutIdx
  }, /*#__PURE__*/React.createElement(LayoutComp, {
    quote: current
  })), /*#__PURE__*/React.createElement("div", {
    className: "display-controls",
    style: {
      bottom: 84
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "dctl",
    onClick: advance,
    "aria-label": "next"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "shuffle"
  })), /*#__PURE__*/React.createElement("button", {
    className: "dctl",
    onClick: () => setLayoutIdx(i => (i + 1) % LAYOUTS.length),
    "aria-label": "layout"
  }, /*#__PURE__*/React.createElement("span", {
    className: "layout-glyph"
  }, layout.label)), /*#__PURE__*/React.createElement("button", {
    className: "dctl",
    onClick: () => setWithPhoto(p => !p),
    "aria-label": "photo"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "image"
  })), /*#__PURE__*/React.createElement("button", {
    className: "dctl",
    "aria-label": "save"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "bookmark"
  }))), /*#__PURE__*/React.createElement(BottomNav, {
    current: "display",
    onChange: go
  }));
};

// ─────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────
const SettingsScreen = ({
  go,
  theme,
  onTheme
}) => {
  const [cadence] = React.useState("30 分钟");
  const [shuffle, setShuffle] = React.useState(true);
  const [showSrc, setShowSrc] = React.useState(true);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u6211\u7684",
    subtitle: "profile"
  }), /*#__PURE__*/React.createElement("div", {
    className: "content"
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5C0F\u7EC4\u4EF6"), /*#__PURE__*/React.createElement(SettingsGroup, null, /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u81EA\u5B9A\u4E49\u5C0F\u7EC4\u4EF6",
    sub: "\u5C3A\u5BF8\u3001\u9891\u7387\u3001\u6765\u6E90\u3001\u5B57\u53F7",
    chev: true,
    onClick: () => go("widget")
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u66F4\u6362\u9891\u7387",
    sub: "\u4E00\u53E5\u8BDD\u505C\u7559\u591A\u4E45",
    value: cadence,
    chev: true
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u4E0D\u91CD\u590D\u8F6E\u64AD",
    sub: "\u6240\u6709\u53E5\u5B50\u8F6E\u8FC7\u4E00\u6B21\u624D\u518D\u51FA\u73B0",
    toggle: shuffle,
    onToggle: setShuffle,
    chev: false
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u663E\u793A\u51FA\u5904",
    sub: "quote attribution",
    toggle: showSrc,
    onToggle: setShowSrc,
    chev: false
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u80CC\u666F\u56FE\u7247",
    sub: "\u9009\u62E9\u58C1\u7EB8\u6216\u76F8\u518C",
    value: "\u7EB8\u7EB9\u7406 \xB7 2",
    chev: true
  })), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5B57\u4F53\u4E0E\u5916\u89C2"), /*#__PURE__*/React.createElement(SettingsGroup, null, /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u4E3B\u9898",
    value: themeByKey(theme).name + " · " + themeByKey(theme).en,
    chev: true,
    onClick: () => onTheme(nextTheme(theme))
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u5B57\u53F7",
    value: "\u6807\u51C6",
    chev: true
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u5B57\u4F53",
    value: "\u601D\u6E90\u5B8B\u4F53",
    chev: true
  })), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5BFC\u5165\u4E0E\u5BFC\u51FA"), /*#__PURE__*/React.createElement(SettingsGroup, null, /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u6279\u91CF\u5BFC\u5165",
    sub: "\u7C98\u8D34\u5927\u6BB5\u6587\u5B57\uFF0C\u81EA\u52A8\u5206\u884C",
    chev: true
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u5BFC\u51FA\u91D1\u5E93",
    sub: "\u5907\u4EFD\u4E3A .txt",
    chev: true
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u4ECE\u5907\u5FD8\u5F55\u5BFC\u5165",
    chev: true
  })), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5173\u4E8E"), /*#__PURE__*/React.createElement(SettingsGroup, null, /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u5C0F\u91D1\u5E93",
    sub: "\u4E00\u53E5\u8BDD\u505C\u4E00\u505C",
    chev: true
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u7ED9\u4F5C\u8005\u5199\u4E00\u53E5",
    chev: true
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 40,
      textAlign: "center",
      fontFamily: "var(--serif-italic)",
      fontStyle: "italic",
      fontSize: 12,
      color: "var(--fg-muted)",
      padding: "20px 0"
    }
  }, "v 0.1 \xB7 \u5171 ", SEED_QUOTES.length, " \u53E5\u5DF2\u5165\u5E93")), /*#__PURE__*/React.createElement(BottomNav, {
    current: "settings",
    onChange: go
  }));
};

// ─────────────────────────────────────────────────────────────
// IMPORT SHEET
// ─────────────────────────────────────────────────────────────
const ImportSheet = ({
  open,
  onClose,
  onImport
}) => {
  const [text, setText] = React.useState("");
  if (!open) return null;
  const lines = text.split(/\n+/).map(l => l.trim()).filter(Boolean);
  return /*#__PURE__*/React.createElement("div", {
    className: "sheet",
    onClick: onClose
  }, /*#__PURE__*/React.createElement("div", {
    className: "sheet-inner",
    onClick: e => e.stopPropagation()
  }, /*#__PURE__*/React.createElement("div", {
    className: "sheet-grabber"
  }), /*#__PURE__*/React.createElement("h2", null, "\u6279\u91CF\u5BFC\u5165"), /*#__PURE__*/React.createElement("div", {
    className: "sheet-help"
  }, "\u628A\u4E00\u6574\u6BB5\u8BDD\u7C98\u8FDB\u6765\uFF0C\u4F1A\u81EA\u52A8\u5206\u884C\u3002"), /*#__PURE__*/React.createElement("textarea", {
    autoFocus: true,
    placeholder: "你在心里种下的种子，时间会帮它找出口。\n真正的强大不是没有裂痕，而是光从裂痕里照进来。\n你不必完美，你只需要真实且完整地活着。",
    value: text,
    onChange: e => setText(e.target.value)
  }), /*#__PURE__*/React.createElement("div", {
    className: "count-line"
  }, /*#__PURE__*/React.createElement("span", null, "\u8BC6\u522B\u5230"), /*#__PURE__*/React.createElement("span", null, /*#__PURE__*/React.createElement("span", {
    className: "n"
  }, lines.length), " \u53E5")), /*#__PURE__*/React.createElement("button", {
    className: "btn block",
    onClick: () => {
      onImport(lines);
      onClose();
    },
    disabled: lines.length === 0,
    style: {
      opacity: lines.length === 0 ? 0.4 : 1
    }
  }, "\u5168\u90E8\u6536\u5165\u91D1\u5E93")));
};
Object.assign(window, {
  SEED_QUOTES,
  TAGS,
  shuffleArr,
  useNoRepeatShuffle,
  ConfirmDialog,
  LibraryScreen,
  EditorScreen,
  DisplayScreen,
  SettingsScreen,
  ImportSheet
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-app/screens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/android-app/widget-editor.jsx
try { (() => {
// 小金库 — Widget editor screen. Live preview + all controls.

const WIDGET_SIZES = [{
  key: "small",
  label: "小",
  pretty: "1×1"
}, {
  key: "medium",
  label: "中",
  pretty: "2×1"
}, {
  key: "large",
  label: "大",
  pretty: "2×2"
}, {
  key: "xlarge",
  label: "巨",
  pretty: "4×4"
}];
const CADENCES = [{
  key: 5,
  label: "5 分钟"
}, {
  key: 15,
  label: "15 分钟"
}, {
  key: 30,
  label: "30 分钟"
}, {
  key: 60,
  label: "1 小时"
}, {
  key: 240,
  label: "4 小时"
}, {
  key: 1440,
  label: "每日一句"
}];
const TEXT_SCALES = [{
  key: "small",
  label: "小"
}, {
  key: "normal",
  label: "标准"
}, {
  key: "large",
  label: "大"
}];
const BG_OPTIONS = [{
  key: "paper",
  label: "纸面"
}, {
  key: "white",
  label: "留白"
}, {
  key: "rice",
  label: "米白"
}, {
  key: "paperwhite",
  label: "纸白"
}, {
  key: "ink",
  label: "墨色"
}, {
  key: "leaf",
  label: "色彩"
}, {
  key: "photo",
  label: "照片",
  disabled: true,
  note: "未上传"
}];

// ─────── In-preview widget (size-aware) ───────
const PreviewWidget = ({
  size,
  quote,
  theme,
  textScale,
  showSource,
  bg,
  cardOpacity = 1
}) => {
  const sizeMap = {
    small: {
      w: 160,
      h: 160,
      qSize: 14,
      line: 1.6,
      lineClamp: 5
    },
    medium: {
      w: 320,
      h: 156,
      qSize: 16,
      line: 1.65,
      lineClamp: 4
    },
    large: {
      w: 320,
      h: 320,
      qSize: 19,
      line: 1.8,
      lineClamp: 6
    },
    xlarge: {
      w: 340,
      h: 340,
      qSize: 22,
      line: 1.85,
      lineClamp: 9
    }
  };
  const tsBoost = textScale === "large" ? 2 : textScale === "small" ? -2 : 0;
  const s = sizeMap[size];

  // Background fills — theme-aware via CSS vars
  const bgStyle = (() => {
    if (bg === "paper") return {
      background: "var(--bg-raised)",
      color: "var(--fg-1)"
    };
    if (bg === "white") return {
      background: "#ffffff",
      color: "#1f1d1a"
    };
    if (bg === "rice") return {
      background: "#f3ecda",
      color: "#2a2620"
    };
    if (bg === "paperwhite") return {
      background: "#f7f6f1",
      color: "#26241f"
    };
    if (bg === "ink") return {
      background: "var(--ink-900)",
      color: "var(--bg-page)"
    };
    if (bg === "leaf") return {
      background: "linear-gradient(155deg, var(--accent-soft) 0%, var(--accent) 55%, var(--accent-pressed) 100%)",
      color: "var(--fg-on-accent)"
    };
    if (bg === "photo") return {
      background: "linear-gradient(135deg, var(--ink-500), var(--ink-900))",
      color: "#fff"
    };
    return {};
  })();
  return /*#__PURE__*/React.createElement("div", {
    className: "pv-widget",
    style: {
      width: s.w,
      height: s.h,
      borderRadius: 28,
      padding: size === "large" || size === "xlarge" ? 24 : 18,
      boxShadow: "0 10px 28px rgba(28,26,23,0.18)",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      fontFamily: "var(--serif-display)",
      overflow: "hidden",
      position: "relative",
      color: bgStyle.color
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      zIndex: 0,
      background: bgStyle.background,
      opacity: cardOpacity
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      zIndex: 1,
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      height: "100%"
    }
  }, (size === "large" || size === "xlarge") && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--sans-ui)",
      fontSize: 11,
      letterSpacing: "0.04em",
      opacity: 0.6
    }
  }, "\u5C0F\u91D1\u5E93 \xB7 ", /*#__PURE__*/React.createElement("em", {
    style: {
      fontFamily: "var(--serif-italic)",
      fontStyle: "italic"
    }
  }, "Folio")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: s.qSize + tsBoost,
      lineHeight: s.line,
      flex: 1,
      display: "-webkit-box",
      WebkitLineClamp: s.lineClamp,
      WebkitBoxOrient: "vertical",
      overflow: "hidden",
      alignItems: "center"
    }
  }, quote.q), showSource && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--serif-italic)",
      fontStyle: "italic",
      fontSize: size === "small" ? 11 : 12,
      opacity: 0.55,
      marginTop: size === "small" ? 6 : 8
    }
  }, "\u2014 ", quote.tag)));
};

// ─────── Segmented control ───────
const Seg = ({
  value,
  options,
  onChange
}) => /*#__PURE__*/React.createElement("div", {
  className: "seg"
}, options.map(o => /*#__PURE__*/React.createElement("button", {
  key: o.key,
  className: "seg-btn" + (value === o.key ? " active" : "") + (o.disabled ? " disabled" : ""),
  onClick: () => !o.disabled && onChange(o.key),
  disabled: o.disabled
}, o.label, o.pretty && /*#__PURE__*/React.createElement("span", {
  className: "seg-sub"
}, o.pretty), o.note && /*#__PURE__*/React.createElement("span", {
  className: "seg-note"
}, o.note))));

// ─────── Chip row (multi-choice or single) ───────
const ChipRow = ({
  value,
  options,
  onChange
}) => /*#__PURE__*/React.createElement("div", {
  className: "chip-row"
}, options.map(o => /*#__PURE__*/React.createElement("button", {
  key: o.key ?? o,
  className: "chip" + (value === (o.key ?? o) ? " active" : ""),
  onClick: () => onChange(o.key ?? o)
}, o.label ?? o)));

// ─────── Opacity slider ───────
const OpacitySlider = ({
  value,
  onChange
}) => /*#__PURE__*/React.createElement("div", {
  className: "opacity-slider",
  style: {
    display: "flex",
    alignItems: "center",
    gap: 12
  }
}, /*#__PURE__*/React.createElement("input", {
  type: "range",
  min: 40,
  max: 100,
  step: 5,
  value: Math.round(value * 100),
  onChange: e => onChange(Number(e.target.value) / 100),
  style: {
    flex: 1,
    accentColor: "var(--ink-900)",
    height: 4
  }
}), /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--sans-ui)",
    fontSize: 13,
    fontVariantNumeric: "tabular-nums",
    color: "var(--fg-2)",
    minWidth: 40,
    textAlign: "right"
  }
}, Math.round(value * 100), "%"));

// ─────── Widget editor screen ───────
const WidgetEditorScreen = ({
  go,
  theme,
  onTheme,
  quotes
}) => {
  const [size, setSize] = React.useState("medium");
  const [cadence, setCadence] = React.useState(30);
  const [source, setSource] = React.useState("全部");
  const [showSource, setShowSource] = React.useState(true);
  const [textScale, setTextScale] = React.useState("normal");
  const [bg, setBg] = React.useState("paper");
  const [cardOpacity, setCardOpacity] = React.useState(1);
  const filteredQuotes = source === "全部" ? quotes : quotes.filter(q => q.tag === source);
  const previewQ = filteredQuotes[0] || quotes[0];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u81EA\u5B9A\u4E49\u5C0F\u7EC4\u4EF6",
    subtitle: "widget",
    actions: [{
      icon: "x",
      label: "关闭",
      onClick: () => go("settings")
    }]
  }), /*#__PURE__*/React.createElement("div", {
    className: "content"
  }, /*#__PURE__*/React.createElement("div", {
    className: "we-preview-stage"
  }, /*#__PURE__*/React.createElement("div", {
    className: "we-preview-inner"
  }, /*#__PURE__*/React.createElement(PreviewWidget, {
    size: size,
    quote: previewQ,
    theme: theme,
    textScale: textScale,
    showSource: showSource,
    bg: bg,
    cardOpacity: cardOpacity
  }))), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5C3A\u5BF8"), /*#__PURE__*/React.createElement(Seg, {
    value: size,
    options: WIDGET_SIZES,
    onChange: setSize
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5B57\u53F7"), /*#__PURE__*/React.createElement(Seg, {
    value: textScale,
    options: TEXT_SCALES,
    onChange: setTextScale
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u66F4\u6362\u9891\u7387"), /*#__PURE__*/React.createElement(ChipRow, {
    value: cadence,
    options: CADENCES,
    onChange: setCadence
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u6765\u81EA\u54EA\u4E2A\u6807\u7B7E"), /*#__PURE__*/React.createElement(ChipRow, {
    value: source,
    options: TAGS,
    onChange: setSource
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u80CC\u666F"), /*#__PURE__*/React.createElement(ChipRow, {
    value: bg,
    options: BG_OPTIONS,
    onChange: setBg
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-h"
  }, "\u5361\u7247\u4E0D\u900F\u660E\u5EA6"), /*#__PURE__*/React.createElement(OpacitySlider, {
    value: cardOpacity,
    onChange: setCardOpacity
  }), /*#__PURE__*/React.createElement("div", {
    className: "settings-group",
    style: {
      marginTop: 16
    }
  }, /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u663E\u793A\u51FA\u5904",
    sub: "show attribution",
    toggle: showSource,
    onToggle: setShowSource,
    chev: false
  }), /*#__PURE__*/React.createElement(SettingRow, {
    label: "\u4E0D\u91CD\u590D\u8F6E\u64AD",
    sub: "\u6240\u6709\u53E5\u5B50\u8F6E\u8FC7\u4E00\u6B21\u624D\u518D\u51FA\u73B0",
    toggle: true,
    onToggle: () => {},
    chev: false
  })), /*#__PURE__*/React.createElement("button", {
    className: "btn block",
    style: {
      marginTop: 20
    },
    onClick: () => go("library")
  }, "\u6DFB\u52A0\u5230\u4E3B\u5C4F"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12,
      textAlign: "center",
      fontFamily: "var(--serif-italic)",
      fontStyle: "italic",
      fontSize: 12,
      color: "var(--fg-muted)"
    }
  }, "\u5F53\u524D\u7B5B\u9009 \xB7 ", filteredQuotes.length, " \u53E5\u53EF\u7528 \xB7 \u6BCF ", CADENCES.find(c => c.key === cadence)?.label, " \u66F4\u6362"), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 24
    }
  })), /*#__PURE__*/React.createElement(BottomNav, {
    current: "widget",
    onChange: go
  }));
};
Object.assign(window, {
  WidgetEditorScreen,
  PreviewWidget,
  Seg,
  ChipRow,
  OpacitySlider,
  WIDGET_SIZES,
  CADENCES,
  TEXT_SCALES,
  BG_OPTIONS
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-app/widget-editor.jsx", error: String((e && e.message) || e) }); }

// ui_kits/android-widgets/widgets.jsx
try { (() => {
// Android widgets — small / medium / large

const WIDGET_QUOTES = [{
  q: "真正的强大不是没有裂痕，而是光从裂痕里照进来。",
  src: "完整而非完美"
}, {
  q: "你在心里种下的种子，时间会帮它找出口。",
  src: "坚持与回响"
}, {
  q: "不必急着去对岸，此刻的波浪也是风景。",
  src: "旅程与抵达"
}, {
  q: "接纳自己的阴影，才能拥抱真正的光明。",
  src: "自我接纳"
}, {
  q: "人生不是冲刺，是一场深呼吸就能继续的远行。",
  src: "旅程与抵达"
}];
const ICON_BASE = "https://unpkg.com/lucide-static@latest/icons/";

// A deliberately long quote to stress-test the multi-char case
const LONG_QUOTE = {
  q: "走得慢的人，只要不丢失目标，也会比那些漫无目的地四处奔跑的人更早抵达自己真正想去的地方。",
  src: "旅程与抵达"
};

// Small (1x1 cell — 76×76 in Android dp, scale up to 160×160 here)
const SmallWidget = ({
  quote,
  theme = "paper"
}) => /*#__PURE__*/React.createElement("div", {
  className: "w-small " + theme
}, /*#__PURE__*/React.createElement("div", {
  className: "seal"
}, "\u91D1"), /*#__PURE__*/React.createElement("div", {
  className: "q"
}, quote.q));

// Medium (2x1 cell — 320×160)
const MediumWidget = ({
  quote,
  theme = "paper"
}) => /*#__PURE__*/React.createElement("div", {
  className: "w-medium " + theme
}, /*#__PURE__*/React.createElement("div", {
  className: "q"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "row"
}, /*#__PURE__*/React.createElement("div", {
  className: "src"
}, "\u2014 ", quote.src), /*#__PURE__*/React.createElement("div", {
  className: "seal"
}, "\u91D1")));

// Large (2x2 cell — 320×320)
const LargeWidget = ({
  quote,
  theme = "paper"
}) => /*#__PURE__*/React.createElement("div", {
  className: "w-large " + theme
}, /*#__PURE__*/React.createElement("div", {
  className: "seal-row"
}, /*#__PURE__*/React.createElement("div", {
  className: "seal"
}, "\u91D1"), /*#__PURE__*/React.createElement("div", {
  className: "brand"
}, "\u5C0F\u91D1\u5E93 \xB7 ", /*#__PURE__*/React.createElement("em", null, "Folio"))), /*#__PURE__*/React.createElement("div", {
  className: "q"
}, quote.q), /*#__PURE__*/React.createElement("div", {
  className: "footer"
}, /*#__PURE__*/React.createElement("div", {
  className: "src"
}, "\u2014 ", quote.src), /*#__PURE__*/React.createElement("div", {
  className: "next"
}, /*#__PURE__*/React.createElement("img", {
  src: ICON_BASE + "shuffle.svg",
  alt: ""
}))));
const WidgetRow = ({
  theme,
  label
}) => /*#__PURE__*/React.createElement("div", {
  className: "row-wrap"
}, /*#__PURE__*/React.createElement("div", {
  className: "row-label"
}, label), /*#__PURE__*/React.createElement("div", {
  className: "row-tiles"
}, /*#__PURE__*/React.createElement(SmallWidget, {
  quote: WIDGET_QUOTES[0],
  theme: theme
}), /*#__PURE__*/React.createElement(MediumWidget, {
  quote: WIDGET_QUOTES[1],
  theme: theme
}), /*#__PURE__*/React.createElement(LargeWidget, {
  quote: WIDGET_QUOTES[2],
  theme: theme
})));

// ─────────────────────────────────────────────────────────────
// Resizable widget — the real Android behaviour: user long-presses,
// drags a corner handle, widget snaps to home-grid cells, and the
// CONTENT REFLOWS + the type AUTO-FITS to both box size AND length.
// ─────────────────────────────────────────────────────────────
const CELL = 78; // one home-grid cell (px, scaled up for the kit)
const GAP = 14; // gutter between cells
const cellsToPx = n => n * CELL + (n - 1) * GAP;

// Fit font size to the box area divided by char count (CJK ≈ square glyphs),
// then clamp. Bigger box → bigger type; more chars → smaller type.
const fitFont = (w, h, chars, reserve) => {
  const innerW = w - 36;
  const innerH = h - 36 - reserve;
  const area = Math.max(0, innerW * innerH);
  const per = area / Math.max(chars, 1);
  return Math.max(12, Math.min(30, Math.sqrt(per) * 0.82));
};
const ResizableWidget = ({
  quote,
  theme,
  cw,
  ch
}) => {
  const w = cellsToPx(cw),
    h = cellsToPx(ch);
  const chars = [...quote.q].length;
  const cells = cw * ch;

  // Reflow tiers driven by the cell footprint
  const showBrand = cw >= 3 && ch >= 2;
  const showFooter = ch >= 2;
  const showAttrInline = ch === 1 && cw >= 2;
  const reserve = (showBrand ? 26 : 0) + (showFooter ? 26 : 0) + (showAttrInline ? 18 : 0);
  const fs = fitFont(w, h, chars, reserve);
  // Max lines the box can hold at this font — used as a graceful clamp floor
  const lineH = fs * 1.7;
  const avail = h - 36 - reserve;
  const maxLines = Math.max(1, Math.floor(avail / lineH));

  // Golden vertical anchor once the widget is large enough to have free space
  const golden = cells >= 4 && ch >= 2;
  return /*#__PURE__*/React.createElement("div", {
    className: "rz-widget " + theme,
    style: {
      width: w,
      height: h
    }
  }, showBrand && /*#__PURE__*/React.createElement("div", {
    className: "rz-brand"
  }, /*#__PURE__*/React.createElement("span", {
    className: "rz-seal"
  }, "\u91D1"), /*#__PURE__*/React.createElement("span", null, "\u5C0F\u91D1\u5E93 \xB7 ", /*#__PURE__*/React.createElement("em", null, "Folio"))), /*#__PURE__*/React.createElement("div", {
    className: "rz-qregion" + (golden ? " golden" : "")
  }, /*#__PURE__*/React.createElement("div", {
    className: "rz-quote",
    style: {
      fontSize: fs,
      lineHeight: 1.7,
      WebkitLineClamp: maxLines
    }
  }, quote.q)), showFooter && /*#__PURE__*/React.createElement("div", {
    className: "rz-foot"
  }, /*#__PURE__*/React.createElement("span", {
    className: "rz-cat"
  }, quote.src), /*#__PURE__*/React.createElement("img", {
    className: "rz-shuffle",
    src: ICON_BASE + "shuffle.svg",
    alt: ""
  })), showAttrInline && /*#__PURE__*/React.createElement("div", {
    className: "rz-attr"
  }, "\u2014 ", quote.src), !showFooter && !showAttrInline && !showBrand && cw === 1 && ch === 1 && /*#__PURE__*/React.createElement("span", {
    className: "rz-seal rz-seal-corner"
  }, "\u91D1"));
};
const ResizableDemo = () => {
  const [theme, setTheme] = React.useState("paper");
  const [longQuote, setLongQuote] = React.useState(false);
  const [size, setSize] = React.useState({
    cw: 2,
    ch: 2
  });
  const stageRef = React.useRef(null);
  const drag = React.useRef(null);
  const quote = longQuote ? LONG_QUOTE : WIDGET_QUOTES[0];
  const onHandleDown = e => {
    e.preventDefault();
    const startX = e.clientX,
      startY = e.clientY;
    drag.current = {
      startX,
      startY,
      cw: size.cw,
      ch: size.ch
    };
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp);
  };
  const onMove = e => {
    if (!drag.current) return;
    const dx = e.clientX - drag.current.startX;
    const dy = e.clientY - drag.current.startY;
    const cw = Math.max(1, Math.min(4, drag.current.cw + Math.round(dx / (CELL + GAP))));
    const ch = Math.max(1, Math.min(4, drag.current.ch + Math.round(dy / (CELL + GAP))));
    setSize({
      cw,
      ch
    });
  };
  const onUp = () => {
    drag.current = null;
    window.removeEventListener("pointermove", onMove);
    window.removeEventListener("pointerup", onUp);
  };
  return /*#__PURE__*/React.createElement("div", {
    className: "rz-demo"
  }, /*#__PURE__*/React.createElement("div", {
    className: "rz-controls"
  }, /*#__PURE__*/React.createElement("div", {
    className: "rz-seg"
  }, /*#__PURE__*/React.createElement("button", {
    className: "rz-seg-btn" + (theme === "paper" ? " on" : ""),
    onClick: () => setTheme("paper")
  }, "\u9752\u7EB8"), /*#__PURE__*/React.createElement("button", {
    className: "rz-seg-btn" + (theme === "night" ? " on" : ""),
    onClick: () => setTheme("night")
  }, "\u6797\u591C")), /*#__PURE__*/React.createElement("div", {
    className: "rz-seg"
  }, /*#__PURE__*/React.createElement("button", {
    className: "rz-seg-btn" + (!longQuote ? " on" : ""),
    onClick: () => setLongQuote(false)
  }, "\u77ED\u53E5"), /*#__PURE__*/React.createElement("button", {
    className: "rz-seg-btn" + (longQuote ? " on" : ""),
    onClick: () => setLongQuote(true)
  }, "\u957F\u53E5")), /*#__PURE__*/React.createElement("div", {
    className: "rz-presets"
  }, [[1, 1], [2, 1], [2, 2], [4, 2], [4, 4]].map(([cw, ch]) => /*#__PURE__*/React.createElement("button", {
    key: cw + "x" + ch,
    className: "rz-chip" + (size.cw === cw && size.ch === ch ? " on" : ""),
    onClick: () => setSize({
      cw,
      ch
    })
  }, cw, "\xD7", ch)))), /*#__PURE__*/React.createElement("div", {
    className: "rz-stage " + theme,
    ref: stageRef
  }, /*#__PURE__*/React.createElement("div", {
    className: "rz-grid"
  }), /*#__PURE__*/React.createElement("div", {
    className: "rz-holder",
    style: {
      width: cellsToPx(size.cw),
      height: cellsToPx(size.ch)
    }
  }, /*#__PURE__*/React.createElement(ResizableWidget, {
    quote: quote,
    theme: theme,
    cw: size.cw,
    ch: size.ch
  }), /*#__PURE__*/React.createElement("div", {
    className: "rz-handle",
    onPointerDown: onHandleDown,
    title: "\u62D6\u52A8\u7F29\u653E"
  }, /*#__PURE__*/React.createElement("img", {
    src: ICON_BASE + "move-diagonal-2.svg",
    alt: ""
  })), /*#__PURE__*/React.createElement("div", {
    className: "rz-dim"
  }, size.cw, " \xD7 ", size.ch))), /*#__PURE__*/React.createElement("div", {
    className: "rz-hint"
  }, "\u62D6\u53F3\u4E0B\u89D2\u624B\u67C4\u7F29\u653E\uFF08\u8D34\u5408\u4E3B\u5C4F\u7F51\u683C\uFF09\uFF0C\u6216\u70B9\u4E0A\u65B9\u9884\u8BBE\u3002\u7EC4\u4EF6\u968F\u5C3A\u5BF8\u91CD\u6392\u3001\u5B57\u53F7\u968F\u5C3A\u5BF8\uFF0B\u5B57\u6570\u81EA\u9002\u5E94\u3002"));
};

// Mock Android home screen to give widgets context
const HomeScreenContext = ({
  theme = "paper"
}) => {
  const isNight = theme === "night";
  return /*#__PURE__*/React.createElement("div", {
    className: "home-screen " + theme
  }, /*#__PURE__*/React.createElement("div", {
    className: "home-bg"
  }), /*#__PURE__*/React.createElement("div", {
    className: "home-content"
  }, /*#__PURE__*/React.createElement("div", {
    className: "time-block"
  }, /*#__PURE__*/React.createElement("div", {
    className: "time"
  }, "9:41"), /*#__PURE__*/React.createElement("div", {
    className: "date"
  }, "5\u6708 14\u65E5 \xB7 \u5468\u4E09")), /*#__PURE__*/React.createElement("div", {
    className: "widget-stack"
  }, /*#__PURE__*/React.createElement(LargeWidget, {
    quote: WIDGET_QUOTES[0],
    theme: theme
  }), /*#__PURE__*/React.createElement("div", {
    className: "row-2"
  }, /*#__PURE__*/React.createElement(SmallWidget, {
    quote: WIDGET_QUOTES[1],
    theme: theme
  }), /*#__PURE__*/React.createElement(SmallWidget, {
    quote: WIDGET_QUOTES[3],
    theme: theme
  })), /*#__PURE__*/React.createElement(MediumWidget, {
    quote: WIDGET_QUOTES[4],
    theme: theme
  })), /*#__PURE__*/React.createElement("div", {
    className: "dock"
  }, ["phone", "message-circle", "camera", "grid-2x2"].map(i => /*#__PURE__*/React.createElement("div", {
    key: i,
    className: "app-tile"
  }, /*#__PURE__*/React.createElement("img", {
    src: ICON_BASE + i + ".svg",
    alt: ""
  }))))));
};
const App = () => /*#__PURE__*/React.createElement("div", {
  className: "kit-frame"
}, /*#__PURE__*/React.createElement("div", {
  className: "legend"
}, /*#__PURE__*/React.createElement("h1", null, "\u5C0F\u91D1\u5E93 \xB7 \u5C0F\u7EC4\u4EF6"), /*#__PURE__*/React.createElement("p", null, "\u4E09\u79CD\u5C3A\u5BF8\u76EE\u5F55\u3001\u53EF\u62D6\u52A8\u7F29\u653E\u7684\u81EA\u9002\u5E94\u7EC4\u4EF6\u3001\u4EE5\u53CA\u653E\u4E0A\u4E3B\u5C4F\u7684\u5B9E\u9645\u6548\u679C\u3002\u7EC4\u4EF6\u968F\u5C3A\u5BF8\u91CD\u6392\uFF0C\u5B57\u53F7\u968F\u5C3A\u5BF8\uFF0B\u5B57\u6570\u81EA\u9002\u5E94\u3002")), /*#__PURE__*/React.createElement("h2", {
  className: "lane-h"
}, "\u5C3A\u5BF8\u76EE\u5F55 \xB7 Catalog"), /*#__PURE__*/React.createElement("div", {
  className: "catalog"
}, /*#__PURE__*/React.createElement(WidgetRow, {
  theme: "paper",
  label: "\u9752\u7EB8 \xB7 Tea Paper"
}), /*#__PURE__*/React.createElement(WidgetRow, {
  theme: "night",
  label: "\u6797\u591C \xB7 Forest Night"
})), /*#__PURE__*/React.createElement("h2", {
  className: "lane-h"
}, "\u53EF\u62D6\u52A8\u7F29\u653E \xB7 Resizable\uFF08\u591A\u5B57\u81EA\u9002\u5E94\uFF09"), /*#__PURE__*/React.createElement(ResizableDemo, null), /*#__PURE__*/React.createElement("h2", {
  className: "lane-h"
}, "\u653E\u5728\u4E3B\u5C4F\u4E0A \xB7 In situ"), /*#__PURE__*/React.createElement("div", {
  className: "home-row"
}, /*#__PURE__*/React.createElement(HomeScreenContext, {
  theme: "paper"
}), /*#__PURE__*/React.createElement(HomeScreenContext, {
  theme: "night"
})));
ReactDOM.createRoot(document.getElementById("root")).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/android-widgets/widgets.jsx", error: String((e && e.message) || e) }); }

})();
