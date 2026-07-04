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
  ① 环境搭建 — 工具链部分已完成 (免登录镜像全链路, doctor 全绿, wiki 01);
  ② 关键依赖编译验证 — 已完成 (entry-default-unsigned.hap 产出, 3 个 ohos
  插件编译进 modules.abc, sqlite3 系统库方案代码就位待真机验证, wiki 02);
  ③ 签名装机 — 已跑通 (wiki 03): AGC 调试证书签名 (证伪 OpenHarmony 自签:
  Mate 80 拒装 code:9568257 + 绕过开关 errNum 1001) → hdc 装机 →
  **Folio 在 Mate 80 / HarmonyOS 6 上完整运行** (金库浏览/屏保/主题/导航,
  种子金句正常渲染)。
  降级说明: path_provider/shared_preferences/file_selector 的 ohos 联邦插件
  受 flutter_ohos 工具链 bug 阻塞 (upstream-issues #1), 走内存 prefs 降级
  (bootstrap 守卫)。**v0.18.1 起数据已真持久化**: 通过 OhosPrefsBridge 自写
  channel 把内存 prefs 快照落到 ArkTS @ohos.data.preferences (绕开上游 bug),
  启动读回, 用户导入的金句/设置/收藏跨重启保留。file_selector 选图仍降级关闭。
  包名 app.folio.quotes (ohos 保留字 + 三段约束)。
  ohos/ 工程直接进仓库 (签名材料 gitignore), 鸿蒙构建 v1 不进 CI。
  过程要求: 每个里程碑的踩坑与经验随做随归档到 docs/wiki/ohos/, 不攒到最后补写。
  wiki 以对外分享为目标写作: 可复现步骤 + 工具/SDK 版本号 + 失败现象与修法;
  对外发布前脱敏 (不含 p12/证书/UDID/账号信息)
- [ ] L21 · 鸿蒙服务卡片 (ArkTS 重写 L18 timeline 刷新机制) — v0.18 进行中。
  设计推演见 docs/adr/0002-ohos-service-card.md (数据桥走自写 MethodChannel +
  ArkTS 侧 @ohos.data.preferences, 绕开上游联邦插件 #1, 不必等上游修复)。
  里程碑①②③ 见 docs/wiki/ohos/04-服务卡片.md。**里程碑①(静态卡片)②(数据桥)
  已真机验证**: 编译+Mate 80 装机+form 注册 (bm dump extensionTypeName=form)+
  app 拉起渲染不崩 (自写 channel 注册证实, ADR 0002 核心假设成立)。
  @kit.FormKit / @kit.ArkData import 在 fork 可用、fork 支持 extensionAbilities
  + 自写 MethodChannel (风险均证伪)。里程碑③ + 客户要的"换一句"刷新按钮 +
  30min 自动刷新 **已真机验证通过 (用户确认)**: 卡片显示库内真实金句、点
  "换一句"换下一句、30min 自动换句。L21 核心功能完整可用 (后续可选: 卡片配色
  跟随主题、多尺寸、打开 app 主动推送刷新桌面卡片)。
  "设为壁纸" 在鸿蒙为系统 API 大概率三方不可用, L20 spike 顺带验证后决定是否永久放弃
- [x] L22 · 设计系统 2.0 (传统色六主题 + 屏保多版式, v0.25.0 全 9 版式收官) — 规划 v0.18.2(重构) + v0.19.0(功能)。
  对齐 2026-06-16 重新生成的 `xiao-jinku-desig` skill: 主题从 青纸/林夜 二元扩成
  六主题 (青纸 / 天青 / 月白 / 绛霞 / 林夜 / 青黛, 2 浅绿 + 4 传统色, 2 暗),
  屏保从单一版式扩成可循环多版式 (精选 5 个: 页 / 满 / 印 / 时 / 片), 引入
  黄金比竖向锚点 (0.382) + 句长分级 q-scale 自适应字号。纯 Dart UI, 全平台通用,
  以 Mate 80 Pro / HarmonyOS 6 真机验收。余下 4 版式 (竖 / 引 / 条 / 织) 已在 v0.25.0 补齐 (全 9 版式)。
- [x] L23 · 标签管理 (设计系统标签 2.0) — 规划 v0.22.1(重构铺路) + v0.23.0(功能)。
  **2026-07-04 范围修正**: 逐文件核实 2026-06-29 同步的 `xiao-jinku-desig` skill
  (screens.jsx / app.jsx / kit.css / card-tags.html), 设计源数据模型仍是**单标签**
  `q.tag`, 全库无"多标签/一句多标签"概念 —— 此前规划的 `tags: List<String>` 迁移 +
  编辑屏多选选择器 + 标签管理 Sheet 均属对 skill 的误读, 按 prompt.md "禁止凭空设计"
  放弃, drift schema 不动。设计源真实新增的是 **tag-row 内联管理模式** (LibraryScreen
  `managingTags`): 行末 `.tag.manage-tag` "✎ 管理/✓ 完成" pill 切换, 管理态下具名标签
  变虚线可删 (`.tag.removable` + x), 点删弹确认 (「删除标签会移到未分类, 句子不删」),
  删除后句子归「未分类」(app.jsx onDeleteTag), 若正筛选该标签回「全部」。v0.22.1 的
  接缝收敛 (`filterQuotesByTag` / `kAllTagsLabel`) 依旧是本条的落点。
- [x] L24 · 屏保轮播续位 (HANDOFF 第二轮收尾) — v0.26.0: 洗牌顺序以 quote-id
  序列持久化 (prefs), 重启接着上次位置; 金库内容变更 (id 集合不一致) 自动重洗。

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
- v0.18 · 鸿蒙服务卡片 (L21) + 设计系统 2.0 重构铺路 (v0.18.2 主题注册表)
- v0.19 · 设计系统 2.0 功能 (L22, 传统色六主题 + 屏保精选 5 版式)

## 短期规划 (Short-term)

- v0.16.2 (已完成) · 重构 PATCH: 平台判断收敛为能力开关 (为 L20 铺路) + lint 清零
- v0.17.0 (已完成) = L20 鸿蒙 6.0 适配, 里程碑 ①②③ 见长期规划 L20 条目。
  每完成一个里程碑, 同步归档一篇 wiki 到 docs/wiki/ohos/。
- v0.17.1 (已完成) · 重构 PATCH: 收敛"平台契约"层重复与魔法值 (为 L21 铺路)
- v0.18 (进行中) = L21 鸿蒙服务卡片 (用户已选定主攻方向)。里程碑① 静态卡片
  scaffold 已真机验证 (编译+装机+form 注册), 见下方 v0.18.0-dev 版本日志;
  里程碑②(数据桥)③(刷新闭环)待续。完整跑通 + 桌面卡片可视验收后发 v0.18.0。
- v0.21.3 (已完成) · 重构 PATCH: 卡片按钮图标 → 刷新样式 + 消除 widget_color_picker magic color
- v0.22.0 (开发完成) · 功能 MINOR: 金库批量操作 (多选 + 批量取出)。触发依据:
  无开放 issue、最新 workflow 全绿、0.21.x 已有 v0.21.3 重构 PATCH (prompt.md
  优先级落到"开发新功能")。严格对齐 `xiao-jinku-desig` skill 的 select-mode 设计
  (screens.jsx LibraryScreen + components.jsx QuoteCard.selectable + kit.css
  `.select-bar` / `.qcheck` / `.action-bar`)。
- v0.22.1 (已完成) · 重构 PATCH: 收敛标签/选择模式接缝 (`filterQuotesByTag` 入
  领域层 + `kAllTagsLabel` 哨兵 + `QuoteCard` source→tag / 编辑屏 _src→_tag 命名诚实
  + 满/时 版式落款去重), 为 v0.23.0 多标签迁移铺路。行为等价, 无 UI 变化。
- v0.23.0 (已完成) · 功能 MINOR: 标签管理内联模式 (= L23, 范围已按设计源修正,
  见长期规划 L23 条目): 库筛选行末"✎ 管理"pill → 管理态虚线可删标签 + 确认弹窗,
  删除后句子归「未分类」虚拟标签 (空 tag 的展示名, 新哨兵 `kUntaggedLabel`),
  tag-row 在存在无标签句时追加「未分类」pill 可筛选。无 schema 迁移。
- v0.23.1 (已完成) · 重构 PATCH: `_mutate` 落盘失败错误处理 (state 回滚 +
  用户反馈), 出自 v0.23.0 多维审查遗留 F9。
- v0.24.0 (已完成) · 功能 MINOR: 批量导入增强 (用户需求"导入文本批量建句",
  设计依据 HANDOFF.md 第三轮): 分句纯函数入域层 + **去重** + 勾选列表保留
  (默认全选, 点行切换, 按钮显示选中数, 只收入勾选句)。
- v0.24.1 (已完成) · 重构 PATCH: 勾选组件收敛 —— 抽共享 `XJKSelectCheck`
  (金库多选卡片 / 导入勾选行共用, 消除 .qcheck 视觉复制), 导入勾选行加
  InkWell 按压反馈 + Semantics 复选框语义。行为等价。
- v0.25.0 (已完成) · 功能 MINOR: 屏保版式补齐 (L22 遗留 竖/引/条/织 4 版式,
  注册表 5→9 且顺序对照设计源 LAYOUTS; `splitClauses` 分句纯函数入域层)。
- v0.25.1 (已完成) · 重构 PATCH: 版式样式去重 (`_metaStyle`/`_italicStyle`/
  `_accentInk` 三个共享 helper 收敛 9 版式重复 TextStyle/配色, 行为等价,
  display_layouts.dart 788→764 行, 缓解 800 行上限与 LOC 预算)。
- v0.26.0 (已完成) · 功能 MINOR: 屏保轮播续位 (= L24, HANDOFF 第二轮
  "下次开机接着上次的位置"): NoRepeatShuffle 快照/恢复 + id↔索引翻译纯函数 +
  RotationStateRepository (prefs) + display 屏 advance 落盘。
- v0.26.1 (开发中) · 重构 PATCH: 测试基建收敛 —— FakeQuoteRepository /
  quotesContainer / awaitQuotesLoaded 提取 test/support 共享, 消除
  test_harness 与 3 个单测文件的四份重复; 行为等价, 测试语义不变。

### v0.18.2 (已完成, CI 绿) · 重构 PATCH — 主题系统注册表化 + 屏保版式宿主抽象 (L22 铺路)

> 触发依据: 0.18 MINOR 在 plan.md 尚无已完成的重构 PATCH (prompt.md 优先级规则)。
> 目标是把"二元主题 + 单一屏保版式"的存量代码重构成"可扩展注册表",
> 为 v0.19.0 的 6 主题 / 5 版式让路, **本版无可见 UI 变化**, 行为等价。
> 设计权威来源: `xiao-jinku-desig` skill 的 README + colors_and_type.css。

- [ ] T1 · 主题标识与亮暗解耦: `AppThemeMode {system, paper, night}` 重构为
  `AppThemeId` 注册表 (每个主题带 `key / 中文名 / en / isDark`), `system` 作为
  独立"跟随系统"开关保留 (映射到一组浅/暗默认对)。当前只注册 paper / night 两项,
  不新增主题 (新增留 v0.19.0)。`app_settings.dart` 持久化键向后兼容旧值。
- [ ] T2 · `XJKTokens.paper()/.night()` 工厂收敛为 `XJKTokens.forId(AppThemeId)`
  的数据驱动表 (token 集按 id 查表), 保持现有两套 token 值逐字不变。
- [ ] T3 · `app.dart` 主题装配改为"由选中主题的 `isDark` 推导 brightness", 不再写死
  `ThemeMode.light/dark` 二分; `resolveIsDark` 重构为查 `AppThemeId.isDark`。
- [ ] T4 · `display_screen.dart` 抽出 `DisplayLayout` 宿主抽象: 把当前固定版式包成
  `LayoutPage`(默认), 引入 `DisplayLayout` 接口 (输入 quote + tokens → Widget) +
  版式注册表 (本版仅 1 项)。轮播/淡入/壁纸/收藏等编排逻辑与版式渲染分离。
- [ ] T5 · 测试: `app_theme_test` / `theme_registry_test` 锁注册表一致性 (id↔token↔isDark)
  与旧值不漂移; `display_layout_host_test` 锁宿主-版式分离不变量。flutter analyze 0 警告。
- [ ] T6 · 版本号 0.18.1+56 → 0.18.2+57 (pubspec + Android + kAppVersion 单一源)。

### v0.19.0 (开发完成, 待 Mate 80 真机验收) · 功能 MINOR — 传统色六主题 + 屏保精选 5 版式 (= L22)

> 兑现重新生成的设计 skill。**Mate 80 Pro / HarmonyOS 6 真机验收**(纯 Dart UI,
> 经现有 ohos 构建 + hdc 装机)。视觉/配色/字体严格对齐 skill, 实现前先读对应参考文件
> (colors_and_type.css / components.jsx / display-layouts.jsx / kit.css)。

- [ ] T1 · 4 个传统色主题落 token: 天青 Celadon(浅) / 月白 Moon White(浅) /
  绛霞 Cinnabar(浅) / 青黛 Ink Indigo(暗), 逐字对照 colors_and_type.css 的
  `[data-theme=...]` 色值进注册表。主题循环顺序 晨→昏: 青纸→天青→月白→绛霞→林夜→青黛。
- [ ] T2 · 设置屏"主题"行从二元切换改为六主题循环/选择 (中文名·en 标签),
  文案与 `themeByKey/nextTheme` 对齐 components.jsx; 跟随系统在浅/暗各取一默认。
- [ ] T3 · 黄金比锚点: 居中版式 (页/满) 用 `Spacer(flex: 382)` / `Spacer(flex: 618)`
  上下夹住 quote, 长句填满时优雅退化 (对齐 README 黄金比一节)。
- [ ] T4 · 句长分级 q-scale: 中文字数→tier→字号乘子 (tiny≤10:1.15 / short≤18:1.0 /
  medium≤30:0.82 / long≤46:0.64 / xlong:0.5), 各版式字号 = 基准 clamp × q-scale
  (基准值对照 kit.css 各 `.ds-*-quote`)。纯函数 + 单测覆盖 5 个边界。
- [ ] T5 · 精选 5 版式实现 (对照 display-layouts.jsx + kit.css `.ds-*`):
  页 Page(书页: 页眉 no.罗马数字+分隔线+标签 / 黄金比正文 / 页脚) ·
  满 Full-bleed(quote 即壁纸, 黄金比锚点) ·
  印 Stamped(首字巨型抹茶印章 + 余文) ·
  时 Lockscreen(时钟+日期 + 叶纹底 + quote 作题注, 黄金比分割) ·
  片 Card on field(纹理场 + 四角纸卡 + 标签/正文/分隔/页脚)。
- [ ] T6 · Display 屏接版式循环: 底部新增"切版式"按钮 (循环 5 个) + 右上 layout-pip
  版式名标签 (1.8s 淡出, 对照 screens.jsx DisplayScreen + kit.css `.layout-pip`)。
  当前选中版式持久化 (shared_preferences, 复用设置仓)。
- [ ] T7 · 测试: 六主题注册表完整性、版式注册表 5 项、q-scale 边界、Display 版式循环
  widget 测试; flutter analyze 0 警告 + dart format。代码量复核 < 10000 行
  (当前 7406, 预算约 2.6k, 5 版式 + 4 主题预计 ~1.2k, 留余量)。
- [ ] T8 · 版本号 0.18.2+57 → 0.19.0+58。真机验收点: 六主题切换正确 (含 2 暗)、
  屏保 5 版式循环渲染不崩、长短句字号自适应、黄金比锚点观感。
- [ ] T9 · 文档: README 更新设计 2.0 介绍, plan.md 状态回写, L22 勾连。

---

## 版本日志

### v0.26.1 (开发中) — 重构 PATCH: 测试基建收敛 (test/support)

> 触发依据: 无开放 issue、CI 全绿、0.26.x 尚无重构 PATCH (prompt.md 优先级 #3)。
> lib 侧 analyze 已零 info/warning、文件均 <800 行, 本版把重复最重的测试基建
> 收敛: FakeQuoteRepository 与"等首次加载"轮询在 4 个文件里各有一份副本。

- [ ] T1 · 新建 test/support/quotes_test_support.dart: FakeQuoteRepository
  (从 test_harness 迁出, harness re-export 保持既有 import 兼容) +
  quotesContainer(seed) + awaitQuotesLoaded(c)。
- [ ] T2 · rename_tag / tags_provider_untagged / quotes_mutate_failure 三个
  测试改用共享 helper, 删除各自的 _FakeRepo/_container/_ready 副本
  (_ExplodingRepo 因 explode 语义特殊保留)。
- [ ] T3 · 全部测试语义不变通过; analyze 0 警告; 版本 0.26.1+77。

### v0.26.0 (已完成, CI 绿) — 功能 MINOR: 屏保轮播续位 (L24)

> 触发依据: 无开放 issue、CI 全绿、0.25.x 已有 v0.25.1 重构 PATCH → 开发新功能。
> 盘点长期规划: 非鸿蒙项全部落地 (L22 勾选), 从设计 skill HANDOFF 路线图补上
> 第二轮唯一缺口 —— "shuffle 顺序持久化, 下次开机接着上次的位置"。存储选
> prefs 而非 HANDOFF 提的 drift 表: 与收藏/设置同惯例, Web/鸿蒙桥同样生效,
> 数据量仅一份 id 列表 (存储选型属工程决策, 设计 skill 权威只约束 UI)。

- [x] T1 · 域层: `NoRepeatShuffle.restore` 命名构造 + `order/position` 快照
  getter; `mapOrderToIndices` (rotation_resume.dart) 把持久化 id 序翻译回当前
  索引, 集合不一致/重复/长度不符 → null 重洗。TDD 10 例。
- [x] T2 · 数据层: `RotationStateRepository` (prefs key folio.display.rotation.v1,
  JSON {ids,pos,round}), 损坏数据返回 null 不抛。TDD 4 例。
- [x] T3 · 接线: RotationController 加 restore 入参 (界内校验);
  display_screen 首建时读档翻译, 每次换句 (手动/定时) fire-and-forget 落盘。
- [x] T4 · analyze 0 警告; 版本 0.26.0+76 (pubspec + kAppVersion)。

### v0.25.1 (已完成, CI 绿) — 重构 PATCH: 版式样式去重 (三共享 helper)

> 触发依据: 无开放 issue、CI 全绿、0.25.x 尚无重构 PATCH (prompt.md 优先级 #3)。
> v0.25.0 后 display_layouts.dart 达 788 行逼近 800 上限, 总 LOC 9110/10000;
> 本版收敛 9 版式间重复样式, 行为等价瘦身。

- [x] T1 · 抽 `_metaStyle` (sans-ui 11px 眉注/类目, 3 处) / `_italicStyle`
  (serif-italic 斜体落款家族, 6 处含 _attributionLine) / `_accentInk`
  (photo→leaf300 否则 accent, 引/织 2 处) 三个模块级 helper。
- [x] T2 · 行为等价: 现有版式渲染/落款测试全过; analyze 0 警告;
  版本 0.25.1+75 (pubspec + kAppVersion)。

### v0.25.0 (已完成, CI 绿) — 功能 MINOR: 屏保版式补齐 (竖/引/条/织)

> 触发依据: 无开放 issue、CI 全绿、0.24.x 已有 v0.24.1 重构 PATCH → 开发新功能。
> 兑现 L22 遗留: "余下 4 版式 (竖/引/条/织) 留后续"。视觉对照
> display-layouts.jsx (LayoutVertical/Pull/Ribbon/Interleave) + kit.css
> `.ds-vertical/.ds-pull/.ds-ribbon/.ds-interleave` 与主题 token 映射。

- [x] T1 · 域层 `splitClauses` (quote_clauses.dart): 中文标点分句留标点,
  无标点/空串整句回落 —— 织版式用。TDD 5 例。
- [x] T2 · 4 版式实现: 竖 (Wrap 竖排逐字右起分列 + 立轴线 + 「金」印 24px
  bamboo500) / 引 (120px 起引号 accent, photo 下 leaf300 + 底部落款/56px 收引号)
  / 条 (通宽纸带 bgRaised + border2 上下边, photo 背景仍纸色) / 织 (罗马数字
  72px + 分句发丝线 + 右下类目)。注册表 5→9, 顺序对照设计源。
- [x] T3 · 测试: 注册表断言更新 (9 款/顺序/key 唯一), 渲染遍历自动覆盖新版式;
  analyze 0 警告; 版本 0.25.0+74。
- [x] T4 · 内联审查: 设置层只存 key (默认 page) 无硬编码列表, display_screen
  注册表循环 + 未知 key 回落 0; 首轮 CI 红定位为测试断言与竖版式逐字结构
  不兼容 (整词子串匹配不到), 改单字匹配后绿。

### v0.24.1 (已完成, CI 绿) — 重构 PATCH: 勾选组件收敛 (共享 XJKSelectCheck)

> 触发依据: 无开放 issue、CI 全绿、0.24.x 尚无重构 PATCH (prompt.md 优先级 #3)。
> 落实 v0.24.0 审查中因子代理限额未及对抗验证、但复核成立的三条整改。

- [x] T1 · 抽 `lib/presentation/widgets/select_check.dart` 的 `XJKSelectCheck`
  (kit.css `.qcheck`): quote_card 私有 `_SelectCheck` 删除改复用 (原 top:2
  margin 移到调用点), 导入勾选行同款 —— 一份视觉两处用, 防复制漂移。
- [x] T2 · 导入勾选行: GestureDetector → Material+InkWell (按压反馈, 触摸目标
  含 padding 增高), Semantics(checked, label) 报为复选框供读屏。
- [x] T3 · 行为等价: 现有 import/select-mode 测试全过; analyze 0 警告;
  版本 0.24.1+73 (pubspec + kAppVersion)。

### v0.24.0 (已完成, CI 绿) — 功能 MINOR: 批量导入增强 (分句去重 + 勾选保留)

> 触发依据: 无开放 issue、CI 全绿、0.23.x 已有 v0.23.1 重构 PATCH → 开发新功能。
> 需求来源: 用户需求TODO "导入文本批量建句"; 设计依据: 设计 skill HANDOFF.md
> 第三轮 ("自动按换行符分句, 去重, 去空白, 让他在列表里勾选保留。参考 ImportSheet"),
> 勾选框视觉沿用 kit.css `.qcheck` (22px 圆 + accent 实底 + 13px check)。

- [x] T1 · 域层纯函数 `splitImportLines` (lib/domain/import_lines.dart):
  分句/trim/丢空行/**去重保序**; 从 ImportSheet 内联 `_splitLines` 抽出。
  TDD 5 例 (分句/连续换行/去重保序/trim 后重复/空输入)。
- [x] T2 · ImportSheet 勾选列表: 识别行以行文本为键默认全选, 点行切换
  (`.qcheck` 圆形勾选 + 未选行压淡), 按钮"全部收入金库/收入 N 句", 只收入
  勾选句; 全取消则按钮禁用; 内容包滚动防小屏溢出。widget 测试 4 例。
- [x] T3 · flutter analyze 0 警告; 版本 0.24.0+72 (pubspec + kAppVersion);
  用户需求TODO.md 回填两项状态。

- [x] T4 · 多维审查 (3 finder + 对抗验证; 7 个验证 agent 因子代理会话限额中断,
  已确认项均处理): 确认 `_dropped` 跨文本编辑残留会让新批次同名行静默未选
  (违背"默认全选"), 修复为 onChanged 整体清空 + 回归测试;
  另修单行输入下 find.text 命中 TextField 全文的测试歧义 +
  library_screen async gap info lint (messenger 捕获提前)。

### v0.23.1 (已完成, CI 绿) — 重构 PATCH: mutate 落盘失败回滚 + 用户反馈 (审查 F9)

> 触发依据: 无开放 issue、CI 全绿、0.23.x 尚无重构 PATCH (prompt.md 优先级 #3)。
> 目标: 兑现 v0.23.0 多维审查遗留 F9 —— `QuotesNotifier._mutate` 此前先写
> state 再 `await saveAll` 且无 try/catch, 落盘失败时 UI 显示成功、重启后
> 数据复活、异常成为无用户反馈的 unhandled async error。

- [x] T1 · `_mutate` 包 try/catch: saveAll 失败 → AppLogger.handle 记日志 +
  state 回滚到 mutate 前快照 + 返回 false; 全部 mutate 方法 (add/addMany/
  update/renameTag/removeTag/remove/removeMany) 链式返回 `Future<bool>`
  (no-op 路径返回 true, update not-found 返回 false)。TDD: 抛错仓储测试
  回滚/返回值/失败后恢复 6 例。
- [x] T2 · UI 调用点失败反馈 (新 ARB key `snackSaveFailed`, zh/en): 编辑屏
  保存/删除、批量导入 sheet、金库单删/批量取出/删除标签、搜索屏删除、
  设置导入合并、标签管理屏改名/取下 —— 失败时 snackbar 提示且**不关闭**
  当前输入面 (文本还在, 可重试), 成功路径行为不变。
- [x] T3 · flutter analyze 0 警告; 版本 0.23.1+71 (pubspec + kAppVersion)。

### v0.23.0 (已完成, CI 绿) — 功能 MINOR: 标签管理内联模式 (L23)

> 触发依据: 无开放 issue、最新 workflow 全绿、0.22.x 已有 v0.22.1 重构 PATCH
> (prompt.md 优先级落到"开发新功能")。**范围修正**: 核实设计源后把 L23 从
> "多标签系统"修正为设计源真实形态"tag-row 内联标签管理" (详见长期规划 L23 条目),
> 放弃 drift 迁移与多选选择器。视觉/文案 100% 对照 screens.jsx LibraryScreen
> (managingTags 分支) + kit.css `.tag.removable` / `.tag.manage-tag` / ConfirmDialog。

- [x] T1 · 域层: `kUntaggedLabel = '未分类'` 哨兵入 tag_filter.dart;
  `filterQuotesByTag` 支持未分类 (命中 trim 后空 tag 句); 测试先行。
- [x] T2 · `tagsProvider`: 存在无标签句时行末追加「未分类」pill (具名标签之后)。
- [x] T3 · TagRow: 管理模式 — 行末 "✎ 管理/✓ 完成" pill (`.tag.manage-tag`:
  透明底 + border-2 + accent + 12px 图标), 管理态具名标签虚线边框 + x
  (`.tag.removable`, 哨兵「全部/未分类」不可删)。
- [x] T4 · LibraryScreen 接线: 确认弹窗 (title 删除标签「t」？/ body 标签下的金句会
  移到「未分类」，不会被删除。/ 确认键 删除标签) → `removeTag` (句子归空 tag);
  正筛选被删标签时回「全部」。文案入 ARB (zh/en)。
- [x] T5 · 测试: filter 未分类 3 例 + tagsProvider 未分类 pill + TagRow 管理模式
  widget 测试 + library 管理流集成 (删除→句子归未分类→pill 消失→active 回全部)。
- [x] T6 · flutter analyze 0 警告; 版本 0.23.0+70 (pubspec + kAppVersion)。
- [x] T7 · 多维审查 workflow (正确性/设计/性能/安全 4 finder + 逐条对抗验证,
  14 agents) 确认 9 条, 已修 8: activeTag 重置提前到落盘前 (防空态卡死) /
  「全部」写入侧净化 `sanitizeTagInput` (add/addMany/update/renameTag 全走) /
  管理态保留 active 实底 (对齐 .tag.active.removable 叠加) / tag-row 字体
  纠偏 sans-ui 12 (kit.css .tag 规范) / CustomPaint 恒定包裹保 AnimatedContainer /
  en 弹窗文案对齐「未分类」pill / provider 侧字面未分类 + 全部净化测试补锁。
- 遗留 (审查 F9) → v0.23.1 重构 PATCH 候选: `QuotesNotifier._mutate` 先写
  state 再 `await saveAll` 且无 try/catch —— 落盘失败时 UI 显示成功、重启后
  数据复活、异常无用户反馈; 系统性问题, 涉及全部 mutate 路径 (add/update/
  remove/renameTag), 需要 state 回滚 + snackbar 反馈, 单独一版做。

### v0.22.1 — 重构 PATCH: 收敛标签/选择模式接缝 (为 v0.23.0 多标签迁移铺路)

> 触发依据: 无开放 issue、最新 workflow 全绿、0.22.x MINOR 在 plan.md 尚无已完成的
> 重构 PATCH (prompt.md 优先级 #3 "当前 MINOR 缺重构 PATCH 必须先补")。用户刚更新
> 设计 skill (新增"批量操作金句 + 标签"= 多标签系统), 即将到来的 v0.23.0 要把单标签
> `Quote.tag` 迁成多标签 `Quote.tags`。本版是该迁移前的**行为等价**铺路: 把散落各处的
> `q.tag` 接缝收敛成"每个面一个改动点", 让 v0.23.0 迁移面更小可控。无可见 UI 变化。

- [x] T1 · 抽纯函数 `filterQuotesByTag(quotes, tag)` 到 `lib/domain/tag_filter.dart`
  (Clean Architecture: 领域纯逻辑入领域层), 去重金库**普通模式**与**多选模式**此前
  各内联一份的 `activeTag == '全部' ? all : where(q.tag == tag)` 筛选谓词。
  **这是 v0.23.0 把 `==` 翻成 `.contains` 的唯一改动点**, 两个调用屏自动跟上。
- [x] T2 · `'全部'` 虚拟标签哨兵收敛为 `kAllTagsLabel` 常量 (同 tag_filter.dart),
  替换 providers (`tagsProvider` / `activeTagProvider`) + library_screen 共 4 处字面量。
- [x] T3 · 命名诚实化: `QuoteCard` 形参/字段 `source` → `tag` (定义 + library×3 /
  search×1 / favorites×1 共 5 处调用); 编辑屏 `_src` → `_tag` 控制器 (6 处)。两处
  此前都叫"source/出处"却装的是标签字段, 改名让多标签迁移面一目了然。
- [x] T4 · 去重屏保版式落款: 满(Fullbleed)/时(Lockscreen) 两版式相同的 `'— ${q.tag}'`
  斜体落款块抽成模块级 `_attributionLine(data, gap, fontSize)` (仅 gap/字号不同)。
  多标签后取首标签只改这一处。页/印/片 三版式的标签作类目标签 (无破折号), 不在此列。
- [x] T5 · 测试: 新增 `filter_quotes_by_tag_test` (哨兵不筛/精确匹配/无匹配/保序/空串
  5 例) + `display_layout_host_test` 加落款渲染 3 例 (满/时 渲染 "— 出处"、
  showAttribution=false 与 无标签 各不渲染)。
- [x] T6 · `flutter analyze` 0 警告 + 行为等价 (现有 widget / select-mode 测试全过)。
  版本号 0.22.0+68 → 0.22.1+69 (pubspec + kAppVersion 双源)。Dart 源码 8333 行
  (< 10000; 本版以接缝收敛 / 命名诚实为主, 非 LOC 削减, 净 +18 行含领域文件注释)。

### v0.22.0 — 金库批量操作 (多选 + 批量取出)

> 功能 MINOR。在「金库」主屏加入多选模式: 顶栏「多选」进入 → 整列卡片可勾选 →
> 底部「取出 N 句」批量删除。视觉/交互严格对齐 `xiao-jinku-desig` skill 的
> select-mode 设计 (screens.jsx / components.jsx / kit.css), 删除口吻沿用品牌
> 「取出」而非「删除」。

- [x] T1 · `QuotesNotifier.removeMany(ids)`: 批量删除只 saveAll + 写一次 state
  (避免循环 `remove` 反复落盘), 空集合不落盘。`test/remove_many_test.dart`
  覆盖: 命中删除/只落盘一次/空集合不动/不存在 id 静默跳过。
- [x] T2 · `QuoteCard` 加 `selectable / selected / onToggle`: 左侧圆形勾选框
  (`.qcheck`), 选中态描边换 accent + 底色叠 8% accent (对照 kit.css)。
- [x] T3 · `LibraryScreen` 改 `ConsumerStatefulWidget`, 加多选模式: 顶栏「多选」
  (check-square) 进入; select-bar (✕ 取消 / 已选 N 句 / 全选·取消全选);
  底部 `_RemoveActionBar` 危险色「取出 N 句」(空选禁用); ✕ 或删除后退出。
- [x] T4 · 复用 `showConfirmDeleteDialog` 加可选 `detail` 行: 标题「从金库取出这 N 句？」
  + 副文「取出后将不再出现在首页和组件里。」。新增 `assets/icons/check-square.svg`
  (Lucide v1.16, ISC)。
- [x] T5 · l10n: ARB(zh/en) + 生成文件新增 actionMultiSelect / selectModeIdle /
  selectedCount(n) / selectAll / deselectAll / removeSelected(n) /
  confirmRemoveSelected(n) / confirmRemoveSelectedBody / selectEmptyNote。
- [x] T6 · 测试: `library_select_mode_test.dart` 覆盖进入/勾选/全选/取消/✕退出/
  确认批量取出 6 个流程。版本号 0.21.3+67 → 0.22.0+68 (pubspec + kAppVersion)。

### v0.21.2 — 修鸿蒙卡片: 去掉「金」印 + 去掉模式切换按钮 (真机反馈)

用户真机反馈桌面卡片两点: (1) 左下角「金」朱印难看, 去掉;
(2) 右下角两个按钮里的「随机/顺序」模式切换按钮多余 —— 模式已在
app「我的」→「小组件播放模式」里调, 卡片上不需要。只保留「下一句」按钮。
顺带清理因此变成死代码的 toggleMode / sealBg / sealFg / playMode 字段。

- [x] T1 · `QuoteCard.ets`: 页脚 Row 去掉 `Text('金')` 朱印块 + 去掉模式
  切换 `Image`(ic_list/ic_shuffle); 只留出处文本 + 下一句按钮(ic_next)。
  删掉因此不再被引用的 `sealBg()` / `sealFg()` / `isDark()` / `playMode` LocalStorageProp。
- [x] T2 · `QuoteFormAbility.ets`: 删 `toggleMode()` 函数 (死代码, 模式按钮
  没了不再有 'mode' event); `onFormEvent` 简化为始终 `nextCard(advance=true)`
  (只剩 refresh 一类消息); `CardData` 接口 + `seed()` + `nextCard()` 返回值
  去掉 `playMode` 字段 (卡片不再消费)。`readMode`/`KEY_MODE` 保留 —— 仍用于
  nextCard 决定随机/顺序推进, 模式由 app 侧设置写入 prefs。
- [x] T3 · 版本号 0.21.0+64 → 0.21.2+66。鸿蒙 hap 构建成功 + **真机验收通过 (含衬线字体)**。
   v0.21.2 附带: 墨色调暖 (ink 6 主题都调暖) + 行距加大 (fontSize+18) +
   内边距加大 (20→24) + 修复 ArkTS 编译 (postCardAction untyped literal →
   显式 interface) + **衬线字体 (Noto Serif SC, compileSdkVersion 23 +
    text.FontCollection.getLocalInstance().loadFontSync())**。

### v0.21.3 — 重构 PATCH: 卡片按钮图标 → 刷新样式 + 消除 widget_color_picker magic color

> 触发依据: 0.21.x MINOR 在 plan.md 尚无已完成的重构 PATCH (prompt.md 优先级 #3)。
> 用户需求: 鸿蒙卡片右下角按钮从「下一句」图标改为「刷新」图标 (两箭头圆环)。

- [x] T1 · 创建 Lucide `refresh-cw` (v1.16.0, ISC) SVG 到 `ohos/entry/src/main/resources/base/media/ic_refresh.svg` + `assets/icons/refresh-cw.svg`。
  保持跟现有图标统一 stroke-width=2, fill=none, stroke=currentColor (ArkTS `.fillColor()` 覆盖)。
- [x] T2 · `QuoteCard.ets`: 按钮图标 `ic_next` → `ic_refresh`, 注释同步 (下一句→换一句)。
  行为不变: 仍通过 `postCardAction` 发 `{action:'message', event:'refresh'}`, 卡片在桌面直接刷新。
- [x] T3 · 重构 `WidgetColorTheme` 加 `xjkThemeId` getter (同 `XJKThemeId` 1:1 映射),
  消除 `_Swatch._color` 内 6 个 magic `Color` 字面量 (值 = `XJKTokens.paper100`),
  改为 `XJKTokens.forId(theme.xjkThemeId).paper100` 一条委托。
- [x] T4 · 测试: `theme_registry_test.dart` 新增 `WidgetColorTheme ↔ XJKThemeId` 映射测试
  (条数相等/同名/isDark一致/paper100 值不漂移), 127 测试全过。
- [x] T5 · flutter analyze 0 警告 + dart format 0 变更。版本号 0.21.2+66 → 0.21.3+67。

### v0.21.0 — 小组件配色对齐六主题 + 预览屏尺寸对齐鸿蒙三档

用户真机验收 v0.20.1 后提两点: (1) 「小组件配色」只有 3 个预设不够;
(2) 「自定义小组件」预览屏只显示 3 个 mock 尺寸, 跟鸿蒙 form_config 实际
支持的 2×2 / 2×4 / 4×4 三档不对应 (v0.20.0 刚加了 4×4 但预览屏没跟上)。
本版把组件配色对齐设计系统六主题, 预览屏对齐鸿蒙三档。

- [x] T1 · `WidgetColorTheme` enum 3→6 (对照 `colors_and_type.css` 六主题):
  现有 paper/night 保留, 新增 celadon(天青)/moonwhite(月白)/
  cinnabar(绛霞)/dai(青黛); 移除 bamboo(不在六主题内, 旧值 fallback paper)。
  displayLabel/displaySub 跟 `XJKThemeId` 对齐。持久化 `.name` 向后兼容。
- [x] T2 · `widget_color_picker.dart` `_Swatch` 6 套色卡: 色值对照
  `colors_and_type.css` 各主题 paper-100。picker 自动列全 6 项 (遍历 values)。
  加 SingleChildScrollView 防长列表溢出。
- [x] T3 · `widgets_preview_screen.dart` 三档 mock 对齐鸿蒙 `form_config.json`:
  小/中/大 → 2×2 (方块 160×160) / 2×4 (横长条 宽×150) / 4×4 (大方块 宽×340)。
  文案改「2×2 / 2×4 / 4×4 · 长按主屏添加「小金库」卡片」。
- [x] T4 · ArkTS 卡片配色扩 6 主题 (`QuoteCard.ets` + `QuoteFormAbility.ets`):
  `readColor` 白名单 6 项; `QuoteCard` 的 bg/ink/ink2/accent/sealBg 5 个色函数
  从 if-chain 改成 6 路 switch, 色值对照 `colors_and_type.css` 各 `[data-theme]`。
- [x] T5 · 测试: `settings_notifier_test` 加六主题 round-trip + 旧值 bamboo
  fallback paper; 125 测试全过, analyze 0 警告。版本号 0.20.1+63 → 0.21.0+64。
- [x] T6 · 鸿蒙 hap 构建 + AGC 签名装机 + Mate 80 真机验收 (用户确认):
  配色 6 选项 ✓ + 预览屏三档 ✓ + 桌面卡片跟随配色变色 ✓。

### v0.20.1 — 重构 PATCH: 三栏导航对齐设计系统 (首页 / 金库 / 我的)

兑现 prompt.md 优先级 #3 (当前 MINOR 0.20.x 缺重构 PATCH)。对照 xiao-jinku-desig
skill 的 `components.jsx` BottomNav + `screens.jsx` SettingsScreen, 把当前 4 tab
(金库 / 屏保 / 组件 / 设置) 重构为设计系统规定的 3 tab (首页 / 金库 / 我的), 并把
小组件配置从独立 tab 收进「我的」section。属结构重构, 向下兼容。

- [x] T1 · 底栏 4→3 tab (`bottom_nav.dart`, 对照 `components.jsx:84-88`):
  enum `XJKNavTab` 去掉 `widgetsTab`; `_items` 三项 首页(`home`/display) ·
  金库(`book-open`/library) · 我的(`user-round`/settings)。
- [x] T2 · 路由结构 (`router.dart`): 初始路由 `/library` → `/display` (首页为落地页,
  对照 `app.jsx:16` `initialScreen="display"`); `/widgets` 从 shell branch 改为
  顶层 push 子路由 (同 `/search` `/tags`); `XJKNavTabRoute.tabs` 三项 display 首位。
- [x] T3 · 我的屏 (`settings_screen.dart`, 对照 `screens.jsx:306`): TopBar 标题
  设置→我的 / subtitle `settings`→`profile`; `_RotationSection` 标题
  屏保/小组件→小组件, 首行加「自定义小组件」(→ push `/widgets` 预览引导)。
- [x] T4 · 组件预览屏 (`widgets_preview_screen.dart`): 从 tab 改为 push 子路由,
  包 `Scaffold` + `SafeArea` + TopBar `leading` 返回 (`chevron-left`), 对照 tags_screen。
- [x] T5 · 测试: `nav_tab_route_test` 更新 3 tab + `/widgets` 不再映射 tab;
  `flutter analyze` 0 警告 + `dart format`。新增 `home.svg` / `user-round.svg`
  (Lucide v1.21.0, stroke-width 2 对齐既有图标集)。
- [x] T6 · 版本号 0.20.0+62 → 0.20.1+63。124 测试全过, analyze 0 警告。

### v0.20.0 — 鸿蒙卡片视觉改版 (对标 西窗烛/句子控) + 展示去序号

用户真机对比西窗烛/句子控觉得我们卡片不够优美。用 xiao-jinku-desig skill
重新设计 (先出 HTML mock 对齐方向, 再落 ArkTS):

- **展示去序号**: 新增 `displayQuoteText` 剥掉开头 "200." / "9、" 等序号前缀
  (原数据不动), 应用到卡片/小组件 timeline + 屏保 5 版式 + 金库列表卡片。
- **卡片重排** (QuoteCard.ets): 16px 顶贴 → 22px 大字 + 黄金比锚点 (上 0.38/
  下 0.62 留白); 顶部「金」朱印 + 小金库·Folio 落款; 出处斜体; 两个控制图标
  按用户要求保留但做淡 (fillColor 跟随主题 + 低透明度), 不抢正文。
- **跟随主题配色**: 卡片读 `widgetColorTheme` (青纸/林夜/翠竹) 自映射 bg/ink/
  accent/seal 三套色 (QuoteFormAbility 把 colorTheme 注入 CardData)。
- 局限: 鸿蒙卡片仍用系统字体 (非衬线) —— ArkUI 卡片不能用 Flutter 端
  Noto Serif SC, 后续可注册 rawfile 衬线字体再上。
- Dart analyze 0 警告 + 124 测试 (新增 quote_display 8 例); 鸿蒙 hap 编译 +
  Mate 80 真机验收。版本号 0.19.3+61 → 0.20.0+62。

### v0.19.3 — 修 v0.19.2 卡片回归 (图标太小 + 顺序模式仍随机)

用户真机反馈两点:
- **图标太小**: 卡片两个图标从 18px 放大到 26px (padding/圆角同步加大)。
- **顺序模式点下一句仍随机**: 根因是 Dart 侧给鸿蒙卡片下发的是**预洗牌**
  timeline (folio 当时 mode=随机), 卡片"顺序"cursor+1 走的是乱序 → 看着还是随机。
  修法: 鸿蒙卡片一律**库原序**下发 (`shuffle: false`), 随机性全交卡片侧
  (随机=随机下标 / 顺序=cursor+1 真按序); EntryAbility 同步只在卡片无模式时
  设初始默认, 不再覆盖用户在卡片上切的模式。
- Dart analyze 0 警告 + 测试全过; 鸿蒙 hap 编译 + Mate 80 真机复验。
  版本号 0.19.2+60 → 0.19.3+61。

### v0.19.2 — 修 Issue #13 (鸿蒙卡片"换一句"文字按钮 → 音乐播放器式图标)

- 卡片底部把文字"换一句"换成两个图标 (对照 Lucide, 预着色进 ohos media):
  **下一句** (skip-forward, accent) + **模式切换** (随机=shuffle / 顺序=list,
  ink-500)。
- 卡片改成 mode 感知: `QuoteFormAbility` 读 `widgetPlayMode` pref, `nextCard`
  按 mode 推进 (顺序=cursor+1 / 随机=整库随机下标), 新增 `toggleMode`;
  `onFormEvent` 解析 event=mode→切模式 / 否则→下一句。模式图标按当前 mode
  显示对应字形 (`@LocalStorageProp('playMode')`)。
- 数据桥补 mode: EntryAbility channel handler + OhosWidgetService 都带上
  `widgetPlayMode`, 让 folio 的"小组件播放模式"设置初始化卡片模式;
  卡片上点模式图标也能本地切换 (离线生效)。
- Dart analyze 0 警告 + 116 测试全过; 鸿蒙 hap 编译 + Mate 80 真机验收。
  版本号 0.19.1+59 → 0.19.2+60。

### v0.19.1 — 修 Issue #11 #12 (小组件整库随机/顺序 + 金库滚动条)

用户在 Mate 80 真机反馈批量 issue (#11 #12 #13), 本版按 prompt.md 优先级
立即修前两个 (#13 卡片图标化留 v0.19.2):

- **#11 小组件下一句不随机 / 只在固定几条里转**: 根因是 `WidgetTimeline.generate`
  固定取 20 条。改为**默认覆盖整个金库** (上限 maxLength=1000), 新增
  `WidgetPlayMode {random, sequential}` 设置 (默认随机) 经 AppSettings 持久化,
  Dart 侧按 mode 生成 (随机=NoRepeatShuffle 整库 / 顺序=库原序), Android +
  鸿蒙两条同步通道都带上 mode。设置屏加"小组件播放模式"行。
- **#12 金库列表无滚动条**: LibraryScreen 的 ListView 包 `Scrollbar`
  (thumbVisibility + interactive 可拖动) + `primary: true`。
- 测试: widget_timeline 加整库默认 / 顺序模式 / maxLength 截断 3 例,
  settings_notifier round-trip 加 widgetPlayMode; 116 测试全过, analyze 0 警告。
  版本号 0.19.0+58 → 0.19.1+59。

### v0.19.0 — 设计系统 2.0: 传统色六主题 + 屏保精选 5 版式 (L22)

兑现 2026-06-16 重新生成的 `xiao-jinku-desig` skill。

- **传统色六主题** (2→6): 新增 天青 Celadon / 月白 Moon White / 绛霞 Cinnabar
  (浅) + 青黛 Ink Indigo (暗), token 值逐字对照 colors_and_type.css
  `[data-theme=...]`。`AppThemeMode` 扩成 system + 6 主题 (晨→昏循环顺序),
  displayLabel 委托 `XJKThemeId.label` 单一可信源; 设置屏主题选择器自动列全 7 项。
- **屏保精选 5 版式** (`display_layouts.dart`, 对照 display-layouts.jsx + kit.css):
  页 Page (书页页眉/正文/页脚) · 满 Full-bleed · 印 Stamped (首字抹茶印章) ·
  时 Lock screen (实时时钟题注, 20s 走字) · 片 Card on field (浮纸卡)。
  底栏新增"换版式"字形按钮 (循环), 右上 layout-pip 版式名 (1.8s 淡出),
  选中版式持久化 (`displayLayoutKey`, 复用 SettingsRepository, 鸿蒙快照自动带走)。
- **黄金比锚点** (`goldenAnchor`): 居中版式用 `Spacer(flex:382/618)` 把 quote
  夹在上黄金线 (≈38.2%), 比死居中更有章法。
- **句长分级 q-scale** (纯函数 + 单测): 中文字数→tier→字号乘子 (tiny 1.15 /
  short 1.0 / medium 0.82 / long 0.64 / xlong 0.5), 长短句字号自适应。
- 测试: theme_registry (6 主题注册表/forId 不漂移/亮暗合理) + display_layout_host
  (5 版式注册表/渲染/q-scale 边界) + theme_mode_label (7 项标签), 113 测试全过,
  analyze 0 警告。Dart 源码 8357 行 (< 10000 预算)。
- 版本号 0.18.2+57 → 0.19.0+58。**纯 Dart UI, 全平台通用, 待 Mate 80 Pro /
  HarmonyOS 6 真机验收**: 六主题切换 (含 2 暗)、5 版式循环、长短句字号、黄金比观感。
- 余下 4 版式 (竖 Vertical / 引 Pull / 条 Ribbon / 织 Interleave) 留后续 PATCH。

### v0.18.2 — 重构 PATCH: 主题系统注册表化 + 屏保版式宿主抽象 (L22 铺路)

为 v0.19.0 设计系统 2.0 铺路, 本版无可见 UI 变化, 行为等价 (CI 绿)。

- `XJKThemeId` 主题注册表 (key/中文名/英文名/isDark) 把"主题身份"与"亮暗"解耦;
  `XJKTokens.forId` 作 token 单一可信源; `AppThemeMode.themeId` 作"设置→注册表"
  唯一映射点 (枚举值/displayLabel/持久化 .name 全不变, 向后兼容)。
- `app.dart` 主题装配由选中主题 isDark 推导 brightness, 不再写死二分;
  `resolveIsDark` 改走注册表。
- 抽出 `DisplayLayout` 宿主抽象 (DisplayLayoutData + 注册表), 轮播/淡入/壁纸/
  收藏编排与版式渲染分离, 当版仅经典居中一项。
- 新增 theme_registry_test + display_layout_host_test, 110 测试全过。
  版本号 0.18.1+56 → 0.18.2+57。

### v0.18.1 — 修鸿蒙数据丢失: app 数据落盘 ArkTS preferences (真机验证)

**用户报 bug**: 鸿蒙上重装/重启后导入的金句全没了。根因: L20 起鸿蒙因
`shared_preferences`/`path_provider` 联邦插件被上游 bug 阻塞, 一直走**内存版
SharedPreferences 降级** (drift 也因拿不到 path_provider 路径 fallback 到内存
prefs), 数据从不落盘, 一杀进程就没。

**修法 (复用服务卡片同款绕过技术)**: 新建 `lib/data/ohos_prefs_bridge.dart`
`OhosPrefsBridge`, 经自写 `MethodChannel('app.folio/ohos_store')` →
`EntryAbility.ets` 的 `AppStoreHandler` 用 ArkTS 系统 API
`@ohos.data.preferences` 把整份 prefs 快照落盘:
- 启动: bootstrap 在 ohos 分支先 `loadSnapshot()` 经 channel 读回快照 →
  喂给 `setMockInitialValues`, 内存 prefs 一开始就带着上次数据;
- 写后: `_PrefsQuoteRepository.saveAll` / `SettingsRepository.save` /
  `FavoritesRepository.save` 各自写完 prefs 后调 `flush()` 把整份快照推回落盘
  (isOhos 守卫, 非鸿蒙全 no-op, 零行为影响);
- 快照**带类型** (`{key:{t:s|b|i|d|sl, v}}`), 让 JSON 往返不丢
  bool/int/List&lt;String&gt; (favorites 是 List&lt;String&gt;、cadence 是 int);
- 安全: 只有 `loadSnapshot` 成功过才允许 flush, 避免 channel 没就绪时空数据
  覆盖已落盘真实数据; 坏 JSON 当空处理不炸启动。

**测试**: `test/ohos_prefs_bridge_test.dart` 锁快照往返保真 (5 种类型) +
坏数据降级, 94→97 测试全过, analyze 0 issue。

**真机验证 (5MT0226311023694)**: hilog `Setting handler for channel
app.folio/ohos_store` + 上次落盘 → 本次启动 `loadPrefs len=1238` (整份 prefs
快照跨重启读回)。数据持久化打通。版本号双源 0.18.0+55 → 0.18.1+56。

注意: 此为应用沙箱内持久化, 跨**更新安装** (bm install 同包名) 数据保留;
彻底卸载会随沙箱清掉 (系统行为, 原生 app 亦然)。

### v0.18.0 — L21 鸿蒙服务卡片 (里程碑①静态卡片 + ②数据桥, 真机验证)

用户在 v0.17.1 后选定 v0.18 主攻 **L21 鸿蒙服务卡片**。里程碑① (静态卡片)
+ ② (数据桥) 本程落地并真机验证。里程碑③ (系统定时 cursor 推进) 代码已就位
(QuoteFormAbility.onUpdateForm), 与"桌面加卡片肉眼看库内金句渲染"一起留手动
验收。鸿蒙构建本地进行不进 CI; Dart 侧变更随 CI 走且对非鸿蒙平台零行为影响。

**设计先行 (ADR 0002)**: 推演 L21 数据桥/刷新/降级设计树, 关键判断是
**数据桥走"自写 MethodChannel (注册在 EntryAbility, 非 pub 插件) + 卡片侧
@ohos.data.preferences 存储"**, 刻意绕开受阻的联邦插件 (上游 #1) —— L21
因此不必等上游修复, 只需真机验证。刷新走"app 主动 updateForm + form
updateDuration 30 分钟兜底"(鸿蒙 form 定时刷新最小粒度 30min, 比 Android
15min 粗)。降级分里程碑①②③, 每级都是可用降级态 (卡片永不白屏)。

**里程碑① scaffold (本程交付, 真机验证通过)**:
- `ohos/entry/src/main/ets/entryformability/QuoteFormAbility.ets` —
  FormExtensionAbility, onAddForm 注入种子金句;
- `ohos/entry/src/main/ets/widget/pages/QuoteCard.ets` — ArkTS 卡片页,
  青纸主题 (bg #e2e6cf / ink #1d2a1f / 出处 #5e7263 斜体右下), 衬线金句,
  点击 postCardAction 拉起 EntryAbility;
- `form_config.json` (2*2 默认, updateDuration=1=30min) + module.json5
  extensionAbilities 注册 + base/zh_CN string.json 加 form_label/desc。
- UI 严格遵循 skill xiao-jinku-desig 青纸主题取色。

**真机验证 (设备 5MT0226311023694 / OpenHarmony 6.1.1.120 API 24)**:
编译过 assembleHap ✓ → AGC 签名装机 `install bundle successfully` ✓ →
`bm dump` 含 `extensionTypeName=form` + form_config metadata, HarmonyOS
已识别 QuoteFormAbility ✓。`@kit.FormKit` import 在 fork 解析成功、fork
支持 extensionAbilities (ADR 两个未决风险均证伪)。仅剩"桌面长按加卡片
肉眼看渲染"需手动验收 (物理操作, 自动化不可达)。
踩坑: form_config.json 是严格 JSON schema 校验, 不能写 `//` 注释键
(propertyName must be valid), 说明文字移到 ADR/wiki。

**里程碑② 数据桥 (本程交付, 真机验证)**:
- Dart `lib/data/ohos_widget_service.dart` (新建): `OhosWidgetService` 经自写
  `MethodChannel('app.folio/ohos_widget')` 推 timeline JSON (复用纯 Dart
  `WidgetTimeline`), `isOhos` 守卫, 非鸿蒙 no-op, handler 缺失时吞
  `MissingPluginException` 降级。`providers.dart` 加 `ohosWidgetServiceProvider`,
  `widget_sync_bridge.dart` `_sync` 并列推 Android(home_widget)+鸿蒙(channel)。
- ArkTS `EntryAbility.ets`: `configureFlutterEngine` 注册 channel handler
  (`WidgetChannelHandler implements MethodCallHandler`), 收到 syncTimeline 写
  `@ohos.data.preferences`(folio_widget)。`QuoteFormAbility.ets`: onAddForm/
  onUpdateForm 读 preferences → 解析 timeline[cursor] 渲染, 缺数据回落种子句。
- 测试: `test/ohos_widget_service_test.dart` 锁 host 上是 no-op (不抛/不 call
  channel)。Dart 92→94 测试全过, analyze 0 issue。
- 真机验证 (5MT0226311023694): ArkTS 编译过 assembleHap、AGC 装机成功、
  **app 拉起渲染金库正常不崩**, hilog 无新异常 (path_provider/home_widget 的
  MissingPlugin 是既有 ohos 降级噪音, 非本次引入; 我的 app.folio/ohos_widget
  channel 未报 MissingPlugin = handler 已注册)。**ADR 0002 核心假设"自写
  channel 能在 fork 注册"证实**。截图见 /tmp (本地)。
- 待手动: 桌面加卡片确认显示库内真实金句 (而非种子句) + cursor 30min 推进。

**卡片刷新 (客户诉求, 本程交付)**: 客户提出"卡片能否加刷新按钮、是否支持
自动刷新"。两条都做了:
- **手动"换一句"按钮**: `QuoteCard.ets` 底部加 accent 色按钮, 点击
  `postCardAction(message {action:'refresh'})` → `QuoteFormAbility.onFormEvent`
  推进 cursor + `formProvider.updateForm`, **在桌面直接换下一句, 不打开 app**。
- **自动刷新**: `form_config.json` `updateEnabled + updateDuration=1` (30min)
  → `onUpdateForm` 自动推进 cursor。鸿蒙 form 系统定时**最小粒度 30 分钟**
  (平台硬约束, 比 Android ~15min 粗); app 在前台时数据桥推送即时刷新。
  手动按钮与之互补 (想立刻换点按钮)。
- 三条换句路径 (定时 onUpdateForm / 按钮 onFormEvent / app 推送) 复用同一个
  `advanceCursor()` 助手, 保持 cursor 语义一致。
- 真机验证: ArkTS 编译过 + 装机 + app 拉起不崩 + **sceneboard 已渲染
  QuoteWidget 卡片** (hilog: build item form cardName=QuoteWidget, page 4)。
  按钮点击换句、30min 自动换句留桌面手动验收。

参考 skill: xiao-jinku-desig (卡片取色) · ohos-dev (构建/签名/装机/bm dump)。

### v0.17.1 — 重构 PATCH: 收敛"平台契约"层的重复与魔法值 (L21 铺路)

兑现 prompt.md 优先级 #3 "当前 MINOR 没有重构 PATCH 必须立即规划"。
v0.17.0 是 L20 鸿蒙适配 MINOR, 之后还没有专门的重构 PATCH, 这版补上。
开 v0.18 (L21 鸿蒙服务卡片 / 批量导入增强) 新 MINOR 前的纯重构,
行为零变化, 92 个测试全过、`flutter analyze` 0 issue。

优先级判定 (开发流程铁律):
- 无 open issue (`gh issue list --state open` 空);
- 最新 workflow 全绿 (27502640709 success);
- v0.17.x MINOR 仅有 v0.17.0, 无重构 PATCH → 必须先做重构 PATCH, 不能直接开 MINOR。

两处真实的重复/魔法值, 同属"平台契约"主题:

1. `lib/core/platform_capabilities.dart`: `isAndroid` / `isIOS` /
   `isDesktop` / `isOhos` 四个 getter 各自重复一遍
   `if (kIsWeb) return false; try { ... } catch (_) { return false; }`
   守卫 (Web 上 `dart:io` 的 `Platform` 不可用、部分运行时访问会抛)。
   抽出私有 `_platformQuery(bool Function() probe)` 收敛, 四个 getter
   退化成一行表达式, 守卫逻辑单一可信源。公开 API 签名与返回语义不变。

2. `lib/data/widget_sync_service.dart`: 写 home_widget 共享存储的 6 个 key
   (`widgetTimeline` / `widgetTimelineCursor` / `widgetCadenceMinutes` /
   `todayQuote` / `todayTag` / `widgetColorTheme`) 此前是内联魔法字符串,
   而 native Kotlin (`QuoteWidgetProvider` / `QuoteWidgetAlarmReceiver`)
   读的是同一份字面量 —— 这是一份跨语言契约。抽成 `_kKey*` 命名常量,
   写入的字面量值逐字节不变 (native 契约不破), 但 Dart 侧不再散落魔法值,
   且 L21 鸿蒙 ArkTS 服务卡片将读同一组 key, 集中后改名只改一处。

不动任何业务行为, 不新增/删除功能。仓库卫生: 删历史残留 `flutter_*.log`
崩溃报告 + `.gitignore` 加 `flutter_*.log` 模式防复发。

参考 skill: 无 UI 改动。

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
