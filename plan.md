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

### v0.13.3 — 修 #3 #4 (4 个子问题)

合并修 Issue #3 (Windows v0.13.0 三处) + #4 (屏保收藏无效):

- **#3.1 TagsScreen 无法退回**: 之前 TopBar 没 leading,Settings push
  过去后用户只能靠系统手势退回 (桌面端没有)。给 `TagsScreen` 的
  `XJKTopBar` 加 `leading: XJKIconButton(icon: 'chevron-left', ...)`,
  跟 skill `ui_kits/android-app/screens.jsx:170` DisplayScreen 的
  back 视觉一致; onTap 优先 `context.canPop() → context.pop()`,
  兜底 `context.go('/library')`。

- **#3.2 cadence 加 1/2/3 分钟**: `kCadenceChoices` 由
  `[5, 15, 30, 60, 120, 240]` 改成 `[1, 2, 3, 5, 15, 30, 60, 120, 240]`。
  DisplayScreen 已经 `cadenceMin.clamp(1, 60*24)`, 无需改限。

- **#3.3 Widgets tab 文案过时**: widgets_preview_screen.dart 副标题
  "三种尺寸 · v0.4 起会真正接入 Android 桌面" 改成
  "三种尺寸 · 长按主屏 → 小组件, 拖动「小金库」到桌面"。
  顶部 doc 注释同步说明 L07 (v0.11.0) / L08 (v0.12.0) 已落地。

- **#4 屏保收藏功能可用**: 之前 bookmark 按钮 `onPressed: null`
  显示 "收藏 (即将上线)"。新建 `lib/data/favorites_repository.dart`
  用 SharedPreferences 存 `Set<String>` 收藏过的 quote id (key
  `folio.favorites.ids.v1`), 故意不动 drift schema, PATCH 范围内
  无数据库迁移; `providers.dart` 新增 `FavoritesNotifier` + provider,
  Display 屏 bookmark 按钮包 Consumer toggle, icon opacity 切实/虚 +
  tooltip 切换 + SnackBar 反馈。"收藏列表入口屏" 留到 v0.14.0 MINOR。

新增 `test/favorites_repository_test.dart` 三条不变量: 空 prefs load /
save→load 回环 / save 空集后清空。

参考 skill 文件: `ui_kits/android-app/screens.jsx` (back button 视觉,
DisplayScreen bottom controls 三按钮布局), `assets/icons/chevron-left.svg`
+ `bookmark.svg`。

### v0.13.2 — 修 v0.13.1 awk 解析空版本号 (#2 回归)

v0.13.1 用 `awk -F'[ :+]'` 把 `:`/space/`+` 全当分隔符切 pubspec
`version: 0.13.1+32`。问题: 集合 FS 在连续分隔符 (`': '`) 处插入空
field, `$2` 是空字符串 → 5 个平台产物落地都叫 `folio--<platform>.<ext>`
版本号位置为空, #2 实际未修。

改用 `grep '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//; s/[+].*$//'`:
- grep 只挑 version 行
- sed 第一段剥前缀 + 空格
- 第二段切 `+` 之后的 build_number, 用 `[+]` 字符类避免 BSD sed
  在 `-E` 模式下报 "repetition-operator operand invalid"
  (Linux GNU sed 容忍裸 `+`, BSD 不容忍, 跨平台保险写法)
- 本地 macOS BSD sed 验证: 输出 `0.13.1`, 跟期望一致

5 个平台 job + workflow 文件全部同步。bump pubspec 0.13.1+32 → 0.13.2+33。

### v0.13.1 — 闪退兜底 + release 包带版本号 (PATCH for #1 #2)

修两个 issue:

- **#1 v0.13.0 APK 闪退**: drift `NativeDatabase.createInBackground` 在
  部分 Android ROM 上首次冷启动时父目录尚未由系统创建, db 打开抛
  SQLite Exception, 未捕获冒到 root 把进程拉死。
  - `lib/data/drift/quotes_database.dart`: 在 `LazyDatabase` 里
    `createSync(recursive: true)` 预创建 `getApplicationSupportDirectory()`。
  - `lib/data/quote_repository.dart`: `buildQuoteRepository` 在 native
    分支 try/catch 包 drift 初始化, 失败时 fallback 到
    新增的 `InMemoryQuoteRepository` (跑种子金句, app 至少打得开)。
  - `lib/main.dart`: 用 `runZonedGuarded` 包住 Bootstrap + runApp,
    装 `FlutterError.onError` + `PlatformDispatcher.onError` 把任何
    未捕获异常都路由到 logger; Bootstrap 自身失败时显示
    `_BootstrapErrorApp` 屏幕代替黑屏闪退。
  - `test/in_memory_quote_repository_test.dart`: 锁住兜底仓库
    load/save/防御性 copy 三条不变量。

- **#2 release 包名缺版本号**: GitHub Actions artifact 沿用 Flutter
  默认的 `app-release.apk` / `folio-web.zip` 等通用名, release 资产无
  法区分版本。
  - `.github/workflows/build.yml`: 5 个平台 job 各加一步
    `Resolve app version` (awk 解析 pubspec `version:` 行取 SemVer 部分,
    不含 build_number), 把所有产物重命名为
    `folio-<version>-<platform>.<ext>`; release job 用 glob 收集。

不动 UI, 无新增 skill 参考。

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

### 早期版本汇总 (v0.1.0 ~ v0.12.0)

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

**v0.4.0 / v0.4.1 / v0.4.2** 多平台 CI (L17 部分): workflow 加
build-linux / build-windows / build-macos 三个 desktop job, 每个
`flutter create --platforms=<p>` + release build + 压缩 + 上传
artifact, release job 一并挂到 GitHub Release; fetch_fonts.sh 改成
bash-3 兼容平行数组扛 macOS runner; 5 个 job 共享的 4 步 setup
(flutter-action / fetch_fonts / flutter create / pub get) 抽到
`.github/actions/flutter-setup/action.yml` composite action。

**v0.5.0 / v0.5.1** 响应式适配 (L14) + 重构: 桌面/平板 content
max-width 640 (skill README:167-169), Library/Editor/Search/Settings/
Widgets-preview 套 MaxWidthBody, Display 屏保保 full-bleed;
BottomSheetThemeData 也加 maxWidth: 640; settings 屏两处 picker 抽
`showOptionPicker<T>` 泛型 BottomSheet。

**v0.6.0 / v0.6.1** 标签管理屏 (L11 收尾) + 重构: TagsScreen 按句数
倒序列出所有标签 (派生 tagCountsProvider) + tap 进 BottomSheet 改名 /
"从所有句子上取下", QuotesNotifier 加 renameTag/removeTag (走 _mutate);
settings_screen 4 段抽独立 _*Section widget。

**v0.7.0 / v0.7.1 / v0.7.2** 自定义背景图 (L09) + 重构: file_selector
跨平台选图 → 复制到 getApplicationDocumentsDirectory()/backgrounds 防
content://blob path 失效; AppSettings.backgroundImagePath 持久化;
DisplayScreen photo 模式有图叠 protection gradient, 无图保深绿渐变;
data 层拆 app_settings / settings_repository, settings 屏抽
background_picker; release job 删多余 actions/checkout 修
tag-only context 偶发 token 注入失败。

**v0.8.0 / v0.8.1** i18n 框架 (L15) + 重构: gen-l10n 打通,
lib/l10n/app_zh.arb + app_en.arb 落 28 个高频 key, MaterialApp 接
AppL10n.delegate, LibraryScreen 切样; SettingsNotifier 5 个 setter
抽 `_apply(AppSettings next)` helper。剩余 ~80 个文案后续 PATCH 分批迁。

**v0.9.0 / v0.9.1** Widget 测试框架 (L16) + race-condition 修: 新建
test/test_harness.dart 提供 FakeQuoteRepository + pumpAppWith,
LibraryScreen / Editor 两屏端到端 widget 测试; QuotesNotifier _load
保存为 _ready future, 5 个 mutate 方法都 `await _ready` 排队等加载,
修了"加载中快速点按数据丢"的 race。

**v0.10.0 / v0.10.1** go_router 路由 + Web 深链 (L13) + 重构:
StatefulShellRoute.indexedStack 包 4 个底栏 branch, 子路由
`/editor` / `/editor/:id` / `/search` / `/tags` 让 Web bookmark 有意义;
router 里 XJKNavTab ↔ path ↔ shellIndex 三角映射抽 `XJKNavTabRoute`
extension 统一一处。

**v0.11.0 / v0.11.1** Android 桌面小组件 (L07) + 重构: Dart 端用
home_widget plugin 把 todayQuote / todayTag 写到共享存储 + 触发 native
AppWidgetProvider 刷新; native 端 docs/android_widget/ 提供三尺寸
RemoteViews 布局 + 单一 QuoteWidgetProvider, CI 用 inject_android_widget.sh
在 `flutter create` 后注入 receiver 到 AndroidManifest。重构 PATCH
抽 `lib/core/platform_capabilities.dart` 集中 `kIsWeb` + `Platform.isX`
样板, `lib/presentation/widget_sync_bridge.dart` 把 `ref.listen
(quotesProvider)` 从 FolioApp 抽出独立 ConsumerStatefulWidget。

**v0.12.0** iOS 桌面小组件 (L08, 与 L07 镜像): Dart 端 `HomeWidget.
updateWidget` 加 `iOSName: 'QuoteWidget'`; Swift 模板 docs/ios_widget/
提供 QuoteEntry / QuoteProvider / QuoteWidget (StaticConfiguration 三个
family) / QuoteWidgetBundle, 严格翻译 skill widgets.jsx 三尺寸视觉,
App Group `group.app.folio` 跨 app/extension 共享 UserDefaults。
Caveat: iOS Widget Extension 须 Xcode 新建 target + Apple Developer
证书签名, CI 暂不构建 iOS。
