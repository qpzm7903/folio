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
- [ ] L12 · drift 持久化迁移 (替换 JSON 文件存储) — v0.13.0 引入 drift, v0.13.4 因 #5 native SIGSEGV 临时切除回 SharedPreferences, 等真因定位再恢复
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

### v0.14.1 — 修 Issue #5 真因 (WorkManager startup disable)

用户 HONOR AAK-AN00 (MagicOS Android 16 / SDK 36) 真机 adb 抓栈,
**真因跟 drift / sqlite3 完全无关**。完整栈:

```
java.lang.RuntimeException: Unable to get provider
  androidx.startup.InitializationProvider: java.lang.RuntimeException:
  Failed to create an instance of androidx.work.impl.WorkDatabase
    at androidx.work.WorkManagerInitializer.b(...:95)
    at androidx.startup.InitializationProvider.onCreate(...:55)
    at android.content.ContentProvider.attachInfo(...)
```

`InitializationProvider` 在 `ActivityThread.installContentProviders` 阶段
跑, 早于 `MainActivity.onCreate`, 早于 Flutter / Dart VM 启动。所以 v0.13.1
装的 `runZonedGuarded` + `FlutterError.onError` + `_BootstrapErrorApp`
全没机会执行 — 进程在 Dart 起来前已经被 SIGKILL。这也解释了为什么
`getApplicationSupportDirectory()/logs/folio.log` 是空的: logger 自己
都没初始化。

`home_widget` plugin 通过 transitive dep 拉进 `androidx.work`, Android 16
SDK 36 上 Room 创建 `WorkDatabase` 抛 `RuntimeException` (R8 obfuscation
后看不到更深一层 cause)。folio 实际不用 WorkManager 后台任务 (widget
sync 走前台 `HomeWidget.updateWidget` + Android `AppWidgetProvider` 系统
广播), 直接 disable WorkManager 的 startup 入口即可。

修法:
- `docs/android_widget/AndroidManifest_widget_fragment.xml` 加 `<provider
  androidx.startup.InitializationProvider tools:node="merge">` 块, 在
  里面 `tools:node="remove"` 掉 `androidx.work.WorkManagerInitializer`
  meta-data。`tool/inject_android_widget.sh` 已经把整个 fragment 注入到
  `</application>` 之前, 不需要改脚本。

**v0.13.4 反思**: 我当时把 Issue #5 误判为 drift / sqlite3 native SIGSEGV,
把 drift 整条切除 (L12 [x] → [ ])。adb 抓栈后真因是 home_widget +
WorkManager + Android 16 兼容性, drift 完全没问题。v0.15.0 会重新引入
drift 恢复 L12。

参考 skill: 无 UI 改动。

### v0.14.0 — 收藏列表屏

v0.13.3 在屏保里接入了 bookmark toggle (Issue #4), 当时承诺
"收藏列表入口屏留到 v0.14.0 MINOR"。这版兑现。

- 新建 `lib/presentation/favorites/favorites_screen.dart`:
  watch `quotesProvider` + `favoritesProvider`, 过滤出收藏中的
  quotes; 复用 `QuoteCard` (LibraryScreen 同款卡片) + `XJKSectionHeader`,
  TopBar 加 `chevron-left` 返回; 空态文案 "在屏保里点 bookmark 试试"。
- 卡片 onTap → `context.push('/editor/${q.id}')` 直接进编辑器,
  跟 LibraryScreen 行为一致。
- `lib/core/router.dart`: 加 `FolioRoutes.favorites = '/favorites'`
  顶层路由。
- `lib/presentation/settings/settings_screen.dart`: `_TagsSection`
  改名 "标签与收藏", 增加"我的收藏" 行入口, sub 文案随 favorites
  数量动态变 ("$count 句" / 提示)。
- 新增 `test/favorites_notifier_test.dart` 锁 3 条不变量:
  初始为空 / toggle 同 id 两次回环 / 跨 ProviderContainer 持久化。

参考 skill: `ui_kits/android-app/screens.jsx` (LibraryScreen 卡片
+ section header 视觉), `assets/icons/chevron-left.svg` /
`bookmark.svg`。

### v0.13.5 — 重构 PATCH (legacy_quotes_migration + bootstrap_error_screen)

让 v0.13.x 拿到重构 PATCH。

- **quote_repository.dart 拆分** (103 → 76 行): top-level
  `_maybeMigrateLegacyJson` 抽到独立 `lib/data/legacy_quotes_migration.dart`
  的 `LegacyQuotesMigration` 类。理由: 这是个独立关注点 (历史文件格式
  → 当前存储的一次性迁移), 跟 repo 的 load/save 语义无关; 抽出后 repo
  文件专注 "接口 + Prefs 实现 + InMemory 兜底" 三件事, 而 migration
  自身可以独立单测 (旧文件不存在 / 存在 + prefs 空 / prefs 已有 / 旧文件
  损坏 4 个分支), 不必走真实 SharedPreferences/path_provider mock 链。
- **main.dart 拆分** (98 → 56 行): 内联的 `_BootstrapErrorApp` 抽到
  `lib/presentation/bootstrap_error_screen.dart` 的 `BootstrapErrorScreen`
  公开 widget。理由: main.dart 应该只关心 "process entry + 全局错误兜底
  路由 + runApp" 三件事; 错误屏的渲染细节是 UI 关注点, 跟 presentation/
  目录的其它屏并列。抽出后 BootstrapErrorScreen 还能在 widget book / 设计
  review 时单独 preview。
- **测试**: 新增 `test/legacy_quotes_migration_test.dart` 用 `_FakePathProvider`
  (PathProviderPlatform.instance override) + temp dir 锁 4 个不变量;
  in_memory test group 标题更新, 不再写"drift 失败兜底" (已过时)。

不动业务行为。

### v0.13.4 — bypass drift, native 走 prefs (Issue #5)

用户反馈 v0.13.2 APK 仍闪退 (Issue #5)。我 v0.13.1 装的
`runZonedGuarded` + `FlutterError.onError` + `_BootstrapErrorApp`
只能兜 **Dart 层** 异常; 用户机型上 `libsqlite3.so` 加载触发
**native SIGSEGV**, Dart try/catch 在进程被内核 kill 之前根本
不会执行 → 我的 in-memory fallback 永远到不了。

**根治**: 完全 bypass drift native 调用, 让所有平台都走
`_PrefsQuoteRepository` (跟 web 一致, v0.12.x 之前的 native 也是
存到文件, prefs 同性质):

- `lib/data/quote_repository.dart`: 去掉 conditional import +
  `drift_impl.buildDriftQuoteRepository()` 调用; native 端启动时
  若 `${getApplicationSupportDirectory()}/quotes.json` 存在 + prefs
  无 quotes 数据 → 一次性导入 + rename 备份 (`migrate-<ts>`),
  不丢 v0.12.x 用户数据。
- 删除 `lib/data/drift/` + `drift_quote_repository_io.dart` +
  `drift_quote_repository_stub.dart` + `test/drift_quotes_database_test.dart`。
- `pubspec.yaml`: 移除 `drift` / `sqlite3_flutter_libs` /
  `drift_dev` / `build_runner` 4 个 dep (sqlite3 native libs
  不再进 APK, 体积减少 ~10 MB)。CI flutter-setup 的 build_runner
  step 自动 no-op (它本来就 `grep drift_dev` 才跑)。

**长期规划影响**: L12 状态从 [x] 打回 [ ], 长期规划 16/17。
等收集到 #5 用户机型/Android 版本信息, 定位是 sqlite3_flutter_libs
的 commit 问题还是更深的兼容性问题, 再规划 v0.14+ 重新引入。

不动 UI, 无新增 skill 参考。

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

### 早期版本汇总 (v0.1.0 ~ v0.13.2)

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

**v0.12.1** 重构 PATCH: `main.dart` 的 "ensureInitialized → logger →
intl 数据 → SharedPreferences → QuoteRepository → ProviderScope
overrides → runApp" 抽到 `lib/core/bootstrap.dart` 的 `Bootstrap.
initialize()`, 返回 `List<Override>` 给 main 自己拼 ProviderScope,
让集成测试 / 未来多入口能复用前 5 步; main.dart 缩成 4 行。

**v0.13.0** drift 持久化迁移 (L12 首次尝试): 加 drift ^2.20.0 +
sqlite3_flutter_libs ^0.5.24 + dev drift_dev + build_runner; native 端
持久化从 quotes.json 升级到 SQLite, 启动时一次性 JSON → drift 迁移 +
rename 备份; Web 仍走 SharedPreferences。L12 在 v0.13.0 标 [x] 但
v0.13.4 因 Issue #5 native SIGSEGV 切除 drift 后打回 [ ], drift 路径
完全删除等真因定位后再以 v0.14+ 重新引入。

**v0.13.1** 闪退兜底 + release 包带版本号 (#1 #2 首次尝试):
drift LazyDatabase 预创建 supportDir; buildQuoteRepository try/catch
fallback 到 InMemoryQuoteRepository; main.dart 用 runZonedGuarded +
FlutterError.onError + PlatformDispatcher.onError 路由未捕获异常到
logger, Bootstrap 失败时显示错误屏代替黑屏。CI 5 个平台 job 加
awk 解析 pubspec version, 产物重命名 folio-&lt;v&gt;-&lt;p&gt;.&lt;ext&gt;。
(awk FS 集合 bug 让 #2 没真修, v0.13.2 用 grep+sed 才真正修好;
#1 的 Dart 层兜底也救不了 native SIGSEGV, v0.13.4 才彻底解决。)

**v0.13.2** 修 v0.13.1 awk 集合 FS 在连续分隔符处插空 field 的 bug:
改用 `grep '^version:' | sed -E 's/^version:[[:space:]]*//; s/[+].*$//'`,
`[+]` 字符类避开 BSD sed 在 `-E` 模式下报 "repetition-operator operand
invalid"。产物文件名才真正带版本号。
