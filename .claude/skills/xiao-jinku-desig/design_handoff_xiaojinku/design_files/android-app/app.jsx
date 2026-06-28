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

  const onSave = (q, tagsArg) => {
    const list = (Array.isArray(tagsArg) ? tagsArg : [tagsArg]).filter(Boolean);
    const tags = list.length ? list : ["未分类"];
    setQuotes(qs => [{ id: Date.now(), q, tags, src: "—", date: "刚刚" }, ...qs]);
    setTags(ts => { const add = tags.filter(t => !ts.includes(t)); return add.length ? [...ts, ...add] : ts; });
  };
  const onImport = (lines) => {
    setQuotes(qs => [
      ...lines.map((l, i) => ({ id: Date.now() + i, q: l, tags: ["导入"], src: "—", date: "刚刚" })),
      ...qs,
    ]);
    setTags(ts => ts.includes("导入") ? ts : [...ts, "导入"]);
  };
  // Batch remove quotes by id
  const onDeleteQuotes = (ids) => {
    const kill = new Set(ids);
    setQuotes(qs => qs.filter(q => !kill.has(q.id)));
  };
  // Strip a set of tags from a quote; fall back to 未分类 if it becomes tagless
  const stripTags = (q, kill) => {
    const cur = Array.isArray(q.tags) ? q.tags : (q.tag ? [q.tag] : []);
    const kept = cur.filter(t => !kill.has(t));
    return { ...q, tags: kept.length ? kept : ["未分类"], tag: undefined };
  };
  // Remove a single tag from all quotes
  const onDeleteTag = (t) => {
    const kill = new Set([t]);
    setQuotes(qs => qs.map(q => stripTags(q, kill)));
    setTags(ts => ts.filter(x => x !== t));
  };
  // Add a tag
  const onAddTag = (t) => setTags(ts => ts.includes(t) ? ts : [...ts, t]);
  // Batch remove tags
  const onDeleteTags = (listArg) => {
    const kill = new Set(listArg);
    setQuotes(qs => qs.map(q => stripTags(q, kill)));
    setTags(ts => {
      const kept = ts.filter(x => !kill.has(x));
      return kept.includes("未分类") ? kept : [...kept, "未分类"];
    });
  };

  return (
    <Phone theme={theme} label={label}>
      <div style={{
        position: "relative", display: "flex", flexDirection: "column",
        flex: 1, overflow: "hidden",
      }}>
        {screen === "library"  && <LibraryScreen      go={setScreen} openSheet={() => setSheetOpen(true)} quotes={quotes} tags={tags} onDeleteQuotes={onDeleteQuotes} onDeleteTag={onDeleteTag} onAddTag={onAddTag} onDeleteTags={onDeleteTags} />}
        {screen === "editor"   && <EditorScreen       go={setScreen} onSave={onSave} openSheet={() => setSheetOpen(true)} tags={tags} onAddTag={onAddTag} />}
        {screen === "display"  && <DisplayScreen      go={setScreen} quotes={quotes} />}
        {screen === "widget"   && <WidgetEditorScreen go={setScreen} theme={theme} onTheme={setTheme} quotes={quotes} />}
        {screen === "settings" && <SettingsScreen     go={setScreen} theme={theme} onTheme={setTheme} />}
        <ImportSheet open={sheetOpen} onClose={() => setSheetOpen(false)} onImport={onImport} />
      </div>
    </Phone>
  );
};

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
