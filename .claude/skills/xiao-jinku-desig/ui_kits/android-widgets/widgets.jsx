// Android widgets — small / medium / large

const WIDGET_QUOTES = [
  { q: "真正的强大不是没有裂痕，而是光从裂痕里照进来。", src: "完整而非完美" },
  { q: "你在心里种下的种子，时间会帮它找出口。",         src: "坚持与回响" },
  { q: "不必急着去对岸，此刻的波浪也是风景。",           src: "旅程与抵达" },
  { q: "接纳自己的阴影，才能拥抱真正的光明。",           src: "自我接纳" },
  { q: "人生不是冲刺，是一场深呼吸就能继续的远行。",     src: "旅程与抵达" },
];

const ICON_BASE = "https://unpkg.com/lucide-static@latest/icons/";

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
      <p>Three widget sizes, in both themes — first as a catalog, then in situ on a phone home screen.</p>
    </div>

    <h2 className="lane-h">尺寸目录 · Catalog</h2>
    <div className="catalog">
      <WidgetRow theme="paper" label="青纸 · Tea Paper" />
      <WidgetRow theme="night" label="林夜 · Forest Night" />
    </div>

    <h2 className="lane-h">放在主屏上 · In situ</h2>
    <div className="home-row">
      <HomeScreenContext theme="paper" />
      <HomeScreenContext theme="night" />
    </div>
  </div>
);

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
