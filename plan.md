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
- [ ] L07 · Android 桌面小组件 (小/中/大三尺寸)
- [ ] L08 · iOS 桌面小组件 + 全平台屏保 / 锁屏样式
- [x] L09 · 自定义背景图 (用户相册 + 内置纯色 + 纸纹叠加) — v0.7.0 (file_selector 选图 + protection gradient; Web 暂不支持)
- [x] L10 · 金句导出 / 导入 (剪贴板 JSON, 跨设备复制粘贴) — v0.3.0
- [x] L11 · 全文搜索 + 标签管理 + 智能分组 — v0.2.0 搜索 + v0.6.0 标签管理 (智能分组按"句数倒序自动归组")
- [ ] L12 · drift 持久化迁移 (替换 JSON 文件存储)
- [ ] L13 · go_router 路由 + Web 深链
- [x] L14 · 响应式适配 (手机 / 折叠屏 / 平板 / 桌面 / Web) — v0.5.0 max-width 640
- [ ] L15 · 国际化 (中文为主，预留 en 框架)
- [ ] L16 · 完整测试覆盖 (单元 + Widget + 集成)
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
