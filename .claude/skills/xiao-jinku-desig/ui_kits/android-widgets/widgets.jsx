// Android widgets — small / medium / large

const WIDGET_QUOTES = [
  { q: "真正的强大不是没有裂痕，而是光从裂痕里照进来。", src: "完整而非完美" },
  { q: "你在心里种下的种子，时间会帮它找出口。",         src: "坚持与回响" },
  { q: "不必急着去对岸，此刻的波浪也是风景。",           src: "旅程与抵达" },
  { q: "接纳自己的阴影，才能拥抱真正的光明。",           src: "自我接纳" },
  { q: "人生不是冲刺，是一场深呼吸就能继续的远行。",     src: "旅程与抵达" },
];

const ICON_BASE = "https://unpkg.com/lucide-static@latest/icons/";

// A deliberately long quote to stress-test the multi-char case
const LONG_QUOTE = {
  q: "走得慢的人，只要不丢失目标，也会比那些漫无目的地四处奔跑的人更早抵达自己真正想去的地方。",
  src: "旅程与抵达",
};

// Small (1x1 cell — 76×76 in Android dp, scale up to 160×160 here)
const SmallWidget = ({ quote, theme = "paper" }) => (
  <div className={"w-small " + theme}>
    <div className="seal">金</div>
    <div className="q">{quote.q}</div>
  </div>
);

// Medium (2x1 cell — 320×160)
const MediumWidget = ({ quote, theme = "paper" }) => (
  <div className={"w-medium " + theme}>
    <div className="q">{quote.q}</div>
    <div className="row">
      <div className="src">— {quote.src}</div>
      <div className="seal">金</div>
    </div>
  </div>
);

// Large (2x2 cell — 320×320)
const LargeWidget = ({ quote, theme = "paper" }) => (
  <div className={"w-large " + theme}>
    <div className="seal-row">
      <div className="seal">金</div>
      <div className="brand">小金库 · <em>Folio</em></div>
    </div>
    <div className="q">{quote.q}</div>
    <div className="footer">
      <div className="src">— {quote.src}</div>
      <div className="next">
        <img src={ICON_BASE + "shuffle.svg"} alt="" />
      </div>
    </div>
  </div>
);

const WidgetRow = ({ theme, label }) => (
  <div className="row-wrap">
    <div className="row-label">{label}</div>
    <div className="row-tiles">
      <SmallWidget quote={WIDGET_QUOTES[0]} theme={theme} />
      <MediumWidget quote={WIDGET_QUOTES[1]} theme={theme} />
      <LargeWidget quote={WIDGET_QUOTES[2]} theme={theme} />
    </div>
  </div>
);

// ─────────────────────────────────────────────────────────────
// Resizable widget — the real Android behaviour: user long-presses,
// drags a corner handle, widget snaps to home-grid cells, and the
// CONTENT REFLOWS + the type AUTO-FITS to both box size AND length.
// ─────────────────────────────────────────────────────────────
const CELL = 78;   // one home-grid cell (px, scaled up for the kit)
const GAP  = 14;   // gutter between cells
const cellsToPx = (n) => n * CELL + (n - 1) * GAP;

// Fit font size to the box area divided by char count (CJK ≈ square glyphs),
// then clamp. Bigger box → bigger type; more chars → smaller type.
const fitFont = (w, h, chars, reserve) => {
  const innerW = w - 36;
  const innerH = h - 36 - reserve;
  const area = Math.max(0, innerW * innerH);
  const per = area / Math.max(chars, 1);
  return Math.max(12, Math.min(30, Math.sqrt(per) * 0.82));
};

const ResizableWidget = ({ quote, theme, cw, ch }) => {
  const w = cellsToPx(cw), h = cellsToPx(ch);
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

  return (
    <div className={"rz-widget " + theme} style={{ width: w, height: h }}>
      {showBrand && (
        <div className="rz-brand">
          <span className="rz-seal">金</span>
          <span>小金库 · <em>Folio</em></span>
        </div>
      )}
      <div className={"rz-qregion" + (golden ? " golden" : "")}>
        <div
          className="rz-quote"
          style={{
            fontSize: fs,
            lineHeight: 1.7,
            WebkitLineClamp: maxLines,
          }}
        >{quote.q}</div>
      </div>
      {showFooter && (
        <div className="rz-foot">
          <span className="rz-cat">{quote.src}</span>
          <img className="rz-shuffle" src={ICON_BASE + "shuffle.svg"} alt="" />
        </div>
      )}
      {showAttrInline && <div className="rz-attr">— {quote.src}</div>}
      {!showFooter && !showAttrInline && !showBrand && cw === 1 && ch === 1 && (
        <span className="rz-seal rz-seal-corner">金</span>
      )}
    </div>
  );
};

const ResizableDemo = () => {
  const [theme, setTheme] = React.useState("paper");
  const [longQuote, setLongQuote] = React.useState(false);
  const [size, setSize] = React.useState({ cw: 2, ch: 2 });
  const stageRef = React.useRef(null);
  const drag = React.useRef(null);

  const quote = longQuote ? LONG_QUOTE : WIDGET_QUOTES[0];

  const onHandleDown = (e) => {
    e.preventDefault();
    const startX = e.clientX, startY = e.clientY;
    drag.current = { startX, startY, cw: size.cw, ch: size.ch };
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp);
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const dx = e.clientX - drag.current.startX;
    const dy = e.clientY - drag.current.startY;
    const cw = Math.max(1, Math.min(4, drag.current.cw + Math.round(dx / (CELL + GAP))));
    const ch = Math.max(1, Math.min(4, drag.current.ch + Math.round(dy / (CELL + GAP))));
    setSize({ cw, ch });
  };
  const onUp = () => {
    drag.current = null;
    window.removeEventListener("pointermove", onMove);
    window.removeEventListener("pointerup", onUp);
  };

  return (
    <div className="rz-demo">
      <div className="rz-controls">
        <div className="rz-seg">
          <button className={"rz-seg-btn" + (theme === "paper" ? " on" : "")} onClick={() => setTheme("paper")}>青纸</button>
          <button className={"rz-seg-btn" + (theme === "night" ? " on" : "")} onClick={() => setTheme("night")}>林夜</button>
        </div>
        <div className="rz-seg">
          <button className={"rz-seg-btn" + (!longQuote ? " on" : "")} onClick={() => setLongQuote(false)}>短句</button>
          <button className={"rz-seg-btn" + (longQuote ? " on" : "")} onClick={() => setLongQuote(true)}>长句</button>
        </div>
        <div className="rz-presets">
          {[[1,1],[2,1],[2,2],[4,2],[4,4]].map(([cw,ch]) => (
            <button key={cw+"x"+ch}
              className={"rz-chip" + (size.cw===cw && size.ch===ch ? " on" : "")}
              onClick={() => setSize({ cw, ch })}>{cw}×{ch}</button>
          ))}
        </div>
      </div>

      <div className={"rz-stage " + theme} ref={stageRef}>
        <div className="rz-grid" />
        <div className="rz-holder" style={{ width: cellsToPx(size.cw), height: cellsToPx(size.ch) }}>
          <ResizableWidget quote={quote} theme={theme} cw={size.cw} ch={size.ch} />
          <div className="rz-handle" onPointerDown={onHandleDown} title="拖动缩放">
            <img src={ICON_BASE + "move-diagonal-2.svg"} alt="" />
          </div>
          <div className="rz-dim">{size.cw} × {size.ch}</div>
        </div>
      </div>
      <div className="rz-hint">拖右下角手柄缩放（贴合主屏网格），或点上方预设。组件随尺寸重排、字号随尺寸＋字数自适应。</div>
    </div>
  );
};

// Mock Android home screen to give widgets context
const HomeScreenContext = ({ theme = "paper" }) => {
  const isNight = theme === "night";
  return (
    <div className={"home-screen " + theme}>
      <div className="home-bg" />
      <div className="home-content">
        <div className="time-block">
          <div className="time">9:41</div>
          <div className="date">5月 14日 · 周三</div>
        </div>
        <div className="widget-stack">
          <LargeWidget quote={WIDGET_QUOTES[0]} theme={theme} />
          <div className="row-2">
            <SmallWidget quote={WIDGET_QUOTES[1]} theme={theme} />
            <SmallWidget quote={WIDGET_QUOTES[3]} theme={theme} />
          </div>
          <MediumWidget quote={WIDGET_QUOTES[4]} theme={theme} />
        </div>
        <div className="dock">
          {["phone","message-circle","camera","grid-2x2"].map(i => (
            <div key={i} className="app-tile"><img src={ICON_BASE + i + ".svg"} alt="" /></div>
          ))}
        </div>
      </div>
    </div>
  );
};

const App = () => (
  <div className="kit-frame">
    <div className="legend">
      <h1>小金库 · 小组件</h1>
      <p>三种尺寸目录、可拖动缩放的自适应组件、以及放上主屏的实际效果。组件随尺寸重排，字号随尺寸＋字数自适应。</p>
    </div>

    <h2 className="lane-h">尺寸目录 · Catalog</h2>
    <div className="catalog">
      <WidgetRow theme="paper" label="青纸 · Tea Paper" />
      <WidgetRow theme="night" label="林夜 · Forest Night" />
    </div>

    <h2 className="lane-h">可拖动缩放 · Resizable（多字自适应）</h2>
    <ResizableDemo />

    <h2 className="lane-h">放在主屏上 · In situ</h2>
    <div className="home-row">
      <HomeScreenContext theme="paper" />
      <HomeScreenContext theme="night" />
    </div>
  </div>
);

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
