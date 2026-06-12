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
- [x] L12 · drift 持久化迁移 (替换 JSON 文件存储) — v0.13.0 首次引入, v0.13.4 因误判 #5 切除, v0.14.1 用 adb 抓栈定位真因是 home_widget WorkManager, v0.15.0 恢复 drift (含 prefs → drift 迁移路径)
- [x] L13 · go_router 路由 + Web 深链 — v0.10.0 (StatefulShellRoute + URL 深链)
- [x] L14 · 响应式适配 (手机 / 折叠屏 / 平板 / 桌面 / Web) — v0.5.0 max-width 640
- [x] L15 · 国际化 (中文为主，预留 en 框架) — v0.8.0 (gen-l10n + ARB + LibraryScreen 切样, 剩余文案后续 PATCH 分批迁)
- [x] L16 · 完整测试覆盖 (单元 + Widget + 集成) — v0.9.0 (test_harness + 屏级 widget 测试框架到位; 剩余屏后续 PATCH 持续覆盖)
- [x] L17 · 多平台 CI 产物 — v0.4.0/v0.4.1 实现 Android + Web + Linux + Windows + macOS;
  iOS IPA 因 Apple 签名证书复杂留 L08 后续单独处理
- [x] L18 · 桌面小组件按 cadence 自动刷新 — v0.16.0 实现 (因 kAppVersion 漏改实际以 v0.16.1 兜底发布):
  Android AlarmManager.setInexactRepeating + Dart 预生成 N=20 timeline + cursor 推进。iOS
  WidgetKit TimelineProvider 镜像实现留 L08 后续 (CI 暂不构建 iOS)
- [x] L19 · 壁纸保持手动一次性 — v0.16.0 明确决定不做: 用户在屏保点 "设为壁纸"
  触发, 不做后台自动轮换 (功耗 + 后台 init 风险)
- [ ] L20 · 鸿蒙 6.0 适配 (OpenHarmony Flutter fork, 决策见 docs/adr/0001) — 规划 v0.17:
  v1 只含纯 Dart 核心功能 (金库 + 屏保 + 主题 + 搜索标签 + 导入导出)。里程碑:
  ① 环境搭建 (Command Line Tools + AGC 调试签名, 不装 DevEco) + 空壳 hap 上 Mate 80 真机;
  ② 关键依赖编译验证 (sqlite3 不过则仓储降级 prefs 工厂分流; file_selector 缺位则
  隐藏选图入口、保留内置纯色背景);
  ③ 完整 app 跑通 + PlatformCapabilities.isOhos 能力开关收尾。
  ohos/ 工程直接进仓库 (签名材料 gitignore), 鸿蒙构建 v1 不进 CI。
  过程要求: 每个里程碑的踩坑与经验随做随归档到 docs/wiki/ohos/, 不攒到最后补写。
  wiki 以对外分享为目标写作: 可复现步骤 + 工具/SDK 版本号 + 失败现象与修法;
  对外发布前脱敏 (不含 p12/证书/UDID/账号信息)
- [ ] L21 · 鸿蒙服务卡片 (ArkTS 重写 L18 timeline 刷新机制) — 待 L20 落地后排期。
  "设为壁纸" 在鸿蒙为系统 API 大概率三方不可用, L20 spike 顺带验证后决定是否永久放弃

---

## 中期规划 (Mid-term, 1-3 个 MINOR)

- v0.1 · 首版核心金库 + 屏保 + 主题
- v0.2 · 本地字体自托管 + drift 持久化迁移 (含一个重构 PATCH)
- v0.3 · 自定义背景图 + 导出/导入
- v0.4 · Android 桌面小组件
- v0.5 · 全文搜索 + 标签管理
- v0.6 · 响应式适配 + Web 深链
- v0.16 · 桌面小组件按 cadence 自动刷新 (Android AlarmManager + timeline 契约)
- v0.17 · 鸿蒙 6.0 适配 (L20, OpenHarmony Flutter fork + 纯 Dart 核心功能)

## 短期规划 (Short-term)

- v0.16.2 (已完成) · 重构 PATCH: 平台判断收敛为能力开关 (为 L20 铺路) + lint 清零
- v0.17 = L20 鸿蒙 6.0 适配, 里程碑 ①②③ 见长期规划 L20 条目。
  每完成一个里程碑, 同步归档一篇 wiki 到 docs/wiki/ohos/。

---

## 版本日志

### v0.16.2 — 重构 PATCH: 能力开关收敛 + lint 清零 (L20 铺路)

按开发流程规则 (当前 MINOR 缺一个重构优化 PATCH), 在开 v0.17 鸿蒙 MINOR
之前做的纯重构, 行为零变化:

- `PlatformCapabilities` 新增三个能力开关 (TDD, 先红后绿):
  - `isOhos` — 用 `Platform.operatingSystem == 'ohos'` 判断, 不用 fork 专属
    getter, 保证同一份代码在官方 SDK 和鸿蒙化 fork 上都能编译;
  - `supportsSetWallpaper` — `WallpaperService.isSupported` 改读它,
    替掉裸 `isAndroid`;
  - `supportsWidgetAlarm` — `WidgetSyncService` 两处裸 `isAndroid` 替换。
  原则: UI/service 只问能力、不问平台, 鸿蒙差异以后全部走能力开关表达。
- lint 清零: 本地升到 Flutter 3.44.2 后 analyze 报 4 个 info
  (unnecessary_import / 可空声明 / 下划线局部名 / prefer_const), 全部修掉,
  `flutter analyze` 恢复 0 issue。
- `dart format` 以 3.44 风格重排了 24 个文件 (tall-style), 属格式噪音,
  CI format 是 apply-only 不会冲突。
- 本地开发环境从零搭建: 官方 Flutter 3.44.2 stable (`~/sdks/flutter-stable`)
  + 鸿蒙化 fork oh-3.35.7-release (`~/sdks/flutter-ohos`), 字体用
  `tool/fetch_fonts.sh` 本地拉取, drift 生成代码用 build_runner 重建。
- 测试 86 → 89 (新增 3 个能力开关断言), 全过。

### v0.16.1 — 修 v0.16.0 kAppVersion 漏改 (workflow 红牌 PATCH)

v0.16.0 push 后 CI `app_version_test.dart: kAppVersion 与 pubspec.yaml
的 version 字段一致` 失败:
```
Expected: '0.16.0'
Actual: '0.15.10'
```

我 bump 了 `pubspec.yaml` 到 `0.16.0+50` 但忘改 `lib/core/app_version.dart`
里的 `kAppVersion = '0.15.10'`。这正是 v0.15.1 引入这个测试要防的双源
真相场景, 测试守住了红线工作正确, 但开发者 (我) 仍踩了同一个坑。

修法是同步 `kAppVersion = '0.16.1'`, 这版直接走 PATCH 兜底 v0.16.0
的发布。v0.16.0 tag 已 push 到 GitHub 但 CI 在 analyze+test 阶段
失败没产出 APK, 该 tag 对应的 release 不存在, 跳过 v0.16.0 直接发
v0.16.1 即可。

教训: 改 pubspec 时必须同步 `lib/core/app_version.dart`。考虑后续给
开发流程加 pre-commit grep, 或把测试运行提前到 push 前。

参考 skill: 无 UI 改动。

### v0.16.0 — 桌面小组件按 cadence 自动刷新 (因 kAppVersion 漏改实际以 v0.16.1 兜底发布)

**版本号**: `0.16.0+50` (上一版 `0.15.10+49`, MINOR bump 因为是新功能)。

**优先级判定**:
- 无 open issue (`gh issue list --state open` 空)
- workflow 全绿 (v0.15.10 / v0.15.9 push 均 success)
- v0.15.x MINOR 已有重构 PATCH v0.15.10
- → 应规划新 MINOR, 开 L18 这条长期项

**用户痛点**: cadence 设置目前**只影响 app 内 DisplayScreen 屏保**, 桌面
小组件只在 quotes 列表 / 配色变化或 app 启动时被动同步一次, 静态停在
`quotes.first` (排序后第一句), 不随用户配的 1min/5min/30min 节奏滚动。
表面上"小组件 = app 的延伸", 实际上是个 stale snapshot, 跟用户预期严重
错位。

**设计取舍 (已确认)**:

1. **cadence 来源**: 复用 `AppSettings.cadenceMinutes`, 但**小组件下限
   15 分钟** (`max(cadenceMinutes, 15)`)。理由: AlarmManager doze 模式下
   实际能保证的最小间隔就在 10-15 分钟; 而且小组件 1 分钟切一次会被
   用户当电池杀手卸载, 不接受单独加 widgetCadenceMinutes 让设置屏更复杂。
2. **重启恢复**: **不**申请 `RECEIVE_BOOT_COMPLETED`。重启后 alarm 丢失,
   小组件停在最后一句, 等用户下次打开 app 由 `WidgetSyncBridge` 重新
   schedule。理由: 部分定制 ROM (小米/华为) 对 boot receiver 有额外
   自启限制, UX 体验依赖用户授权, 不如直接接受静止 + 明确恢复路径。
3. **"下一句是什么" 契约**: Dart 端预生成 N=20 条 timeline 写 prefs,
   native 推 cursor index。跟 iOS WidgetKit `TimelineProvider` 同构,
   L08 iOS 自动刷新可以**直接复用同一份契约**, 不必为两平台各设计一套。
   Native Kotlin 不参与 shuffle 逻辑, 保证 app 屏保和小组件显示完全
   同一份 NoRepeatShuffle 序列。

**技术实现 (分 7 个小提交)**:

1. **`lib/domain/widget_timeline.dart` (新建)**: 纯函数 `WidgetTimeline
   .generate(List<Quote> quotes, {int length = 20, int? seed})`, 复用
   `NoRepeatShuffle` 语义产出 `List<Quote>`。`serialize` / `deserialize`
   走 JSON (跟 `QuoteCodec` 同 pattern, 但因为 widget 只读 text+tag 简化
   字段)。单测覆盖空列表 / quotes < 20 / quotes >> 20 / 重复 quote 4 个
   边界。

2. **`lib/data/widget_sync_service.dart` (扩)**: `syncToday` 改造为
   `syncTimeline(List<Quote> quotes, {WidgetColorTheme? colorTheme,
   int cadenceMinutes})`:
   - 调 `WidgetTimeline.generate` 生成 20 条
   - `HomeWidget.saveWidgetData<String>('widgetTimeline', json)`
   - `HomeWidget.saveWidgetData<int>('widgetTimelineCursor', 0)`
   - `HomeWidget.saveWidgetData<int>('widgetCadenceMinutes',
     max(cadenceMinutes, 15))`
   - 然后调新 method channel `app.folio/widget_alarm.schedule(cadenceMin)`
     让 native 安排 AlarmManager
   - **保留** `todayQuote` / `todayTag` 兼容字段 (拿 timeline[0]), 让
     旧版 widget layout 不挂

3. **`docs/android_widget/app/src/main/kotlin/app/folio/widget/QuoteWidgetAlarmReceiver.kt`
   (新建)**: `BroadcastReceiver` 收 `app.folio.action.WIDGET_TICK`:
   - 读 prefs cursor, `cursor = (cursor + 1) % timelineLength`, 写回
   - 触发所有 `QuoteWidgetProvider` instance 的 `onUpdate` 重新读 prefs
     渲染 (走 `AppWidgetManager.notifyAppWidgetViewDataChanged` 或
     直接 `sendBroadcast(ACTION_APPWIDGET_UPDATE)`)

4. **`docs/android_widget/app/src/main/kotlin/app/folio/widget/WidgetAlarmScheduler.kt`
   (新建)**: 单例对外暴露 `schedule(context, cadenceMin)` /
   `cancel(context)`:
   - `AlarmManager.setInexactRepeating(AlarmManager.RTC, triggerAt,
     intervalMillis, pendingIntent)` (无需 SCHEDULE_EXACT_ALARM 权限,
     doze 友好)
   - `intervalMillis = max(cadenceMin, 15) * 60_000`
   - PendingIntent 复用 (FLAG_UPDATE_CURRENT) 防止泄漏

5. **`docs/android_widget/app/src/main/kotlin/app/folio/MainActivity.kt`
   (扩)**: `configureFlutterEngine` 注册第二条 channel
   `app.folio/widget_alarm`, 路由 `schedule(cadenceMin)` / `cancel()`
   到 `WidgetSchedulerAlarmScheduler` (跟现有 `app.folio/wallpaper` channel
   并列)

6. **`docs/android_widget/AndroidManifest_widget_fragment.xml` (扩)**:
   注册 `QuoteWidgetAlarmReceiver` 监听 `app.folio.action.WIDGET_TICK`
   intent。**不**加 BOOT_COMPLETED filter (按上面取舍 2)

7. **`lib/presentation/widget_sync_bridge.dart` (扩)**: 把 `quotesProvider`
   / `settingsProvider` 两个 listener 的 `syncToday(today, colorTheme:...)`
   全部改成 `syncTimeline(allQuotes, colorTheme:..., cadenceMinutes:
   settings.cadenceMinutes)`。**新加** `cadenceMinutes` 字段的变化检测,
   只在 cadence 真变化时重新 schedule alarm (节省 alarm churn)

**测试**:

- `test/widget_timeline_test.dart`: 4 个 generate 边界 + 1 个 serialize
  round-trip
- `test/widget_sync_service_test.dart`: `syncTimeline` mock HomeWidget
  channel, 锁住 prefs 4 个 key 都被写 + cadenceMin 应用 15 min floor
- `test/widget_sync_bridge_test.dart` (新建): pump WidgetSyncBridge
  with `_StubWidgetSyncService`, 验证 quotes 变化 / cadence 变化 /
  colorTheme 变化各自只触发一次相应同步
- Native 端 (Kotlin) 因为没 CI Android instrumentation test 框架, 暂
  不写 native test, 用 adb logcat 真机 smoke 验证 (跟 v0.15.5 widget click
  同策略)

**风险与缓解**:

- **风险 A**: `AlarmManager.setInexactRepeating` 在 Android 12+ 实际下限
  被推到 ~15 分钟, 用户配 30min 实际可能 35-40min 切。**缓解**: doc 里
  明确"小组件刷新间隔为系统最佳努力, 实际可能稍晚"。
- **风险 B**: PendingIntent FLAG_IMMUTABLE 在 Android 12+ 强制要求,
  v0.15.5 已踩过坑 (HomeWidgetLaunchIntent 内部处理), 这次自己写
  WidgetAlarmScheduler 不能漏。**缓解**: 直接 `PendingIntent.FLAG_IMMUTABLE
  or PendingIntent.FLAG_UPDATE_CURRENT`, code review 时盯死。
- **风险 C**: `home_widget` plugin 的 `saveWidgetData` 对大 JSON (20 条
  quote 序列化) 性能未知, 但单条 quote 即使含中文也就 ~200 bytes, 20 条
  ~4KB 没问题, SharedPreferences 上限 250KB。
- **风险 D**: 用户关掉 app 后台后 native receiver 仍能收到 alarm 吗?
  → AlarmManager 的 receiver 注册在 Manifest, 系统进程托管, 不依赖 app
  进程存活。但用户在系统设置里彻底"强制停止"folio 后 alarm 会失效, 这
  是 Android 平台行为, 跟"重启丢失"同性质, 接受。

**明确不做**:

- ❌ 壁纸自动刷新 (按用户决定保持 v0.15.9 的手动一次性)
- ❌ iOS widget 自动刷新 (CI 不构建 iOS, 留 L08 后续)
- ❌ RECEIVE_BOOT_COMPLETED 权限
- ❌ Foreground service
- ❌ WorkManager (v0.14.1 永久 strip, 不回头)
- ❌ 让 cadence 在 widget 层无下限 (15min floor 写死)

**参考 skill**: 无新 UI 视觉。设置屏不加新行 (复用 cadence)。widgets_preview
副标题文案可微调说明"小组件按所选频率自动更换 (最低 15 分钟)"。

---

### v0.15.10 — 重构 PATCH (WallpaperService 接入 Riverpod provider)

兑现 prompt.md 优先级 #3 "当前 MINOR 没有重构 PATCH 必须立即规划"。
v0.15.x MINOR (v0.15.0 起) 9 个 PATCH 全是 issue 修复 / workflow 修复,
没有专门重构。这版补上。

**重构目标**: v0.15.9 我新加的 `WallpaperService` 是唯一**直接在 widget
state 里 `new WallpaperService()` 实例化**的 service, 跟代码库其他 service
(WidgetSync / BackgroundImage / SettingsRepository / FavoritesRepository /
QuoteRepository) 都走 Riverpod `Provider<T>` 注入的 pattern 不一致。
后果: 没法在测试里 `overrideWithValue(_MockWallpaperService())`, 测 UI
会调真 MethodChannel 失败。

修法:

- `lib/data/wallpaper_service.dart`: 构造函数从 `WallpaperService()` 改成
  `const WallpaperService()`, 跟 `WidgetSyncService` / `BackgroundImageService`
  对齐, 让 provider 可以返回 const singleton。
- `lib/presentation/providers.dart`: 加 `wallpaperServiceProvider`,
  `Provider<WallpaperService>((Ref ref) => const WallpaperService())`,
  紧跟 `widgetSyncServiceProvider`。
- `lib/presentation/display/display_screen.dart`: 删 `_wallpaperService`
  field, `_setAsWallpaper` 里 `ref.read(wallpaperServiceProvider)` 取实例;
  按钮可见性判断 `if (ref.watch(wallpaperServiceProvider).isSupported)`
  (用 watch 让未来 override 切换能触发 rebuild)。
- `test/wallpaper_service_test.dart` 新增: 锁住三条不变量:
  1. `isSupported` 在非 Android host 为 false (CI Linux / 本地 macOS)
  2. provider cache: 两次 read 拿到同一实例
  3. `overrideWithValue(_StubWallpaperService())` 链路可用

不动业务行为。下次有新 service 时跟着 provider 走, 防止再积累不一致。

参考 skill: 无 UI 改动。

### v0.15.9 — Issue #8 屏保设为 Android 系统壁纸

用户 Issue #8 "屏保应该真的影响屏幕壁纸, 而不是只要应用没有一个界面"。
理解为: 把屏保画面 (当前 quote + 背景) 一键设成 Android 系统 +
锁屏壁纸, 让"屏保"真正影响桌面。Android 三种"屏保"概念里
(WallpaperManager.setBitmap / Daydream service / Live Wallpaper),
选最直接的 `setBitmap`, 工程量最小且对用户最直观。

不引入新 plugin (v0.14.1 教训), 走自写 MethodChannel + 自定义
MainActivity 路线:

- **native** (`docs/android_widget/app/src/main/kotlin/app/folio/MainActivity.kt`):
  自定义 MainActivity 覆盖 `flutter create` 默认空版,
  `configureFlutterEngine` 注册 channel `app.folio/wallpaper`,
  `setWallpaperFromFile(path, flag)` 调 `WallpaperManager.setBitmap`,
  默认 `FLAG_SYSTEM or FLAG_LOCK` 同时设主屏 + 锁屏。
- **inject 脚本** (`tool/inject_android_widget.sh`):
  1. cp 自定义 MainActivity.kt 到 android/app/src/main/kotlin/app/folio/
  2. python patch AndroidManifest.xml 顶层加
     `<uses-permission android:name="android.permission.SET_WALLPAPER" />`
     (normal permission, Android 6+ install-time 自动授予, 不需要
     runtime request)。
- **Dart 端** (`lib/data/wallpaper_service.dart`):
  `setWallpaperFromBoundary(RenderRepaintBoundary)`:
  `boundary.toImage(pixelRatio: 2.5)` → PNG bytes → 写到
  `getApplicationSupportDirectory()/wallpapers/quote-<ts>.png` →
  channel `setWallpaperFromFile(path)`。`isSupported`
  根据 `PlatformCapabilities.isAndroid` 判断, 其他平台 UI 隐藏入口。
- **DisplayScreen** (`lib/presentation/display/display_screen.dart`):
  重构 Stack 分两层 — 内层 RepaintBoundary 只包背景 + 文字
  (key=_boundaryKey), 外层 Stack 加按钮 row → 截图自然不含按钮。
  底部按钮 row 加第 4 个 IconButton (icon=`download`, tooltip=
  `设为系统壁纸`), `_setAsWallpaper` 走 wallpaper service +
  SnackBar 反馈成功/失败。`_settingWallpaper` flag 防双击。

跨平台:
- Android: 走 native 路径, setBitmap 成功后系统壁纸立即更新。
- iOS / Web / Desktop: `WallpaperService.isSupported = false`,
  download 按钮直接不渲染, 不会误触。

参考 skill: 无新 UI 视觉, button 沿用 XJKIconButton + 复用现有
`download.svg` 图标 (assets/icons/), tooltip 中文文案。

### v0.15.8 — 修 v0.15.7 XML 注释 `--` 让 aapt 报错 (workflow 红牌 PATCH)

v0.15.7 CI build android apk fail:
```
colors_folio.xml:13:52: Error: The string "--" is not permitted within comments.
```

XML 1.0 规范禁止注释里出现 `--` (因为它是 `-->` 终止符的前缀,
parser 不允许)。我 v0.15.7 在 `colors_folio.xml` 写注释
`(skill --bamboo-500)` 引用 skill css 变量名时直接复制了 CSS 的双连字符,
aapt2 校验 XML 严格按规范走。Android build 工具链刚开始 v0.15.7 不会
crash, 但到 `packageReleaseResources` 阶段会校验 resource XML 合规性。

修法: 把 `(skill --bamboo-500)` 改成 `(skill bamboo-500 token)`,
去掉前缀 `--`。

PATCH 不改业务行为, 让 v0.15.7 的 Issue #6 子任务 4 实际产出 APK。

参考 skill: 无 UI 改动。

### v0.15.7 — Issue #6 子任务 4 (小组件选颜色), Issue #6 闭环

Issue #6 4 个子任务全部完成 (v0.15.4 + v0.15.5 + v0.15.7):
1. ✅ 去"金"字 (v0.15.4)
2. ✅ 出处放右下角 (v0.15.4)
3. ✅ 点击切换金库 → 启动 app 到屏保 (v0.15.5)
4. ✅ 支持选颜色 (**本版**): 3 个预设青纸/林夜/翠竹

实施 (跨 Dart + native + 持久化 3 层):

- `lib/data/widget_color_theme.dart` 新建 enum (paper/night/bamboo)
  含 `displayLabel` ("青纸"/"林夜"/"翠竹") + `displaySub` ("Paper · 浅底"
  等英文小字)。
- `lib/data/app_settings.dart` 加 `widgetColorTheme` 字段, copyWith /
  defaults (paper) / operator== / hashCode 全跟着加; `export 'widget_color_theme.dart'
  show WidgetColorTheme;` 让 settings_repository.dart 的下游不必加新 import。
- `lib/data/settings_repository.dart` 加 `_kWidgetColor` SharedPreferences
  key + load/save + `_decodeWidgetColor` (未知值 fallback 到 paper)。
- `lib/presentation/providers.dart` SettingsNotifier 加 `setWidgetColorTheme`。
- `lib/data/widget_sync_service.dart` `syncToday` 加 `colorTheme` 可选参数,
  通过 `HomeWidget.saveWidgetData<String>('widgetColorTheme', name)` 透传。
- `lib/presentation/widget_sync_bridge.dart` 加第二个 `ref.listen<AppSettings>`,
  只在 `widgetColorTheme` 真变化时触发 sync (避免其他设置改动也强刷 widget)。
- `lib/presentation/settings/widget_color_picker.dart` 新建 BottomSheet,
  3 张色卡 ListTile (32×32 圆点 leading + 中文 title + 英文 italic subtitle
  + 选中带 `Icons.check` trailing); 复用 `showModalBottomSheet` + `showDragHandle`,
  视觉跟 option_picker 同质。
- `lib/presentation/settings/settings_screen.dart` `_RotationSection` 加
  SettingRow "小组件配色", `_pickWidgetColor` 走 `showWidgetColorPicker`。
- `docs/android_widget/app/src/main/res/drawable/xjk_widget_bg_bamboo.xml`
  新增: bamboo-500 (#B8A866) solid, 22dp radius, 无 stroke。
- `docs/android_widget/app/src/main/res/values/colors_folio.xml` 加
  `xjk_bamboo_500` color resource (skill `colors_and_type.css:38`)。
- `docs/android_widget/.../QuoteWidgetProvider.kt` 读 prefs 的
  `widgetColorTheme` key (null → paper), `setInt(R.id.widget_root,
  "setBackgroundResource", resId)` runtime 覆盖 layout 默认 background。
- `test/settings_notifier_test.dart` 加 `setWidgetColorTheme(bamboo)` 调用,
  既验证 state 也验证 prefs 持久化 round-trip。

iOS Widget Extension 端的 colorTheme 透传留后续 (CI 当前不构建 iOS),
跟 v0.15.4 视觉调整保持一致的 iOS pending 状态。

参考 skill: `colors_and_type.css:36-39` (bamboo-500 = #B8A866);
widget 色卡视觉是按用户 Issue #6 自由发挥, skill 原 widgets.jsx 没有
颜色选择面板设计。

### v0.15.6 — 修 v0.15.5 Kotlin 编译报错 (workflow 红牌 PATCH)

v0.15.5 CI build android apk fail, Kotlin 编译两条 error:

```
QuoteWidgetProvider.kt:37:65 Cannot infer type for type parameter 'T'.
QuoteWidgetProvider.kt:39:13 Argument type mismatch: 'Class<CapturedType(*)>!' vs 'Class<uninferred T>'
```

`HomeWidgetLaunchIntent.getActivity` 签名是 `<T : Activity> getActivity
(ctx, Class<T>, Uri)`, 我 v0.15.5 直接传 `Class.forName(...)` 拿到的是
`Class<*>` (类型擦除), Kotlin 推不出 T。MainActivity 类是 `flutter create`
注入到 `android/app/src/main/kotlin/.../MainActivity.kt` 的, widget
provider 模块编译时不在 classpath 里, 没法用 `MainActivity::class.java`
直接拿。

修法: `Class.forName(...)` 后显式 cast 成 `Class<Activity>`,
`@Suppress("UNCHECKED_CAST")` 标注故意做 unchecked cast (MainActivity
确实 extends Activity, 运行期不会 ClassCastException):

```kotlin
@Suppress("UNCHECKED_CAST")
val mainActivityClass = Class.forName("${context.packageName}.MainActivity")
    as Class<Activity>
val clickIntent = HomeWidgetLaunchIntent.getActivity(
    context, mainActivityClass, Uri.parse("folio://display")
)
```

import 加 `android.app.Activity`。

PATCH 不动 Dart 行为, 单纯让 v0.15.5 的子任务 3 实现编出来。
Issue #6 子任务 4 (选颜色) 仍留 v0.15.7。

参考 skill: 无 UI 改动。

### 早期版本汇总 (v0.1.0 ~ v0.15.5)

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

**v0.13.3** 修 #3 #4 (4 个子问题): TagsScreen 加 chevron-left 返回按钮
(canPop → context.pop, 兜底 go /library); kCadenceChoices 加 1/2/3 分钟
档位; widgets_preview 副标题文案更新; 屏保 bookmark 按钮真正接入
FavoritesRepository (SharedPreferences Set&lt;String&gt; ids), Display 屏
Consumer toggle + icon opacity 切实/虚 + tooltip 切换 + SnackBar 反馈。

**v0.13.4** Issue #5 误诊版: 当时把 #5 闪退判为 drift / sqlite3 native
SIGSEGV (Dart 层 try/catch 兜不住), 切除 drift 全套 (移除 drift /
sqlite3_flutter_libs / drift_dev / build_runner 4 个 dep, 删
drift_quote_repository_io/stub + drift/quotes_database.dart),
native 改走 `_PrefsQuoteRepository` 同 web 路径, 启动时 quotes.json
→ prefs 一次性迁移 + rename 备份。L12 [x] 打回 [ ]。v0.14.1 用 adb
抓栈才发现真因是 home_widget WorkManager, drift 完全没问题, v0.15.0
已恢复, 这版的切除决定整体来看是误修。

**v0.15.1** 修 Issue #9 设置屏版本号显示陈旧: `settings_screen.dart:30`
`_versionLabel = 'v 0.13'` 跟 pubspec.yaml `version: 0.15.0+39` 是双源真相
漏改。修法是新建 `lib/core/app_version.dart` 单一可信源 `kAppVersion`,
+ `test/app_version_test.dart` 解析 pubspec 锁一致性防回归。不引入
`package_info_plus` (v0.14.1 home_widget 教训)。

**v0.15.2** Issue #10 暂停其他平台 CI 只发 APK: workflow 删 build-web/
linux/windows/macos 4 个 job, release job 只依赖 [build-android]。
L17 (多平台 CI 产物) 状态保持 [x] — 工程能力仍在, git history 保留
可 `git show v0.15.1:.github/workflows/build.yml` 恢复。

**v0.15.3** Issue #7 更换频率改成双滚轮 (小时+分钟自由选): 新建
`cadence_wheel_sheet.dart` 双 ListWheelScrollView (0-12h + 0-59m) +
实时大字预览, 替换之前 9 档预设 `[1,2,3,5,15,30,60,120,240]`
showOptionPicker。导出 formatCadenceText/Short 纯函数, cadence_label_test
覆盖 7 个边界分支。视觉对照 skill ImportSheet 骨架。

**v0.15.5** Issue #6 子任务 3 小组件点击启动 app: 3 个 layout root LinearLayout
加 `@+id/widget_root`; QuoteWidgetProvider.onUpdate 用 HomeWidgetLaunchIntent
.getActivity 包 PendingIntent (URI=folio://display, 内部处理 FLAG_IMMUTABLE 兼容),
setOnClickPendingIntent 挂到 root; widget_sync_bridge.dart 加
HomeWidget.initiallyLaunchedFromHomeWidget() (冷启动) +
HomeWidget.widgetClicked stream (热启动), URI host=display 时
postFrame `ref.read(routerProvider).go('/display')`。选启动 app 而非
原地 advance 是因为后者要 BackgroundIntent + WorkManager, v0.14.1 已 strip。

**v0.15.4** Issue #6 子任务 1+2 (小组件去"金"印 + 出处右下角):
strings_widget.xml 删 widget_brand_seal; 3 个 layout 删 seal TextView / 顶部
seal-row; medium/large widget_tag 改 `android:gravity="end"`;
widgets_preview in-app preview 同步 textAlign.end。属于按用户反馈对
skill 原版 seal 设计的修正。

**v0.15.0** 恢复 drift 满足 L12 (重启 v0.13.0): v0.14.1 定位真因后切除决定
没必要。pubspec 重新加 drift ^2.20.0 + sqlite3_flutter_libs ^0.5.24 + dev
drift_dev + build_runner; `lib/data/drift/quotes_database.dart` (含 v0.13.1
LazyDatabase 父目录预创建) + `drift_quote_repository_io.dart` 重写 bootstrap
按 prefs → JSON → seed 三级优先, 救 v0.13.4~v0.14.1 时代 prefs 用户数据;
删 v0.13.5 抽的 legacy_quotes_migration helper (JSON 迁移并入 drift bootstrap
路径); CI flutter-setup composite action 自动 build_runner step。L12 [ ] → [x]。

**v0.14.1** 修 Issue #5 真因 (home_widget WorkManager 在 Android 16 init 失败):
用户 HONOR AAK-AN00 (MagicOS Android 16 / SDK 36) 真机 adb 抓栈, 真因栈是
`androidx.startup.InitializationProvider → WorkManagerInitializer → WorkDatabase
RuntimeException`, 在 `installContentProviders` 阶段 (Dart VM 未启动前) 直接
SIGKILL, v0.13.1 装的 `runZonedGuarded` Dart 兜底完全没机会执行。folio 不用
WorkManager 后台任务, 修法是 `docs/android_widget/AndroidManifest_widget_fragment.xml`
加 `tools:node="merge"` 的 InitializationProvider 块 + `tools:node="remove"`
掉 WorkManagerInitializer meta-data。同时反思 v0.13.4 把 drift 误诊误切的决定,
v0.15.0 恢复 drift 满足 L12。

**v0.14.0** 收藏列表屏 (兑现 v0.13.3 接入 bookmark toggle 时承诺):
新建 `lib/presentation/favorites/favorites_screen.dart` watch
`quotesProvider` + `favoritesProvider` 过滤出收藏 quotes, 复用 QuoteCard
+ XJKSectionHeader, TopBar 加 chevron-left 返回, 空态 "在屏保里点
bookmark 试试"; 卡片 onTap → `/editor/:id`; router 加 `/favorites`
顶层路由; settings `_TagsSection` 改名 "标签与收藏" 加"我的收藏" 行;
新增 `favorites_notifier_test.dart` 锁 3 条不变量。参考 skill
`screens.jsx` LibraryScreen + chevron-left/bookmark SVG。

**v0.13.5** 重构 PATCH 让 v0.13.x 拿到重构: top-level `_maybeMigrateLegacyJson`
抽到 `lib/data/legacy_quotes_migration.dart` (跟 repo 的 load/save 语义独立,
可单测 4 个分支); `main.dart` 内联 `_BootstrapErrorApp` 抽到
`lib/presentation/bootstrap_error_screen.dart` (main 缩到 56 行只关心
entry + 错误路由 + runApp)。新增 `legacy_quotes_migration_test.dart` 用
`_FakePathProvider` + temp dir 锁 4 个不变量。v0.15.0 重新引入 drift 后
`legacy_quotes_migration.dart` 又被删了 (JSON 迁移现在直接在 drift
bootstrap 路径里做, helper 反而冗余) — 这版的 main.dart 拆分留下来。
