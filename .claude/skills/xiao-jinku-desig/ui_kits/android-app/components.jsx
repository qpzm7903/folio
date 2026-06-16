// 小金库 — Android app UI Kit, shared primitives
// Exports to window for cross-script sharing.

const ICON_BASE = "https://unpkg.com/lucide-static@latest/icons/";
const Icon = ({ name, size = 20, style = {}, ...rest }) => (
  <img src={`${ICON_BASE}${name}.svg`} width={size} height={size} alt="" style={style} {...rest} />
);

// ─────────────────────────────────────────────────────────────
// Themes — 2 fresh-green + 4 classical (传统色). Order =晨→昏.
// `dark:true` themes get the structural dark-mode styling in kit.css.
// ─────────────────────────────────────────────────────────────
const THEMES = [
  { key: "paper",     name: "青纸", en: "Tea Paper",    dark: false },
  { key: "celadon",   name: "天青", en: "Celadon",      dark: false },
  { key: "moonwhite", name: "月白", en: "Moon White",   dark: false },
  { key: "cinnabar",  name: "绛霞", en: "Cinnabar",     dark: false },
  { key: "night",     name: "林夜", en: "Forest Night", dark: true  },
  { key: "dai",       name: "青黛", en: "Ink Indigo",   dark: true  },
];
const themeByKey = (k) => THEMES.find(t => t.key === k) || THEMES[0];
const nextTheme = (k) => THEMES[(THEMES.findIndex(t => t.key === k) + 1) % THEMES.length].key;

// ─────────────────────────────────────────────────────────────
// Phone shell — bezel + status bar + content + gesture nav
// ─────────────────────────────────────────────────────────────
const Phone = ({ theme = "paper", children, label }) => {
  return (
    <div className="phone-wrap" style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 14 }}>
      <div className="phone">
        <div className="phone-notch" />
        <div className="phone-screen" data-theme={theme === "paper" ? undefined : theme}>
          <StatusBar />
          {children}
          <GestureBar />
        </div>
      </div>
      {label && (
        <div style={{
          fontFamily: "var(--serif-italic)", fontStyle: "italic",
          fontSize: 13, color: "var(--fg-3)",
        }}>{label}</div>
      )}
    </div>
  );
};

const StatusBar = () => (
  <div className="status-bar">
    <span>9:41</span>
    <div className="sb-icons">
      <svg viewBox="0 0 16 16" fill="currentColor"><path d="M8 13.3L.67 5.97a10.37 10.37 0 0114.66 0L8 13.3z"/></svg>
      <svg viewBox="0 0 16 16" fill="currentColor"><path d="M14.67 14.67V1.33L1.33 14.67h13.34z"/></svg>
      <svg viewBox="0 0 18 16" fill="currentColor"><rect x="1" y="4" width="13" height="8" rx="1.5" fillOpacity="0.3"/><rect x="2" y="5" width="9" height="6" rx="0.5"/><rect x="15" y="6" width="1.5" height="4" rx="0.5"/></svg>
    </div>
  </div>
);

const GestureBar = () => <div className="gesture-bar" />;

// ─────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────
const TopBar = ({ title, subtitle, actions = [], leading = null }) => (
  <div className="topbar">
    <div className="title-wrap">
      {leading}
      <span className="title">{title}</span>
      {subtitle && <span className="sub">{subtitle}</span>}
    </div>
    <div className="actions">
      {actions.map((a, i) => (
        <button key={i} className="icon-btn" onClick={a.onClick} aria-label={a.label}>
          <Icon name={a.icon} />
        </button>
      ))}
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────
const BottomNav = ({ current, onChange }) => {
  const items = [
    { key: "library",  icon: "book-open",   label: "金库" },
    { key: "display",  icon: "sparkles",    label: "屏保" },
    { key: "widget",   icon: "layout-grid", label: "组件" },
    { key: "settings", icon: "settings",    label: "设置" },
  ];
  return (
    <div className="bottom-nav">
      {items.map(it => (
        <button
          key={it.key}
          className={"nav-item" + (current === it.key ? " active" : "")}
          onClick={() => onChange(it.key)}
        >
          <Icon name={it.icon} size={22} />
          <span>{it.label}</span>
        </button>
      ))}
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// Quote card
// ─────────────────────────────────────────────────────────────
const QuoteCard = ({ quote, source, date, variant = "default", onClick }) => (
  <div className={"quote-card" + (variant === "dark" ? " dark" : "")} onClick={onClick}>
    <div className="q">{quote}</div>
    <div className="qmeta">
      <span>{source && <em>{source}</em>}</span>
      <span>{date}</span>
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// Setting row
// ─────────────────────────────────────────────────────────────
const SettingRow = ({ label, sub, value, toggle, onToggle, chev = true, onClick }) => (
  <div className="setting-row" onClick={onClick}>
    <div className="lead">
      <div className="lbl">{label}</div>
      {sub && <div className="sub">{sub}</div>}
    </div>
    {value && <span className="val">{value}</span>}
    {toggle !== undefined && (
      <div className={"toggle" + (toggle ? " on" : "")} onClick={(e) => { e.stopPropagation(); onToggle && onToggle(!toggle); }}>
        <div className="dot" />
      </div>
    )}
    {chev && toggle === undefined && <Icon name="chevron-right" size={14} style={{ opacity: 0.4 }} className="chev" />}
  </div>
);

const SettingsGroup = ({ children }) => <div className="settings-group">{children}</div>;

// ─────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────
const SectionH = ({ children, count }) => (
  <div className="section-h">
    <span>{children}</span>
    {count !== undefined && <span className="ct">{count} 句</span>}
  </div>
);

// ─────────────────────────────────────────────────────────────
// Floating action button
// ─────────────────────────────────────────────────────────────
const Fab = ({ icon = "plus", onClick }) => (
  <button className="fab" onClick={onClick} aria-label="add">
    <Icon name={icon} size={22} />
  </button>
);

Object.assign(window, {
  Icon, Phone, StatusBar, GestureBar,
  TopBar, BottomNav, QuoteCard,
  SettingRow, SettingsGroup, SectionH, Fab,
  THEMES, themeByKey, nextTheme,
});
