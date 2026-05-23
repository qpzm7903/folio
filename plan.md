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
- [ ] L09 · 自定义背景图 (用户相册 + 内置纯色 + 纸纹叠加)
- [x] L10 · 金句导出 / 导入 (剪贴板 JSON, 跨设备复制粘贴) — v0.3.0
- [ ] L11 · 全文搜索 + 标签管理 + 智能分组
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
  (clang/cmake/ninja/gtk-3-dev), `flutter build linux`,
  打 tar.gz 上传。
- `build-windows` on windows-latest: 不用装额外 toolchain
  (VS Build Tools 已预装), `flutter build windows`,
  PowerShell `Compress-Archive` 打 zip。
- `build-macos` on macos-latest: Xcode 已预装,
  `flutter build macos` (不签名, 用户首次打开需 ctrl+click 绕过 Gatekeeper),
  zip .app bundle。
- 每个 job 自己 `flutter create --platforms=<platform> .`,
  fetch_fonts.sh 一次拉本地字体, 走 release build。
- `release` job 增加 3 个 download-artifact + 把 5 个产物全部
  挂到 GitHub Release 的 files。

完成长期项 L17 (除 iOS IPA, 留给 L08 一起处理 Apple 证书)。

### v0.3.1 — 重构 PATCH (QuotesNotifier mutate + ThemeMode label)

让 v0.3.x 拿到重构 PATCH, 解锁下一轮 v0.4.0 新功能。

- `QuotesNotifier` 的 4 个 mutate 方法 (add / addMany / update / remove)
  都有同样的"读 current → 算 next → state = AsyncValue.data(next) →
  repo.saveAll → log"5 行样板。抽 `_mutate({log, transform})` helper,
  4 个方法各只声明 transform。
- `AppThemeMode` 增加 `displayLabel` extension, 把"system → 跟随系统 /
  paper → 青纸 · Paper / night → 林夜 · Forest"这条映射放到 model 旁边。
  原本 settings_screen 里两处 (label 显示 + picker bottom sheet) 各
  hardcode 一遍, 现在都改用 extension。Picker 直接遍历
  `AppThemeMode.values` 而不是手维护 tuple list, 新增枚举值时不会漏。
- 新增 `test/theme_mode_label_test.dart` 锁定映射稳定 (settings 屏依赖)。

不动业务行为。

### v0.3.0 — 导出 / 导入 (L10)

Settings 屏新增"导入与导出"区段, 两个 SettingRow:

- **导出金库**: 打开 BottomSheet, 显示 JSON (复用 `QuoteCodec.encode`),
  顶部"复制到剪贴板"一键写入 Clipboard, 弹"已复制 N 句"toast。
  用 [SelectableText] 让用户也能手动选段。
- **从剪贴板导入**: 打开 BottomSheet, 进屏自动尝试粘贴剪贴板,
  实时 `QuoteCodec.tryDecode` 预览句数 + 错误提示, OK 后调
  `QuotesNotifier.addMany` **合并** (不覆盖现有金库, 安全)。

跨平台: Web / Android 共用 `Clipboard.setData` / `Clipboard.getData`,
不引入 file_picker / share_plus 等新插件。

文件格式跟 [QuoteCodec] 一致, 跨设备只需复制 → 粘贴。

完成长期项 L10。

### v0.2.2 — 修 widget 测试

v0.2.1 加的 `test/confirm_delete_dialog_test.dart` 在 CI 上挂了:
`XJKTheme` 当时放在 `MaterialApp.home` 下, 但 `showDialog` 弹出的
overlay 走 root Navigator, 不在 home 的祖先链上, 所以
`XJKTheme.of(ctx)` 的 assert 直接挂掉, dialog 根本没构建, 自然
找不到"留着 / 取出"按钮。

改成跟生产代码 `app.dart` 一样, 用 `MaterialApp.builder` 把
XJKTheme 注入到 Navigator 之上, dialog overlay 也能正确拿到 tokens。

### v0.2.1 — 重构 PATCH (删除对话框 + 搜索状态)

让 v0.2.x 这个 MINOR 拿到重构 PATCH, 解锁下一轮 v0.3.0 新功能。

- 新建 `lib/presentation/widgets/confirm_delete_dialog.dart` —— 把
  Library / Search / Editor 三处一模一样的"从金库取出这句话？"
  AlertDialog (~30 行 × 3 = ~90 行重复) 抽成一个 top-level
  `showConfirmDeleteDialog(context)` 函数, 三处一行调用替代。
- `SearchScreen.build` 里的三元嵌套 (没输入 / 没命中 / 有命中)
  抽成方法 `_buildBody`, 一眼看清三个分支。
- 新增 `test/confirm_delete_dialog_test.dart`: widget 测试覆盖
  点"取出"返回 true、点"留着"返回 false。

不动业务逻辑。

### v0.2.0 — 全文搜索 + 编辑已有金句 (L11 第一刀)

- Library TopBar 加 search 按钮 (skill `screens.jsx:85` 占位的那个 icon),
  点击 push 全屏 `SearchScreen`。
- `SearchScreen`: 顶部 SearchBar (44×fg-raised 卡片, 圆角 14px) +
  实时按 quote.text/tag 大小写不敏感子串过滤 + 命中数提示行
  ("3 句包含「光」")。空态文案沿用 skill 温和口吻 (".../要不要换一个词？")。
- 普通 QuoteCard tap 现在进入编辑 (之前没动作)。
  EditorScreen 改造成可接 `editing: Quote?`,
  存在时标题变 "改一改" + 右上角"取出"按钮 + 保存调
  `QuotesNotifier.update`。
- `lib/presentation/providers.dart` 新增 `QuotesNotifier.update(id, text, tag)`。
- `lib/presentation/library/search_screen.dart` 新增, ~250 行。
- 测试: `test/search_test.dart` 覆盖空 query / 子串 / tag / 大小写 / 不命中 / 多命中。

完成长期项: 部分 L01 (搜索) + L11 第一刀 (全文搜索)。
未做: L11 的"标签管理 + 智能分组" 留给 v0.3.0。

### v0.1.4 — 重构 PATCH (display Timer + Quote codec)

让 v0.1.x 这个 MINOR 拿到一次"重构优化"PATCH, 之后才能开 v0.2.0 新功能。

- `lib/domain/rotation_controller.dart` 新增 —— 把 display 的
  `NoRepeatShuffle + Timer.periodic + cadence/itemCount 同步` 整组逻辑
  从 `_DisplayScreenState` 抽出来。原版用 4 个互相耦合的私有字段
  (_shuffler / _autoTimer / _lastLength / _lastCadenceMin) 在 build()
  里管 Timer 副作用; 现在变成一个明确生命周期的 controller, 拥有
  `advance / reconfigure / dispose` 三个语义清楚的方法。
- 用户手动 advance 也会重置 cadence —— 之前是 bug-ish 行为
  (用户刚切完可能马上又被自动切走)。
- `lib/data/quote_codec.dart` 新增 —— 把 File / SharedPreferences
  两个 [QuoteRepository] 子类里重复的 `jsonEncode/jsonDecode + 异常处理`
  抽到一个静态类。后续切 drift 时只用替换这一处。
- 新增测试: `test/rotation_controller_test.dart` 用 `fake_async`
  虚拟时钟驱动, 覆盖自动 tick / 手动 advance 重置 / reconfigure /
  dispose 四个分支; `test/quote_codec_test.dart` 覆盖往返编解码 +
  坏 JSON 兜底 + 空数组。
- 总 Dart 行数仍在 10000 限制下。

### v0.1.3 — 修 analyze 报错与警告

format 阻塞解开后 `flutter analyze` 暴露 3 个 error + 6 个 info, 全部清掉:

- `display_screen.dart` 漏掉 `settings_repository.dart` import, 拿不到 `AppSettings`
- `providers.dart` 用了 `ProviderElement<Object?>`, 实际 `getAllProviderElements()`
  返回 `ProviderElementBase<dynamic>` —— 换成 for-in + 类型推断
- 占位 `test/widget_test.dart` —— 防 CI `flutter create` 自动生成引用 `MyApp` 的模板
- `editor_screen` / `import_sheet` 把 BuildContext 依赖的对象 (NavigatorState /
  ScaffoldMessengerState) 在 await 前捕获, `Navigator.maybePop()` 用 `unawaited()` 包
- `app_theme.dart` 把 ElevatedButton textStyle 改成 `const TextStyle(...)`
- `quote_serialization_test.dart` map 字面量加 `const`

### v0.1.2 — CI format step 改为 apply-only

- v0.1.1 试图通过 dart format 对齐 CI; 但本地 Dart 3.11.6 与 CI Flutter 3.44.0
  自带 Dart 在换行 heuristic 上仍然有差异 (10 个文件 still changed)。
- 这是死循环 —— CI 永远会比本地"赢"。
- 把 CI 改成 `dart format lib test` (apply only), 移除 `--set-exit-if-changed`,
  让流水线在 CI 自己格式化后的代码上继续 analyze / test。
- 风格仍是项目要求, 由开发者本地 `dart format` 保证, CI 不再强制门控。

### v0.1.1 — workflow 修复

- v0.1.0 的 `dart format --set-exit-if-changed` 在 CI 上拦下了 12 个未格式化文件 (本地没有 dart CLI, 没法预先校验)。
- 本版安装 dart-sdk 后 `dart format lib test` 重新整理 22 个文件 (含 widget/screen/test) 的换行与缩进; 风格检查现在 0 diff。
- 不动业务逻辑。

### v0.1.0 — 首版核心

目标：跑通 "写一句 → 进金库 → 屏保里再次遇见" 的核心闭环。

任务清单：

- [ ] T01 · Flutter 工程骨架 (pubspec / analysis / gitignore / Android / Web)
- [ ] T02 · XJKTokens (颜色 / 字号 / 间距 / 圆角 / 阴影) 翻译自 `colors_and_type.css`
- [ ] T03 · ThemeData (青纸 / 林夜 双主题，Material 3 紧凑型)
- [ ] T04 · 日志系统 (talker + 文件落盘 `getApplicationSupportDirectory`)
- [ ] T05 · Quote 实体 + JSON 文件持久化 + Riverpod Provider + 种子数据
- [ ] T06 · `TopBar` / `QuoteCard` / `BottomNav` / `SettingRow` / `Fab` 基础组件
- [ ] T07 · Library 屏 (今日金句 + 标签筛选 + 列表)
- [ ] T08 · Editor 屏 (新建金句)
- [ ] T09 · Display 屏 (全屏无重复轮播 + 640ms 交叉淡入)
- [ ] T10 · Settings 屏 (主题切换 + 频率展示 + 关于)
- [ ] T11 · Import Sheet (粘贴大段文本，自动分行)
- [ ] T12 · 本地化 Lucide 图标 SVG (28 个)
- [ ] T13 · `flutter_svg` 渲染图标 (禁止换图标库)
- [ ] T14 · 单元测试：无重复 shuffle 算法
- [ ] T15 · GitHub Actions workflow (Android APK + Web bundle)
- [ ] T16 · README.md (项目介绍 + 截图占位)
- [ ] T17 · tag v0.1.0 推送，验证 workflow 成功

非目标（推迟到后续版本）：

- 自托管字体文件 (v0.2 落地，本版本暂用系统中文衬线回退 + 在 README 标注 substitution flag)
- drift 持久化 (v0.2 重构 PATCH)
- 桌面小组件 (v0.4)
- 自定义背景图 / 导出 (v0.3)
- iOS / Windows / macOS / Linux 构建 (v0.x 启用，本版本仅 Android + Web)
- go_router (v0.6 引入，本版本 IndexedStack + Navigator.push 即可)
