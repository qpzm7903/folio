// 小金库 — Screens (Home/Library/Editor/Settings/Widget editor/Import sheet)

// ─────────────────────────────────────────────────────────────
// REAL CORPUS — provided by user
// ─────────────────────────────────────────────────────────────
const SEED_QUOTES = [
  { id: 1,  q: "你在心里种下的种子，时间会帮它找出口。",                                src: "—", tag: "坚持与回响",   date: "5月 20日" },
  { id: 2,  q: "所有的执着，最终都会以你意想不到的方式，轻轻拥抱你。",                  src: "—", tag: "坚持与回响",   date: "5月 19日" },
  { id: 3,  q: "真正的强大不是没有裂痕，而是光从裂痕里照进来。",                        src: "—", tag: "完整而非完美", date: "5月 18日" },
  { id: 4,  q: "你不必完美，你只需要真实且完整地活着。",                                src: "—", tag: "完整而非完美", date: "5月 17日" },
  { id: 5,  q: "允许自己有时候走得慢，有时候想回头，这才是完整的人。",                  src: "—", tag: "完整而非完美", date: "5月 16日" },
  { id: 6,  q: "走得慢的人，只要不丢失目标，也比漫无目的奔跑的人更早到达。",            src: "—", tag: "旅程与抵达",   date: "5月 12日" },
  { id: 7,  q: "不必急着去对岸，此刻的波浪也是风景。",                                  src: "—", tag: "旅程与抵达",   date: "5月 10日" },
  { id: 8,  q: "人生不是冲刺，是一场深呼吸就能继续的远行。",                            src: "—", tag: "旅程与抵达",   date: "5月 8日" },
  { id: 9,  q: "你不需要成为别人，你只需要成为自己，一个不断在完整中的自己。",          src: "—", tag: "自我接纳",     date: "5月 5日" },
  { id: 10, q: "接纳自己的阴影，才能拥抱真正的光明。",                                  src: "—", tag: "自我接纳",     date: "5月 3日" },
];

const TAGS = ["全部", "坚持与回响", "完整而非完美", "旅程与抵达", "自我接纳"];

// ─────────────────────────────────────────────────────────────
// Fisher-Yates shuffle (returns NEW array)
// ─────────────────────────────────────────────────────────────
const shuffleArr = (arr) => {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
};

// "No-repeat shuffle" hook: every round visits every item exactly once,
// then re-shuffles. Returns { current, next, round, posInRound, totalInRound }.
const useNoRepeatShuffle = (items) => {
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

  return { current, next, round, posInRound: pos + 1, totalInRound: safeOrder.length };
};

// ─────────────────────────────────────────────────────────────
// Confirm dialog — small centered sheet
// ─────────────────────────────────────────────────────────────
const ConfirmDialog = ({ open, title, body, confirmLabel = "删除", danger = true, onConfirm, onCancel }) => {
  if (!open) return null;
  return (
    <div className="confirm-scrim" onClick={onCancel}>
      <div className="confirm-box" onClick={e => e.stopPropagation()}>
        <div className="confirm-title">{title}</div>
        {body && <div className="confirm-body">{body}</div>}
        <div className="confirm-actions">
          <button className="btn ghost" onClick={onCancel}>取消</button>
          <button className={"btn" + (danger ? " danger" : "")} onClick={onConfirm}>{confirmLabel}</button>
        </div>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// LIBRARY
// ─────────────────────────────────────────────────────────────
const LibraryScreen = ({ go, openSheet, quotes, tags, onDeleteQuotes, onDeleteTag }) => {
  const [tag, setTag] = React.useState("全部");
  const [selecting, setSelecting] = React.useState(false);
  const [picked, setPicked] = React.useState(() => new Set());
  const [managingTags, setManagingTags] = React.useState(false);
  const [confirm, setConfirm] = React.useState(null); // {type, ...}

  // Reset selection when leaving select mode or changing filter
  React.useEffect(() => { if (!selecting) setPicked(new Set()); }, [selecting]);

  const filtered = tag === "全部" ? quotes : quotes.filter(q => q.tag === tag);
  // In select mode the "today" card is folded into the list so everything is selectable
  const today = !selecting ? (filtered[0] || quotes[0]) : null;
  const rest = today ? filtered.filter(q => q.id !== today.id) : filtered;

  const togglePick = (id) => setPicked(p => {
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
    return (
      <React.Fragment>
        <div className="topbar select-bar">
          <button className="icon-btn" onClick={() => setSelecting(false)} aria-label="cancel"><Icon name="x" /></button>
          <span className="select-count">{picked.size > 0 ? `已选 ${picked.size} 句` : "选择金句"}</span>
          <button className="text-btn" onClick={toggleAll}>{allPicked ? "取消全选" : "全选"}</button>
        </div>
        <div className="content">
          {rest.map(q => (
            <QuoteCard key={q.id} quote={q.q} source={q.tag} date={q.date}
              selectable selected={picked.has(q.id)} onToggle={() => togglePick(q.id)} />
          ))}
          {rest.length === 0 && <div className="empty-note">这个标签下还没有金句。</div>}
          <div style={{ height: 90 }} />
        </div>
        <div className="action-bar">
          <button className="btn danger block" disabled={picked.size === 0}
            style={{ opacity: picked.size === 0 ? 0.4 : 1 }}
            onClick={() => setConfirm({ type: "quotes" })}>
            <Icon name="trash-2" size={18} /> 取出 {picked.size > 0 ? picked.size : ""} 句
          </button>
        </div>
        <ConfirmDialog
          open={confirm?.type === "quotes"}
          title={`从金库取出这 ${picked.size} 句？`}
          body="取出后将不再出现在首页和组件里。"
          confirmLabel="取出"
          onConfirm={doDeleteQuotes}
          onCancel={() => setConfirm(null)}
        />
      </React.Fragment>
    );
  }

  // ── Normal header ──
  return (
    <React.Fragment>
      <TopBar
        title="小金库"
        subtitle="est. 2026"
        actions={[
          { icon: "search", label: "搜索" },
          { icon: "check-square", label: "多选", onClick: () => setSelecting(true) },
        ]}
      />
      <div className="content">
        <div className="hero"><div className="hi">今天的金句</div></div>
        {today && (
          <QuoteCard variant="dark" quote={today.q} source={today.tag} date={today.date} onClick={() => go("display")} />
        )}

        <div className="section-h" style={{ marginTop: 24 }}>
          <span>你的金库</span>
          <span className="ct">{quotes.length} 句</span>
        </div>

        <div className="tag-row">
          {tags.map(t => {
            const removable = managingTags && t !== "全部";
            return (
              <span key={t} className={"tag" + (t === tag ? " active" : "") + (removable ? " removable" : "")}
                onClick={() => removable ? setConfirm({ type: "tag", tag: t }) : setTag(t)}>
                {t}
                {removable && <span className="tag-x"><Icon name="x" size={12} /></span>}
              </span>
            );
          })}
          <span className="tag manage-tag" onClick={() => setManagingTags(m => !m)}>
            <Icon name={managingTags ? "check" : "pencil"} size={12} />
            {managingTags ? " 完成" : " 管理"}
          </span>
        </div>

        {rest.map(q => (
          <QuoteCard key={q.id} quote={q.q} source={q.tag} date={q.date} />
        ))}
        <div style={{ height: 80 }} />
      </div>
      <Fab onClick={() => go("editor")} />
      <BottomNav current="library" onChange={go} />

      <ConfirmDialog
        open={confirm?.type === "tag"}
        title={`删除标签「${confirm?.tag}」？`}
        body="标签下的金句会移到「未分类」，不会被删除。"
        confirmLabel="删除标签"
        onConfirm={() => { onDeleteTag(confirm.tag); if (tag === confirm.tag) setTag("全部"); setConfirm(null); }}
        onCancel={() => setConfirm(null)}
      />
    </React.Fragment>
  );
};

// ─────────────────────────────────────────────────────────────
// EDITOR
// ─────────────────────────────────────────────────────────────
const EditorScreen = ({ go, onSave, openSheet }) => {
  const [text, setText] = React.useState("");
  const [src, setSrc] = React.useState("");
  const canSave = text.trim().length > 0;
  return (
    <React.Fragment>
      <TopBar
        title="新的一句"
        actions={[
          { icon: "upload", label: "批量导入", onClick: openSheet },
          { icon: "x",      label: "关闭",     onClick: () => go("library") },
        ]}
      />
      <div className="content" style={{ display: "flex", flexDirection: "column" }}>
        <div className="composer">
          <textarea placeholder="写下一句你最近读到的话…" value={text} onChange={e => setText(e.target.value)} autoFocus />
          <div className="footer-tools">
            <input className="src-input" placeholder="— 出处 / 标签（可留空）" value={src} onChange={e => setSrc(e.target.value)} />
            <button className="icon-btn" aria-label="image"><Icon name="image" /></button>
          </div>
          <button
            className="btn block"
            disabled={!canSave}
            onClick={() => { onSave(text, src); go("library"); }}
            style={{ opacity: canSave ? 1 : 0.4, marginTop: 12 }}
          >收入金库</button>
        </div>
      </div>
    </React.Fragment>
  );
};

// ─────────────────────────────────────────────────────────────
// 首页 HOME — full-screen, no-repeat shuffle, switchable layouts
// ─────────────────────────────────────────────────────────────
const DisplayScreen = ({ go, quotes }) => {
  const [withPhoto, setWithPhoto] = React.useState(false);
  const [layoutIdx, setLayoutIdx] = React.useState(0);
  const { current, next } = useNoRepeatShuffle(quotes);
  const [fadeKey, setFadeKey] = React.useState(0);
  const advance = () => { next(); setFadeKey(k => k + 1); };

  const layout = LAYOUTS[layoutIdx];
  const LayoutComp = LAYOUT_COMPONENTS[layout.key];

  return (
    <div className="display-screen">
      {withPhoto && (
        <div className="display-bg protect" style={{
          background: "linear-gradient(135deg, #5e7263 0%, #324638 60%, #1d2a1f 100%)",
        }} />
      )}
      <div className="grain" />

      {/* Layout name — appears top-right, fades after 1.5s */}
      <div className={"layout-pip" + (withPhoto ? " on-photo" : "")} key={"pip-" + layoutIdx}>
        {layout.label} · <em>{layout.name}</em>
      </div>

      <div className={"display-content layout-host" + (withPhoto ? " on-photo" : "")} key={fadeKey + "-" + layoutIdx}>
        <LayoutComp quote={current} />
      </div>

      <div className="display-controls" style={{ bottom: 84 }}>
        <button className="dctl" onClick={advance} aria-label="next"><Icon name="shuffle" /></button>
        <button className="dctl" onClick={() => setLayoutIdx(i => (i + 1) % LAYOUTS.length)} aria-label="layout">
          <span className="layout-glyph">{layout.label}</span>
        </button>
        <button className="dctl" onClick={() => setWithPhoto(p => !p)} aria-label="photo"><Icon name="image" /></button>
        <button className="dctl" aria-label="save"><Icon name="bookmark" /></button>
      </div>

      <BottomNav current="display" onChange={go} />
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────
const SettingsScreen = ({ go, theme, onTheme }) => {
  const [cadence] = React.useState("30 分钟");
  const [shuffle, setShuffle]   = React.useState(true);
  const [showSrc, setShowSrc]   = React.useState(true);
  return (
    <React.Fragment>
      <TopBar title="我的" subtitle="profile" />
      <div className="content">
        <div className="section-h">小组件</div>
        <SettingsGroup>
          <SettingRow label="自定义小组件" sub="尺寸、频率、来源、字号" chev onClick={() => go("widget")} />
          <SettingRow label="更换频率" sub="一句话停留多久" value={cadence} chev />
          <SettingRow label="不重复轮播" sub="所有句子轮过一次才再出现" toggle={shuffle} onToggle={setShuffle} chev={false} />
          <SettingRow label="显示出处" sub="quote attribution" toggle={showSrc} onToggle={setShowSrc} chev={false} />
          <SettingRow label="背景图片" sub="选择壁纸或相册" value="纸纹理 · 2" chev />
        </SettingsGroup>

        <div className="section-h">字体与外观</div>
        <SettingsGroup>
          <SettingRow label="主题" value={themeByKey(theme).name + " · " + themeByKey(theme).en} chev onClick={() => onTheme(nextTheme(theme))} />
          <SettingRow label="字号" value="标准" chev />
          <SettingRow label="字体" value="思源宋体" chev />
        </SettingsGroup>

        <div className="section-h">导入与导出</div>
        <SettingsGroup>
          <SettingRow label="批量导入" sub="粘贴大段文字，自动分行" chev />
          <SettingRow label="导出金库" sub="备份为 .txt" chev />
          <SettingRow label="从备忘录导入" chev />
        </SettingsGroup>

        <div className="section-h">关于</div>
        <SettingsGroup>
          <SettingRow label="小金库" sub="一句话停一停" chev />
          <SettingRow label="给作者写一句" chev />
        </SettingsGroup>
        <div style={{
          height: 40, textAlign: "center",
          fontFamily: "var(--serif-italic)", fontStyle: "italic",
          fontSize: 12, color: "var(--fg-muted)", padding: "20px 0",
        }}>v 0.1 · 共 {SEED_QUOTES.length} 句已入库</div>
      </div>
      <BottomNav current="settings" onChange={go} />
    </React.Fragment>
  );
};

// ─────────────────────────────────────────────────────────────
// IMPORT SHEET
// ─────────────────────────────────────────────────────────────
const ImportSheet = ({ open, onClose, onImport }) => {
  const [text, setText] = React.useState("");
  if (!open) return null;
  const lines = text.split(/\n+/).map(l => l.trim()).filter(Boolean);
  return (
    <div className="sheet" onClick={onClose}>
      <div className="sheet-inner" onClick={e => e.stopPropagation()}>
        <div className="sheet-grabber" />
        <h2>批量导入</h2>
        <div className="sheet-help">把一整段话粘进来，会自动分行。</div>
        <textarea
          autoFocus
          placeholder={"你在心里种下的种子，时间会帮它找出口。\n真正的强大不是没有裂痕，而是光从裂痕里照进来。\n你不必完美，你只需要真实且完整地活着。"}
          value={text}
          onChange={e => setText(e.target.value)}
        />
        <div className="count-line">
          <span>识别到</span>
          <span><span className="n">{lines.length}</span> 句</span>
        </div>
        <button
          className="btn block"
          onClick={() => { onImport(lines); onClose(); }}
          disabled={lines.length === 0}
          style={{ opacity: lines.length === 0 ? 0.4 : 1 }}
        >全部收入金库</button>
      </div>
    </div>
  );
};

Object.assign(window, {
  SEED_QUOTES, TAGS, shuffleArr, useNoRepeatShuffle, ConfirmDialog,
  LibraryScreen, EditorScreen, DisplayScreen, SettingsScreen, ImportSheet,
});
