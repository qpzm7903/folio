// 小金库 — Top-level app shell

const App = () => (
  <div style={{
    minHeight: "100vh",
    padding: "60px 40px 80px",
    display: "flex",
    gap: 56,
    justifyContent: "center",
    alignItems: "flex-start",
    flexWrap: "wrap",
    background: "var(--paper-100)",
    backgroundImage: "url(../../assets/paper-grain.svg)",
    backgroundSize: "240px 240px",
  }}>
    <PhoneApp initialTheme="paper"    initialScreen="display" label="青纸 · 首页（首页 / 金库 / 我的）" />
    <PhoneApp initialTheme="dai"      initialScreen="library" label="青黛 · Ink Indigo" />
  </div>
);

const PhoneApp = ({ initialTheme = "paper", initialScreen = "library", label }) => {
  const [theme, setTheme]     = React.useState(initialTheme);
  const [screen, setScreen]   = React.useState(initialScreen);
  const [sheetOpen, setSheetOpen] = React.useState(false);
  const [quotes, setQuotes]   = React.useState(SEED_QUOTES);
  const [tags, setTags]       = React.useState(TAGS);

  const onSave = (q, src) => {
    const tag = src || "未分类";
    setQuotes(qs => [{ id: Date.now(), q, tag, src: "—", date: "刚刚" }, ...qs]);
    setTags(ts => ts.includes(tag) ? ts : [...ts, tag]);
  };
  const onImport = (lines) => {
    setQuotes(qs => [
      ...lines.map((l, i) => ({ id: Date.now() + i, q: l, tag: "导入", src: "—", date: "刚刚" })),
      ...qs,
    ]);
    setTags(ts => ts.includes("导入") ? ts : [...ts, "导入"]);
  };
  // Batch remove quotes by id
  const onDeleteQuotes = (ids) => {
    const kill = new Set(ids);
    setQuotes(qs => qs.filter(q => !kill.has(q.id)));
  };
  // Remove a tag: its quotes fall back to 未分类
  const onDeleteTag = (t) => {
    setQuotes(qs => qs.map(q => q.tag === t ? { ...q, tag: "未分类" } : q));
    setTags(ts => ts.filter(x => x !== t));
  };

  return (
    <Phone theme={theme} label={label}>
      <div style={{
        position: "relative", display: "flex", flexDirection: "column",
        flex: 1, overflow: "hidden",
      }}>
        {screen === "library"  && <LibraryScreen      go={setScreen} openSheet={() => setSheetOpen(true)} quotes={quotes} tags={tags} onDeleteQuotes={onDeleteQuotes} onDeleteTag={onDeleteTag} />}
        {screen === "editor"   && <EditorScreen       go={setScreen} onSave={onSave} openSheet={() => setSheetOpen(true)} />}
        {screen === "display"  && <DisplayScreen      go={setScreen} quotes={quotes} />}
        {screen === "widget"   && <WidgetEditorScreen go={setScreen} theme={theme} onTheme={setTheme} quotes={quotes} />}
        {screen === "settings" && <SettingsScreen     go={setScreen} theme={theme} onTheme={setTheme} />}
        <ImportSheet open={sheetOpen} onClose={() => setSheetOpen(false)} onImport={onImport} />
      </div>
    </Phone>
  );
};

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
