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

### v0.15.5 — Issue #6 子任务 3 (小组件点击启动 app 到屏保)

Issue #6 4 个子任务进度:
1. ✅ 去"金"字 (v0.15.4)
2. ✅ 出处放右下角 (v0.15.4)
3. ✅ 点击切换金库 — **本版**: 实现为"点击启动 app 到 /display 屏保",
   用户能立即看到金句轮播 + 在屏保里手动切换。完整的 widget 端原地
   advance (不启动 app) 需要 home_widget BackgroundIntent + WorkManager,
   而 v0.14.1 刚因为 WorkManager 在 Android 16 启动崩才把它 strip 掉,
   所以选最稳的"启动 app"方案。
4. ⏳ 支持选颜色 (留 v0.15.6)

实施细节:

- `docs/android_widget/app/src/main/res/layout/quote_widget_*.xml`:
  3 个 layout 的 root `LinearLayout` 加 `android:id="@+id/widget_root"`,
  让 `setOnClickPendingIntent` 有 target view 可挂。
- `docs/android_widget/app/src/main/kotlin/app/folio/widget/QuoteWidgetProvider.kt`:
  `onUpdate` 里用 `HomeWidgetLaunchIntent.getActivity(ctx, MainActivity, Uri)`
  封装 `PendingIntent`, URI 用 `folio://display` scheme;
  `setOnClickPendingIntent(R.id.widget_root, ...)` 挂到根容器, 整张
  widget 点击都触发。HomeWidgetLaunchIntent 内部已处理 API 23+ 的
  `FLAG_IMMUTABLE` 兼容, minSdk 21 不踩坑。
- `lib/presentation/widget_sync_bridge.dart`:
  initState 起 `HomeWidget.initiallyLaunchedFromHomeWidget()` (冷启动
  缓存的 URI) + `HomeWidget.widgetClicked` Stream (热启动后续点击),
  URI host=`display` 时用 `WidgetsBinding.instance.addPostFrameCallback`
  + `ref.read(routerProvider).go('/display')` 跳路由。
  - post-frame 调度避开 "navigator not yet attached" — router delegate
    在 MaterialApp.router 绑定前不能 `.go()`。
- Web / iOS / Desktop: bridge 仍执行 (HomeWidget API 在不支持平台是
  no-op), 不会崩。

参考 skill: 无 UI 改动 (沿用 v0.15.4 已经按 widgets.jsx 视觉重构过的
3 个 layout)。

### v0.15.4 — Issue #6 子任务 1+2 (小组件去"金"印 + 出处右下角)

用户 Issue #6 是个组合诉求, 含 4 个子任务:
1. ✅ 去"金"字
2. ✅ 出处放右下角
3. ⏳ 点击切换金库 (留 v0.15.5)
4. ⏳ 支持选颜色 (留 v0.15.5)

本版完成视觉调整部分 (1+2), 改动面 Android RemoteViews + in-app preview:

- `docs/android_widget/app/src/main/res/values/strings_widget.xml`:
  删 `widget_brand_seal` 字符串。
- 三个 layout (`quote_widget_small/medium/large.xml`):
  - small: 删顶部 28dp seal 圆印, 金句改全屏垂直居中。
  - medium: 删底部 row 里的"金"印 TextView, 留 `widget_tag`,
    `android:gravity="end"` 让出处右对齐到 row 末尾。
  - large: 删顶部整块 `seal-row` (含"金"印 + "小金库" brand),
    底部出处 `gravity="end"` + maxLines=1。
- `lib/presentation/widgets_preview/widgets_preview_screen.dart`:
  in-app preview 三个 mock 跟 native 视觉保持一致, 去"金"印,
  attribution `textAlign: TextAlign.end` 右对齐。

不动的部分:
- `xjk_widget_seal_bg.xml` / `xjk_widget_seal_bg_dark.xml` drawable
  暂留 (没引用, 但下版恢复 "selectable seal" 时可能复用), 体积可忽略。
- iOS Widget Extension (`docs/ios_widget/Swift/QuoteWidget.swift`)
  也含"金"字, 但 CI 当前不构建 iOS (L08 等开发者证书),
  跟子任务 3+4 一起在 v0.15.5 同步, 避免本轮改动面过大。

参考 skill: `ui_kits/android-widgets/widgets.jsx` (本轮的"去金/出处右下"
属于按用户反馈对设计稿做的修正, 偏离 skill 原版 seal 设计是有意的;
其余布局间距 / 字号 / 字体 / 圆角仍严格沿用 skill `colors_and_type.css`)。

### v0.15.3 — Issue #7 更换频率改成双滚轮 (小时+分钟自由选)

用户 Issue #7: "更换频率切换成类似时间滚轮, 让用户自己选时间频率"。
之前 settings 屏频率 picker 是 9 档预设 `[1,2,3,5,15,30,60,120,240]`,
用 `showOptionPicker` 列出固定项, 用户不能选 7 分钟 / 1 小时 45 分钟
这种"中间值"。

实施:

- 新建 `lib/presentation/settings/cadence_wheel_sheet.dart`:
  双 `ListWheelScrollView` (小时 0-12 + 分钟 0-59), 实时大字预览
  `每 X 小时 Y 分钟换一句`, 保存按钮当总分钟数 ≥ 1 才可点。
  - 视觉对照 skill `screens.jsx:244-273` 的 ImportSheet 骨架:
    grabber (40×4 px) + h2 衬线标题 + 副标题斜体 + 内容区 + 主按钮 (accent
    底色 + radius-lg)。
  - 滚轮中央选中行用 `accentSoft × 0.35` 软高亮 (skill --accent-soft),
    diameterRatio 1.6 + perspective 0.003 让圆筒接近平面感, 配合衬线字体
    远端 opacity 衰减实现纸感。
  - 避开 `CupertinoTimerPicker` (iOS 蓝跟青纸/林夜衬线冲突)。
  - 顶部导出两个纯函数 `formatCadenceText` (滚轮大字预览) +
    `formatCadenceShort` (SettingRow value 列), 边界规则:
    `<60` → "X 分钟", `整小时` → "X 小时", `混合` → "X 小时 Y 分钟"。
- `lib/presentation/settings/settings_screen.dart`: `_pickCadence` 改调
  `showCadenceWheelSheet`; SettingRow value 改用 `formatCadenceShort`;
  删 `kCadenceChoices` 常量和 `cadenceLabel(int)` 函数 (已被滚轮 +
  format 函数替代, 不再有"九选一"的概念)。
- `test/cadence_label_test.dart` 重写: 覆盖 `formatCadenceText` 4 个分支
  (0/纯分/纯时/混合) + `formatCadenceShort` 3 个分支。

参考 skill: `colors_and_type.css:85-104` (字号/间距/radius token),
`ui_kits/android-app/screens.jsx:244-273` (ImportSheet 骨架)。

### v0.15.2 — Issue #10 暂停其他平台 CI, 只发 Android APK

用户 Issue #10: "版本可以先只发 apk 的, 待彻底稳定后再出其他的"。
鉴于近期 #5 (Android 16 启动崩) / #6 (小组件) / #7 (频率选择)
/ #8 (壁纸) 都是 Android 端体验问题, 收敛火力 makes sense。

实施:

- `.github/workflows/build.yml`: 删除 `build-web` / `build-linux` /
  `build-windows` / `build-macos` 4 个 job (每次省 ~3-5 分钟 CI 时间);
  `release` job 的 `needs:` 从 5 个改成只依赖 `[build-android]`,
  `files:` 只挂 APK。git history 保留, 想恢复跑
  `git show v0.15.1:.github/workflows/build.yml` 拿回原文件即可。
- workflow 顶部加 banner 注释说明 Issue #10 决策, 以及恢复路径。
- README "构建产物" 一节同步: 列表只剩 Android APK, 附 git show 恢复指令。

**长期规划影响**: L17 (多平台 CI 产物) 长期规划状态保持 `[x]` —
工程能力 (脚本 / setup composite action / 字体 fetch) 仍在, 只是发布
管线短期不挂非 Android 产物。等 Android 端验完 #6/#7/#8 再恢复。

`pubspec.yaml` 0.15.1+40 → 0.15.2+41, `kAppVersion` 同步。

参考 skill: 无 UI 改动。

### v0.15.1 — 修 Issue #9 (设置屏版本号显示陈旧)

用户报 Issue #9: "设置里面最下面显示的版本号不对"。根因是
`settings_screen.dart:30` 的 `_versionLabel = 'v 0.13'` 是个手维护字符串,
跟 `pubspec.yaml` 的 `version: 0.15.0+39` 是**双源真相**, 我从 v0.13
之后 5 次 bump pubspec 都漏改这一处。

修法不是改字符串, 而是引入**单一可信源**:

- 新建 `lib/core/app_version.dart` 导出 `const String kAppVersion`,
  每次发版只改这一处和 pubspec, 其它代码 (settings footer / 未来日志
  里的 banner / about 屏) 全从它派生。
- 不引入 `package_info_plus` 读运行时 native bundle 版本 — v0.14.1 刚因
  `home_widget` 拉进 `androidx.work` 在 Android 16 上启动崩 (Issue #5),
  教训告诉我们能用编译期常量解决就不要再加 native 插件依赖。
- `settings_screen.dart` 把 `_versionLabel` 改成 `'v $kAppVersion'`。
- 新增 `test/app_version_test.dart` 解析 `pubspec.yaml` 锁住 `kAppVersion`
  与 `version:` 字段的 MAJOR.MINOR.PATCH 部分一致, 漏改一处 CI 红牌。
  这是这个修复的**防回归核心**, 比修字符串本身更重要。

`pubspec.yaml` bump 到 `0.15.1+40`。

参考 skill: 无 UI 改动, _VersionFooter 视觉沿用 v0.1.0 对照
`screens.jsx` SettingsScreen footer 的实现。

### 早期版本汇总 (v0.1.0 ~ v0.15.0)

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
