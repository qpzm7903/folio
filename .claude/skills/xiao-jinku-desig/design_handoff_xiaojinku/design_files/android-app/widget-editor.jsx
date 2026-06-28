// 小金库 — Widget editor screen. Live preview + all controls.

const WIDGET_SIZES = [
  { key: "small",  label: "小",  pretty: "1×1" },
  { key: "medium", label: "中",  pretty: "2×1" },
  { key: "large",  label: "大",  pretty: "2×2" },
  { key: "xlarge", label: "巨",  pretty: "4×4" },
];
const CADENCES = [
  { key: 5,    label: "5 分钟" },
  { key: 15,   label: "15 分钟" },
  { key: 30,   label: "30 分钟" },
  { key: 60,   label: "1 小时" },
  { key: 240,  label: "4 小时" },
  { key: 1440, label: "每日一句" },
];
const TEXT_SCALES = [
  { key: "small",  label: "小" },
  { key: "normal", label: "标准" },
  { key: "large",  label: "大" },
];
const BG_OPTIONS = [
  { key: "paper", label: "纸面" },
  { key: "white", label: "留白" },
  { key: "rice",  label: "米白" },
  { key: "paperwhite", label: "纸白" },
  { key: "ink",   label: "墨色" },
  { key: "leaf",  label: "色彩" },
  { key: "photo", label: "照片", disabled: true, note: "未上传" },
];

// ─────── In-preview widget (size-aware) ───────
const PreviewWidget = ({ size, quote, theme, textScale, showSource, bg, cardOpacity = 1 }) => {
  const sizeMap = {
    small:  { w: 160, h: 160, qSize: 14, line: 1.6, lineClamp: 5 },
    medium: { w: 320, h: 156, qSize: 16, line: 1.65, lineClamp: 4 },
    large:  { w: 320, h: 320, qSize: 19, line: 1.8, lineClamp: 6 },
    xlarge: { w: 340, h: 340, qSize: 22, line: 1.85, lineClamp: 9 },
  };
  const tsBoost = textScale === "large" ? 2 : textScale === "small" ? -2 : 0;
  const s = sizeMap[size];

  // Background fills — theme-aware via CSS vars
  const bgStyle = (() => {
    if (bg === "paper")      return { background: "var(--bg-raised)", color: "var(--fg-1)" };
    if (bg === "white")      return { background: "#ffffff", color: "#1f1d1a" };
    if (bg === "rice")       return { background: "#f3ecda", color: "#2a2620" };
    if (bg === "paperwhite") return { background: "#f7f6f1", color: "#26241f" };
    if (bg === "ink")   return { background: "var(--ink-900)",   color: "var(--bg-page)" };
    if (bg === "leaf")  return {
      background: "linear-gradient(155deg, var(--accent-soft) 0%, var(--accent) 55%, var(--accent-pressed) 100%)",
      color: "var(--fg-on-accent)",
    };
    if (bg === "photo") return {
      background: "linear-gradient(135deg, var(--ink-500), var(--ink-900))",
      color: "#fff",
    };
    return {};
  })();

  return (
    <div
      className="pv-widget"
      style={{
        width: s.w, height: s.h,
        borderRadius: 28,
        padding: size === "large" || size === "xlarge" ? 24 : 18,
        boxShadow: "0 10px 28px rgba(28,26,23,0.18)",
        display: "flex", flexDirection: "column", justifyContent: "space-between",
        fontFamily: "var(--serif-display)",
        overflow: "hidden",
        position: "relative",
        color: bgStyle.color,
      }}
    >
      {/* Background layer — opacity-adjustable so the home screen shows through */}
      <div style={{
        position: "absolute", inset: 0, zIndex: 0,
        background: bgStyle.background,
        opacity: cardOpacity,
      }} />
      <div style={{ position: "relative", zIndex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between", height: "100%" }}>
      {(size === "large" || size === "xlarge") && (
        <div style={{
          fontFamily: "var(--sans-ui)", fontSize: 11, letterSpacing: "0.04em",
          opacity: 0.6,
        }}>小金库 · <em style={{ fontFamily: "var(--serif-italic)", fontStyle: "italic" }}>Folio</em></div>
      )}

      <div style={{
        fontSize: s.qSize + tsBoost,
        lineHeight: s.line,
        flex: 1,
        display: "-webkit-box",
        WebkitLineClamp: s.lineClamp,
        WebkitBoxOrient: "vertical",
        overflow: "hidden",
        alignItems: "center",
      }}>{quote.q}</div>

      {showSource && (
        <div style={{
          fontFamily: "var(--serif-italic)", fontStyle: "italic",
          fontSize: size === "small" ? 11 : 12,
          opacity: 0.55,
          marginTop: size === "small" ? 6 : 8,
        }}>— {(quote.tags && quote.tags[0]) || quote.tag}</div>
      )}
      </div>
    </div>
  );
};

// ─────── Segmented control ───────
const Seg = ({ value, options, onChange }) => (
  <div className="seg">
    {options.map(o => (
      <button
        key={o.key}
        className={"seg-btn" + (value === o.key ? " active" : "") + (o.disabled ? " disabled" : "")}
        onClick={() => !o.disabled && onChange(o.key)}
        disabled={o.disabled}
      >
        {o.label}
        {o.pretty && <span className="seg-sub">{o.pretty}</span>}
        {o.note && <span className="seg-note">{o.note}</span>}
      </button>
    ))}
  </div>
);

// ─────── Chip row (multi-choice or single) ───────
const ChipRow = ({ value, options, onChange }) => (
  <div className="chip-row">
    {options.map(o => (
      <button
        key={o.key ?? o}
        className={"chip" + (value === (o.key ?? o) ? " active" : "")}
        onClick={() => onChange(o.key ?? o)}
      >{o.label ?? o}</button>
    ))}
  </div>
);

// ─────── Opacity slider ───────
const OpacitySlider = ({ value, onChange }) => (
  <div className="opacity-slider" style={{ display: "flex", alignItems: "center", gap: 12 }}>
    <input
      type="range" min={40} max={100} step={5}
      value={Math.round(value * 100)}
      onChange={e => onChange(Number(e.target.value) / 100)}
      style={{ flex: 1, accentColor: "var(--ink-900)", height: 4 }}
    />
    <span style={{
      fontFamily: "var(--sans-ui)", fontSize: 13, fontVariantNumeric: "tabular-nums",
      color: "var(--fg-2)", minWidth: 40, textAlign: "right",
    }}>{Math.round(value * 100)}%</span>
  </div>
);

// ─────── Widget editor screen ───────
const WidgetEditorScreen = ({ go, theme, onTheme, quotes }) => {
  const [size,       setSize]       = React.useState("medium");
  const [cadence,    setCadence]    = React.useState(30);
  const [source,     setSource]     = React.useState("全部");
  const [showSource, setShowSource] = React.useState(true);
  const [textScale,  setTextScale]  = React.useState("normal");
  const [bg,         setBg]         = React.useState("paper");
  const [cardOpacity, setCardOpacity] = React.useState(1);

  const filteredQuotes = source === "全部" ? quotes : quotes.filter(q => (Array.isArray(q.tags) ? q.tags : [q.tag]).includes(source));
  const previewQ = filteredQuotes[0] || quotes[0];

  return (
    <React.Fragment>
      <TopBar
        title="自定义小组件"
        subtitle="widget"
        actions={[{ icon: "x", label: "关闭", onClick: () => go("settings") }]}
      />
      <div className="content">
        {/* Live preview — clean, just the widget */}
        <div className="we-preview-stage">
          <div className="we-preview-inner">
            <PreviewWidget
              size={size} quote={previewQ} theme={theme}
              textScale={textScale} showSource={showSource} bg={bg}
              cardOpacity={cardOpacity}
            />
          </div>
        </div>

        <div className="section-h">尺寸</div>
        <Seg value={size}      options={WIDGET_SIZES} onChange={setSize} />

        <div className="section-h">字号</div>
        <Seg value={textScale} options={TEXT_SCALES}   onChange={setTextScale} />

        <div className="section-h">更换频率</div>
        <ChipRow value={cadence} options={CADENCES} onChange={setCadence} />

        <div className="section-h">来自哪个标签</div>
        <ChipRow value={source} options={TAGS} onChange={setSource} />

        <div className="section-h">背景</div>
        <ChipRow value={bg} options={BG_OPTIONS} onChange={setBg} />

        <div className="section-h">卡片不透明度</div>
        <OpacitySlider value={cardOpacity} onChange={setCardOpacity} />

        <div className="settings-group" style={{ marginTop: 16 }}>
          <SettingRow label="显示出处" sub="show attribution" toggle={showSource} onToggle={setShowSource} chev={false} />
          <SettingRow label="不重复轮播" sub="所有句子轮过一次才再出现" toggle={true} onToggle={() => {}} chev={false} />
        </div>

        <button className="btn block" style={{ marginTop: 20 }} onClick={() => go("library")}>添加到主屏</button>
        <div style={{
          marginTop: 12, textAlign: "center",
          fontFamily: "var(--serif-italic)", fontStyle: "italic",
          fontSize: 12, color: "var(--fg-muted)",
        }}>当前筛选 · {filteredQuotes.length} 句可用 · 每 {CADENCES.find(c => c.key === cadence)?.label} 更换</div>
        <div style={{ height: 24 }} />
      </div>
      <BottomNav current="widget" onChange={go} />
    </React.Fragment>
  );
};

Object.assign(window, {
  WidgetEditorScreen, PreviewWidget, Seg, ChipRow, OpacitySlider,
  WIDGET_SIZES, CADENCES, TEXT_SCALES, BG_OPTIONS,
});
