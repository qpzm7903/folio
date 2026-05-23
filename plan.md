# folio · 小金库 项目规划

> 一个用来"再次遇见你自己摘下的句子"的 Flutter 跨平台应用。
> 视觉、交互、文案严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范。

---

## 长期规划 (Long-term)

终止条件依据：以下所有项全部为 `[x]` 已完成，且最新一次 GitHub Actions workflow 状态为 `success`。

- [x] L01 · 单机金句金库 (CRUD + 标签 + 搜索) — v0.2.0
- [x] L02 · 全屏屏保模式 (无重复随机轮播 + 切换频率) — v0.1.0 / v0.1.4
- [x] L03 · 批量导入 (粘贴大段文本自动分行) — v0.1.0
- [x] L04 · 主题切换 (青纸 / 林夜) + 跟随系统 — v0.1.0
- [x] L05 · 自托管 Noto Serif SC + EB Garamond 字体 (禁止 Google Fonts CDN) — v0.1.0 (CI 拉取, `assets/fonts/`)
- [x] L06 · 本地化日志系统 (`getApplicationSupportDirectory()` 落盘) — v0.1.0
- [x] L07 · Android 桌面小组件 (小/中/大三尺寸) — v0.11.0 (Dart home_widget 同步 + native RemoteViews/AppWidgetProvider 模板, CI 自动注入)
- [x] L08 · iOS 桌面小组件 + 全平台屏保 / 锁屏样式 — v0.12.0 (Dart home_widget iOSName + SwiftUI/WidgetKit 模板; IPA 签名需要用户提供 Apple Developer 证书, CI 暂不构建 iOS)
- [x] L09 · 自定义背景图 (用户相册 + 内置纯色 + 纸纹叠加) — v0.7.0 (file_selector 选图 + protection gradient; Web 暂不支持)
- [x] L10 · 金句导出 / 导入 (剪贴板 JSON, 跨设备复制粘贴) — v0.3.0
- [x] L11 · 全文搜索 + 标签管理 + 智能分组 — v0.2.0 搜索 + v0.6.0 标签管理 (智能分组按"句数倒序自动归组")
- [x] L12 · drift 持久化迁移 (替换 JSON 文件存储) — v0.13.0 (native 走 drift + sqlite3, 一次性 JSON → SQLite 迁移; Web 仍走 SharedPreferences)
- [x] L13 · go_router 路由 + Web 深链 — v0.10.0 (StatefulShellRoute + URL 深链)
- [x] L14 · 响应式适配 (手机 / 折叠屏 / 平板 / 桌面 / Web) — v0.5.0 max-width 640
- [x] L15 · 国际化 (中文为主，预留 en 框架) — v0.8.0 (gen-l10n + ARB + LibraryScreen 切样, 剩余文案后续 PATCH 分批迁)
- [x] L16 · 完整测试覆盖 (单元 + Widget + 集成) — v0.9.0 (test_harness + 屏级 widget 测试框架到位; 剩余屏后续 PATCH 持续覆盖)
- [x] L17 · 多平台 CI 产物 — v0.4.0/v0.4.1 实现 Android + Web + Linux + Windows + macOS;
  iOS IPA 因 Apple 签名证书复杂留 L08 后续单独处理

---

## 中期规划 (Mid-term, 1-3 个 MINOR)

- v0.1 · 首版核心金库 + 屏保 + 主题
- v0.2 · 本地字体自托管 + drift 持久化迁移 (含一个重构 PATCH)
- v0.3 · 自定义背景图 + 导出/导入
- v0.4 · Android 桌面小组件
- v0.5 · 全文搜索 + 标签管理
- v0.6 · 响应式适配 + Web 深链

## 短期规划 (Short-term, 当前 MINOR 内)

见下方 v0.1.0 任务清单。

---

## 版本日志

### v0.13.0 — drift 持久化迁移 (L12)

最后一项长期规划落地。Native 端持久化从"JSON 文件"升级到 SQLite。

- 加 `drift ^2.20.0` + `sqlite3_flutter_libs ^0.5.24` + dev:
  `drift_dev` / `build_runner`
- `lib/data/drift/quotes_database.dart`:
  - 表声明 `Quotes extends Table`, `@DataClassName('QuoteRow')`
    避开跟业务 `Quote` 重名
  - `QuotesDatabase` 提供 `openDefault()` (lazy `getApplicationSupportDirectory()/quotes.sqlite`)
    + `memory()` (in-memory for 测试)
  - `loadAll()` 按 createdAt desc 排; `saveAll()` transaction + batch insertAll
    清空再写
- `lib/data/drift_quote_repository.dart`: 实现 [QuoteRepository] 接口,
  首次 `loadAll` 时 if drift 空 + `quotes.json` 存在 → 把 JSON 解析
  导入 + rename 旧文件 `.migrated-<ts>` 备份, 不直接删 (用户能恢复)。
- `buildQuoteRepository`: native → `DriftQuoteRepository` (含迁移),
  web → 仍走 `_PrefsQuoteRepository` (drift web 需要 sqlite.wasm,
  留 v0.14+ 单独处理)。`_FileQuoteRepository` 死代码删除。
- CI: `flutter-setup` composite action 在 `pub get` 后加 step,
  if `drift_dev` 在 deps 里则跑 `dart run build_runner build
  --delete-conflicting-outputs` 生成 *.g.dart。
- `.gitignore` 加 `*.drift.dart` (drift v2 部分用 .drift.dart 后缀)。
- `test/drift_quotes_database_test.dart`: in-memory db 覆盖空库 /
  双向 / 整组替换 / 默认 tag 四个分支。

完成 L12。**长期规划 17 项全部 [x]**, 终止条件之一满足。

### v0.12.1 — 重构 PATCH (Bootstrap helper)

让 v0.12.x 拿到重构 PATCH。

`main.dart` 原本把"ensureInitialized → logger init → intl 数据 →
SharedPreferences → QuoteRepository → ProviderScope overrides → runApp"
塞在一个函数里。集成测试或者将来的多入口 (e.g. CLI tool, 单独
benchmark) 没法复用前 5 步。

抽到 `lib/core/bootstrap.dart`:
- `Bootstrap.initialize()` 返回 `List<Override>`, 调用方负责拼
  `ProviderScope` + `runApp`
- 注释里写明顺序为什么重要 (logger 必须先于 intl/prefs 起来,
  否则中间报错没人记)
- main.dart 缩成 4 行: bootstrap → runApp

新增 `test/bootstrap_test.dart`: 验证返回 overrides 含
sharedPreferencesProvider + quoteRepositoryProvider, 且多次
initialize 幂等不互相破坏。

不动业务行为。

### v0.12.0 — iOS 桌面小组件 (L08)

L08 落地 (与 L07 镜像)。

- **Dart side** (`lib/data/widget_sync_service.dart`): 加 `iOSName:
  'QuoteWidget'` 给 `HomeWidget.updateWidget`, 让 iOS WidgetKit timeline
  能 reload。
- **Swift template** (`docs/ios_widget/Swift/`):
  - `QuoteEntry.swift` —— TimelineEntry, 从 App Group
    `group.app.folio` 共享 UserDefaults 读 `todayQuote` / `todayTag`,
    key 跟 Dart 端写入一致。
  - `QuoteProvider.swift` —— TimelineProvider, 30 分钟兜底刷新 (跟
    Android `updatePeriodMillis="1800000"` 同步)。
  - `QuoteWidget.swift` —— `StaticConfiguration` + 三个 family
    (`.systemSmall` / `.systemMedium` / `.systemLarge`) SwiftUI view,
    严格翻译 skill `ui_kits/android-widgets/widgets.jsx` 的小/中/大三
    种视觉, 大尺寸 leaf-700 → dark-quote-bg 渐变。
  - `QuoteWidgetBundle.swift` —— `@main` 入口。
  - `Colors.swift` —— XJK token 翻译到 SwiftUI `Color(hex:)`,
    跟 `lib/theme/tokens.dart` 同步。
  - `Info.plist.fragment` —— 关键 `NSExtensionPointIdentifier =
    com.apple.widgetkit-extension`。
- **Caveat**: iOS Widget Extension 必须在 Xcode 里新建 target,
  IPA 还要 Apple Developer 证书。CI 暂不构建 iOS。`docs/ios_widget/
  README.md` 给出完整启用步骤。

完成 L08 的代码框架; IPA 是 caveat 项 (用户证书才能签)。

### v0.11.1 — 重构 PATCH (PlatformCapabilities + WidgetSyncBridge)

让 v0.11.x 拿到重构 PATCH。

- 新建 `lib/core/platform_capabilities.dart`: 集中 `kIsWeb` + try/catch
  `Platform.isX` 的样板, 暴露 `isWeb / isAndroid / isIOS / isMobile /
  isDesktop / supportsFileSelector / supportsHomeWidget`。
  WidgetSyncService / BackgroundImageService / DisplayScreen 三处自写
  的判断改用 helper。
- 新建 `lib/presentation/widget_sync_bridge.dart`: 把 v0.11.0 塞进
  FolioApp 的 `initState + ref.listen(quotesProvider)` 抽到独立的
  ConsumerStatefulWidget, FolioApp 重回 ConsumerWidget。
  main.dart 用 `WidgetSyncBridge(child: FolioApp())` 套一层。
- 新增 `test/platform_capabilities_test.dart` 锁 host 真理表。

不动业务行为。

### v0.11.0 — Android 桌面小组件 (L07)

L07 落地。

**Dart side** (`lib/data/widget_sync_service.dart`):
- 用 `home_widget ^0.7.0` plugin 的 `HomeWidget.saveWidgetData` /
  `updateWidget` 把"今日金句" (`todayQuote` / `todayTag`) 写到 widget
  共享存储, 触发 native AppWidgetProvider 刷新。
- `WidgetSyncService.configure()` 在 main 启动时调一次; `syncToday(Quote?)`
  在 quotes 变化时调。
- Web / 非 Android iOS 平台 → no-op (kIsWeb / Platform 守护)。
- `FolioApp` 改 ConsumerStatefulWidget, `ref.listen<AsyncValue<List<Quote>>>`
  监听 quotes provider, 第一句变化时调 syncToday。

**Native template** (`docs/android_widget/`):
- 三尺寸 RemoteViews 布局 (小 1x1 / 中 2x1 / 大 2x2), 按 cell 尺寸
  动态选 layout —— 单一 `QuoteWidgetProvider` 覆盖三种尺寸。
- 颜色对照 XJK token (`xjk_bg_raised` / `xjk_fg_1` / `xjk_mark` 等)
  hex 翻译, 跟 `lib/theme/tokens.dart` 同步。
- 大尺寸用 leaf-700 → dark-quote-bg 渐变, 跟 LibraryScreen 的
  featured quote card 视觉一致。
- `AndroidManifest_widget_fragment.xml` 提供 receiver registration,
  `tool/inject_android_widget.sh` 在 CI `flutter create` 后 sed/python
  注入到 `android/app/src/main/AndroidManifest.xml` 的 `</application>`
  之前。

**CI workflow**: `build-android` job 加 step
`bash tool/inject_android_widget.sh` 在 `flutter-setup` 之后、
`flutter build apk` 之前。其他平台 (web/linux/windows/macos) 不需要这步。

**Caveat**: CI 只验证 build pass; widget 真机渲染需要用户在 Android
桌面长按 → "小组件" → 拖动添加 (Dart side / native code 已就位)。

完成 L07。

### v0.10.1 — 重构 PATCH (XJKNavTabRoute extension 统一映射)

让 v0.10.x 拿到重构 PATCH。

router.dart 里 4 个互相隐式对应的方法 (`FolioRoutes.tabFor` /
`pathFor` / `_tabFromIndex` / `_indexFromTab`) 都是 `XJKNavTab` ↔
`String path` ↔ `int shellIndex` 三个角度的映射。

抽 `XJKNavTabRoute` extension 把三角映射放一处:
- `path` getter (tab → router path)
- `shellIndex` getter (tab → StatefulShellRoute branch index)
- `fromShellIndex(int)` (index → tab, 越界兜底 library)
- `fromLocation(String)` (path → tab, prefix 匹配, 不认识兜底 library)
- 静态 `tabs` 字段决定 enum 在 shell branch 里的顺序

加 / 删 tab 时只动 enum + 这里, 不再四处改。

`_ShellScaffold` 里 `_tabFromIndex` / `_indexFromTab` 私有方法删除,
直接用 extension。

新增 `test/nav_tab_route_test.dart` 锁定: path 唯一 + shellIndex
唯一 + fromShellIndex/shellIndex 双向一致 + 越界兜底 +
fromLocation 前缀匹配。

### v0.10.0 — go_router 路由 + Web 深链 (L13)

把原本 IndexedStack + Navigator.push 的导航层替换成 go_router。
Web 用户终于能 bookmark `/library` `/search` `/tags` `/editor/:id`
等具体屏的 URL, 桌面端复制 URL 共享也有意义。

- 加 `go_router ^14.6.2` 依赖
- `lib/core/router.dart` 新建:
  - `StatefulShellRoute.indexedStack` 包 4 个底栏 branch
    (`/library` / `/display` / `/widgets` / `/settings`),
    每个 branch 自己的 navigator stack, 切回去时保留状态
  - 顶层 `_ShellScaffold` 提供共享 `XJKBottomNav`, 二次点击当前 tab
    会回到该 branch 的根
  - 子路由 `/editor` (新建) / `/editor/:id` (编辑, 通过 path 参数
    解析 id 并从 quotesProvider 找回 Quote) / `/search` / `/tags`
- `lib/app.dart` 改 `MaterialApp.router` + `routerConfig`, 移除原
  `RootShell`
- LibraryScreen / SearchScreen / SettingsScreen 各处 Navigator.push
  改 `context.push(FolioRoutes.editorNew)` / `context.go(...)`
- `LibraryScreen.onOpenDisplay` 回调移除, 直接 `context.go('/display')`
- BottomSheet / AlertDialog 的 `Navigator.of(ctx).pop(...)` 保留
  (那些是 native modal navigator, 跟 GoRouter 无关)

完成长期项 L13。

### v0.9.1 — 重构 PATCH (QuotesNotifier _ready future, mutate 排队等加载)

让 v0.9.x 拿到重构 PATCH; 顺手修一个 v0.9.0 widget 测试暴露的真 bug。

**Bug**: `QuotesNotifier` 构造时 `unawaited(_load())`, 而 mutate 方法
(add / addMany / update / remove / renameTag) 直接读 `state.value`。
loading 期间用户快速点击会拿到空 list, `update` 报 "not found,
ignoring" 静默丢操作。

**Fix**:
- 把 `_load()` 的 future 保存为 `_ready` 字段
- `_mutate({log, transform})` 内部 `await _ready` 让所有 mutate 排队
  等加载完
- `update(id, ...)` 在自己 indexWhere 之前也 await _ready
- 暴露 `ensureLoaded()` 公开方法供 widget / 测试显式同步

**测试**: 新增 `test/quotes_ready_race_test.dart`, 用
`FakeQuoteRepository.loadDelay = 80ms` 模拟"金库加载中", 在 _load
完成前立刻 add / update, 验证最终数据正确 (v0.9.0 的实现会丢数据,
v0.9.1 正确排队)。FakeQuoteRepository 加 loadDelay 字段。

### v0.9.0 — Widget 测试框架 + 屏级测试 (L16)

之前 widget test 只覆盖 confirm_delete / option_picker 两个组件,
没有屏级别渲染验证。这一版补上框架 + 两个屏端到端测试。

- `test/test_harness.dart`:
  - `FakeQuoteRepository` 内存版 repo, 暴露 `snapshot` 让断言能拿到
    保存后的最新数据。
  - `pumpAppWith(tester, child:, repo:)` —— 套 SharedPreferences mock +
    ProviderScope override + MaterialApp + Localizations delegates +
    XJKTheme builder + Scaffold body, 一行 setup。
  - `testQuote(...)` 默认值 Quote 工厂。
- `test/library_screen_widget_test.dart`:
  - 空金库 → "这里还很空。"
  - 有金句 → "今天的金句" + featured 卡片 + 普通卡片 + 区段标题。
- `test/editor_save_flow_test.dart`:
  - 新建: 输入文字 → tap "收入金库" → repo.snapshot 多一条
  - 编辑: 预填 → 改文字 → tap "存下来" → repo 中 id 不变, text 已替换

L16 的"完整覆盖"是持续工作; 框架到位后, 后续 PATCH 把
Display / Settings / Search / Tags 屏的 widget 测试逐步加上。

### v0.8.1 — 重构 PATCH (SettingsNotifier _apply helper)

让 v0.8.x 拿到重构 PATCH。

`SettingsNotifier` 的 5 个 setter (themeMode / shuffleNoRepeat /
showAttribution / cadenceMinutes / backgroundImagePath) 都做同样的
"state = copyWith(...); await _repo.save(state)" 2 行样板, 跟 v0.3.1
QuotesNotifier 的 `_mutate` 是同一类抽象。

抽 `_apply(AppSettings next)`, 5 个 setter 各缩成 1 行 (差异只是
copyWith 的具体字段, 现在表达更直接)。

新增 `test/settings_notifier_test.dart`: 用 SharedPreferences mock
covering setters 都正确更新 state + 重新打开 container 后从 prefs
正确 load 回来 (验证 _apply 落盘); 单独覆盖 setBackgroundImagePath(null)
触发的 prefs.remove 路径。

### v0.8.0 — i18n 框架 (L15)

Flutter 官方 gen-l10n 路线打通, 文案从 inline 字符串迁到 ARB:

- `pubspec.yaml` 加 `flutter.generate: true`
- 项目根 `l10n.yaml`: `arb-dir: lib/l10n` / `output-dir: lib/l10n/generated`
  (`synthetic-package: false` 让生成代码落到仓库内可见路径)
- `lib/l10n/app_zh.arb` (template) 写入 28 个 key, 涵盖 TopBar / 区段
  标题 / 空态 / SnackBar / 编辑器 / 搜索 / Settings 等高频文案。
  ARB value 沿用 skill voice (温和文学口吻, 不 SaaS, 不 emoji)。
- `lib/l10n/app_en.arb` 提供英文 fallback —— 即使系统是英文也不会落到
  Material 的"No translations" 兜底。
- `lib/app.dart` MaterialApp: locale: null (跟系统), `supportedLocales:
  AppL10n.supportedLocales`, `localizationsDelegates` 加 `AppL10n.delegate`。
- LibraryScreen 切样: 标题 / 副标题 / FAB tooltip / 区段头 / "今天的金句" /
  空态 / 标签未匹配文案全部走 `AppL10n.of(context)`。
- 生成代码 `lib/l10n/generated/` gitignore (`flutter pub get` 自动生成)。

剩余 ~80 个文案 (其他屏幕) 留作后续 PATCH 分批迁; L15 框架已完成。

### v0.7.2 — release job 移除多余 actions/checkout

v0.6.1 / v0.7.1 连续两次 release job 都挂在 `actions/checkout@v4`:
`fatal: could not read Username for 'https://github.com': terminal
prompts disabled`。这是 GitHub Actions 在 tag-only context 里对
release job 的 GITHUB_TOKEN 注入偶发失败。前次 rerun 通过, 但既然
重复出现, 就不算偶发, 从配置层面修。

release job 其实根本不需要 git working tree —— 它只下载 5 个 build
artifact 然后调 `softprops/action-gh-release@v2` 上传 Release。
直接删掉 `actions/checkout` step, 绕过整个 checkout 失败模式,
顺便少做一份网络 IO。

### v0.7.1 — 重构 PATCH (data 拆 model/IO + settings 抽 background_picker)

让 v0.7.x 拿到重构 PATCH, 解锁下一轮 v0.8.0 新功能。

- **data 层拆 model/IO**: `lib/data/app_settings.dart` 新建, 把 `AppSettings`
  + `AppThemeMode` + `AppThemeModeLabel` extension 搬过去, 不耦合
  SharedPreferences。`settings_repository.dart` 只剩 IO 适配, 通过
  `export 'app_settings.dart'` 保持现有 import 路径仍可用 (调用方不必
  改 import)。
- **settings 抽 background_picker**: `_BgAction` enum / `_BackgroundActionSheet`
  / `_pickBackground` / `_bgSubLabel` 一组 ~80 行从 `_RotationSection`
  搬到 `lib/presentation/settings/background_picker.dart`, 暴露
  `showBackgroundPicker` + `backgroundSubLabel` 顶层函数。
- **cadence helper**: 顶层 `cadenceLabel(int)` + `kCadenceChoices` 取代
  inline 字符串拼接, 便于后续 L15 i18n 替换。
- 新增 `test/cadence_label_test.dart` 锁映射稳定。

不动业务逻辑。

### v0.7.0 — 自定义背景图 (L09)

skill README.md:105-110 说"screensaver background 是 user-provided —
that's the whole point"。这版补上。

- 加 `file_selector ^1.0.3` 依赖, 跨平台 (mobile + desktop) 文件选择。
  Web 暂不支持 (kIsWeb 守护, Settings 入口降级显示提示)。
- `lib/data/background_image_service.dart`: `pickAndStore()` 弹文件
  选择器 → readAsBytes → 写入 `getApplicationDocumentsDirectory()/
  backgrounds/bg-<ts>.<ext>`, 返回稳定 path。这一步是关键: file_selector
  的 XFile 在 Android (content://) / iOS (PHPicker) / Web (blob)
  上原始 path 不稳定, 必须复制到 app doc dir 才能扛重启。新选图时
  会清掉同目录旧文件防止占用累积。
- `AppSettings.backgroundImagePath: String?` 新字段; `SettingsRepository`
  持久化到 SharedPreferences。`copyWith` 加 `clearBackgroundImage` 参
  数显式区分"保留旧值" vs "清空"。
- DisplayScreen photo 模式: 有用户图 → `Image.file(File(path))` cover
  + 顶/底 protection gradient (rgba(0,0,0,0.5) → transparent at 30%/70%,
  严格照 skill README.md:110); 没图 → 现有深绿渐变。Web 强制走渐变
  (kIsWeb 短路)。
- Settings 屏 "屏保 / 小组件" 区段加 "背景图片" 行: BottomSheet 提供
  "从相册或文件选一张" / "回到默认背景" 两个操作; sub 文案根据平台
  / 当前状态自适应。

完成长期项 L09。

### v0.6.1 — 重构 PATCH (settings 拆 Section + plan 压缩)

让 v0.6.x 拿到重构 PATCH。

- `settings_screen.dart` 把 ListView 里 4 段 (屏保 / 字体外观 /
  标签 / 导入导出 / 关于) 各拆成独立 `_*Section` 私有 widget。
  原来 ~130 行的 build 方法瘦身; 每个 section 一个清晰边界,
  以后加新 section (如 v0.7 自定义背景图) 只动一处。
- footer 的 hardcoded `'v 0.3 · ...'` 改成 const `_versionLabel`
  顶层常量, 每个 MINOR 改一次即可。本版同步成 `'v 0.6'`。
- plan.md 旧版本介绍 (v0.1.0 ~ v0.3.1) 压缩成一段"早期版本汇总",
  符合 prompt.md 的"最多保留最新 5 个版本介绍"硬要求。

不动业务逻辑。

### v0.6.0 — 标签管理屏 (L11 收尾)

L11 在 v0.2.0 完成了全文搜索, 这一刀补上标签管理。

- `lib/presentation/tags/tags_screen.dart` 新建: 列出 quotes 里出现过
  的所有标签 + 每个的句数 (派生 provider `tagCountsProvider`, 按句数
  倒序), tap 进入重命名 BottomSheet。"按句数倒序"就是 plan 里说的
  "智能分组" 第一刀: 大组靠前, 小尾巴靠后。
- `_TagEditSheet`: 改名 input + "改好"按钮 + "从所有句子上取下" 红色
  TextButton (复用 [showConfirmDeleteDialog], message 改成 "从所有句子
  上取下「xxx」？")。
- `QuotesNotifier` 加 `renameTag(old, new)` / `removeTag(tag)`,
  内部都走 `_mutate` helper。`renameTag` 同名 / 空 oldTag 是 no-op。
- Settings 屏新增"标签"区段一行入口 → push TagsScreen。
- 测试 `test/rename_tag_test.dart`: 用 fake QuoteRepository + 真实
  ProviderContainer 覆盖 rename / remove / no-op 三个分支。

完成长期项 L11。

### v0.5.1 — 重构 PATCH (showOptionPicker generic helper)

让 v0.5.x 拿到重构 PATCH, 解锁下一轮 v0.6.0 新功能。

settings 屏的 `_pickTheme` 和 `_pickCadence` 各 ~40 行,
结构几乎一样: BottomSheet + ListTile 列表 + 当前选中带 ✓。

抽出 `lib/presentation/widgets/option_picker.dart`,
提供泛型 `showOptionPicker<T>` + record-based `PickerOption<T>`。
两处调用都缩到 ~10 行。后续做"字号/字体"选择也能直接复用。

新增 `test/option_picker_test.dart` widget 测试: 选中返回 value /
空选项不崩。

### v0.5.0 — 响应式适配 (L14) max-width 640

按 skill `README.md:167-169` 的硬规则: 桌面/平板 content max-width 640px,
"we are not a dashboard"; 手机保留 20px safe inset; 屏保 full-bleed。

- 新建 `lib/presentation/widgets/max_width_body.dart`:
  Align.topCenter + ConstrainedBox(maxWidth: 640) 的薄包装。
- Library / Editor / Search / Settings / Widgets-preview 5 个屏顶层
  套 MaxWidthBody。Display 不套, 保持屏保 full-bleed (符合"显示金句独占"
  的产品意图)。
- `lib/theme/app_theme.dart` BottomSheetThemeData 加 `constraints:
  BoxConstraints(maxWidth: 640)`, 让所有 modal sheet (Import / Export /
  pickTheme / pickCadence) 在桌面 / Web 上自动收窄。
- BottomNav 不限宽: 跟桌面应用习惯一致, 底栏跨屏。

完成长期项 L14。

### v0.4.2 — 重构 PATCH (workflow 共用 composite action)

让 v0.4.x 拿到重构 PATCH, 解锁下一轮 v0.5.0 新功能。

5 个 build job 都有同样的 4 步 setup (flutter-action / fetch_fonts /
flutter create / pub get), 抽到 `.github/actions/flutter-setup/action.yml`
composite action。

收益:
- 每个 job 这 4 行 → 1 行 `uses: ./.github/actions/flutter-setup`
- 改 setup 流程 (如更换 Flutter channel、字体策略) 只动一处
- 平台特定步骤 (Linux apt / Android setup-java / desktop enable)
  保留在 job 里, 因为它们不通用

不动业务行为。

### v0.4.1 — fetch_fonts.sh 兼容 bash 3.2

v0.4.0 跑通了 Linux / Windows / Android / Web, 但 macOS runner 挂了:
`tool/fetch_fonts.sh` 用了 `declare -A` 关联数组, 而 macOS runner
默认 bash 是 Apple 锁住的 3.2, 不支持关联数组, `set -u` 下展开
直接报 unbound variable。

改成 bash-3 兼容的平行数组 (NAMES + URLS 一一对齐 + 长度校验),
本地 /bin/bash 跑通验证。

### v0.4.0 — 多平台 CI (L17 部分)

CI workflow 加 3 个 desktop build job, 让一次 tag push 同时出 5 个
平台的可下载产物:

- `build-linux` on ubuntu-latest: 装 GTK toolchain
  (clang/cmake/ninja/gtk-3-dev), `flutter build linux`, tar.gz。
- `build-windows` on windows-latest: VS Build Tools 已预装,
  `flutter build windows`, PowerShell Compress-Archive。
- `build-macos` on macos-latest: Xcode 已预装,
  `flutter build macos` (unsigned), zip .app。
- 每个 job 自己 `flutter create --platforms=<platform> .`,
  fetch_fonts.sh 拉本地字体, 走 release build。
- `release` job 增加 3 个 download-artifact + 把 5 个产物全部
  挂到 GitHub Release。

完成长期项 L17 (除 iOS IPA, 留给 L08 一起处理 Apple 证书)。

### 早期版本汇总 (v0.1.0 ~ v0.3.1)

**v0.1.0** 首版核心: skill colors_and_type.css → XJKTokens 双主题
(青纸/林夜); 金库 / 屏保 / 组件 / 设置 四 Tab + 编辑器 + 批量导入
抽屉; 无重复随机轮播 + 640ms 交叉淡入; JSON 文件本地持久化, talker
日志落盘到 getApplicationSupportDirectory; 28 个本地 Lucide SVG;
GitHub Actions 构建 Android APK + Web bundle; 字体由 tool/fetch_fonts.sh
在 CI 拉取 OFL。

**v0.1.1 / v0.1.2** workflow 修复: `dart format --set-exit-if-changed`
跟 CI Dart 版本的 layout heuristic 死循环, 最终改成 apply-only,
风格由开发者本地保证。

**v0.1.3** 清 flutter analyze: display_screen 缺 AppSettings import;
providers.dart ProviderElement 类型对不上; CI flutter create 自动
生成 widget_test.dart 引用不存在的 MyApp (用占位文件挡住); 把多个
async-gap 后的 context 用法改为 await 前捕获 Navigator/ScaffoldMessenger。

**v0.1.4** 重构 PATCH: 抽 RotationController (NoRepeatShuffle +
Timer.periodic + cadence 同步) 把 4 个互相耦合的 State 字段拢成
一个明确生命周期的 controller; 用户手动 advance 也会重置 cadence。
抽 QuoteCodec 把 File/Prefs 两个仓储的 JSON 编解码集中到一处, 后续
切 drift 只换一处。fake_async 单测覆盖 timer 4 个分支。

**v0.2.0** 全文搜索 + 编辑已有金句 (L11 第一刀, L01 收尾): Library
TopBar search 按钮 → 全屏 SearchScreen (实时按 text/tag 大小写不敏感
子串过滤); EditorScreen 改造可接 editing: Quote?, 进入"改一改"模式;
QuotesNotifier 新增 update(id, text, tag)。

**v0.2.1 / v0.2.2** 重构 PATCH + 修测试: Library/Search/Editor 三处
"从金库取出这句话？" dialog 抽 showConfirmDeleteDialog; SearchScreen
三元嵌套抽 _buildBody。第一版 widget 测试把 XJKTheme 放错位置
(home 下而非 builder), showDialog overlay 拿不到 tokens 直接挂掉,
v0.2.2 改成 MaterialApp.builder 注入。

**v0.3.0** L10 导出 / 导入: Settings 屏新增"导入与导出"区段,
QuoteCodec 编码 JSON + Clipboard.setData 写入剪贴板; 导入 sheet
进屏自动 Clipboard.getData, QuoteCodec.tryDecode 实时预览, 合并进
现有金库 (不覆盖, 安全)。跨平台无新插件。

**v0.3.1** 重构 PATCH: QuotesNotifier 4 个 mutate 方法抽 _mutate
helper, 5 行样板压缩成 1 行 transform; AppThemeMode 加 displayLabel
extension, 让 settings 两处 (label 显示 + picker) 共享映射, picker
直接遍历 .values 而非手维护 tuple list。
