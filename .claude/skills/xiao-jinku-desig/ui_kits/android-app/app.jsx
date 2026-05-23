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
    <PhoneApp initialTheme="paper" initialScreen="library" label="青纸 · Tea Paper" />
    <PhoneApp initialTheme="night" initialScreen="widget"  label="林夜 · Forest Night" />
  </div>
);

const PhoneApp = ({ initialTheme = "paper", initialScreen = "library", label }) => {
  const [theme, setTheme]     = React.useState(initialTheme);
  const [screen, setScreen]   = React.useState(initialScreen);
  const [sheetOpen, setSheetOpen] = React.useState(false);
  const [quotes, setQuotes]   = React.useState(SEED_QUOTES);

  const onSave = (q, src) => setQuotes(qs => [
    { id: Date.now(), q, tag: src || "未分类", src: "—", date: "刚刚" }, ...qs,
  ]);
  const onImport = (lines) => setQuotes(qs => [
    ...lines.map((l, i) => ({ id: Date.now() + i, q: l, tag: "导入", src: "—", date: "刚刚" })),
    ...qs,
  ]);

  return (
    <Phone theme={theme} label={label}>
      <div style={{
        position: "relative", display: "flex", flexDirection: "column",
        flex: 1, overflow: "hidden",
      }}>
        {screen === "library"  && <LibraryScreen      go={setScreen} openSheet={() => setSheetOpen(true)} quotes={quotes} />}
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
