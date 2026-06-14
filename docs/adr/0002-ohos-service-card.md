# 0002 · 鸿蒙服务卡片 (L21) 数据桥 / 刷新 / 降级设计

日期: 2026-06-15
状态: 提议 (设计已定, 实现待真机验证)

## 背景

L18 在 Android 上实现了桌面小组件按 cadence 自动刷新: Dart 端用
`home_widget` 插件把预生成的 N=20 条 timeline 写进共享存储, native 端
`QuoteWidgetProvider` (Kotlin) + `AlarmManager` 按用户配的频率推进 cursor
渲染下一句。ADR 0001 已明确鸿蒙上的等价物 "服务卡片" 推到 L21, 因为鸿蒙
没有 `home_widget` 的等价插件 (实测 `MissingPluginException`), 服务卡片
必须用 ArkTS 的 `FormExtensionAbility` 原生实现。

L21 的核心难点是 **数据怎么从 Dart 传到 ArkTS 卡片**, 以及卡片怎么刷新。
本 ADR 推演这棵设计树并定调, 让后续实现 (真机就绪时) 不再返工。

### 关键约束

1. **鸿蒙服务卡片是独立运行环境**: 卡片由 `FormExtensionAbility` (ArkTS)
   渲染, 跟 Flutter 的 `EntryAbility` 不是同一个进程/Ability, 但**同属一个
   应用 bundle, 共享应用沙箱** (filesDir / preferences / distributedKVStore)。
2. **上游联邦插件 bug (#1) 仍未修**: `path_provider` / `shared_preferences`
   的 ohos 联邦插件因 srcPath off-by-one 装不上 (见
   `docs/wiki/ohos/upstream-issues.md`), Folio 当前在鸿蒙走内存 prefs 降级,
   数据不跨重启持久化。**这意味着 Dart 端没有可靠的持久化存储, 也没有
   `path_provider` 能拿到沙箱路径。**
3. **真机当前未连接** (`hdc list targets` = Empty), 任何卡片代码无法在本程
   验证, 只能写到"可验证 scaffold"为止。
4. UI 必须遵循 skill `xiao-jinku-desig` (青纸/林夜双主题, 金句卡片样式)。

## 决策

### 决策一: 数据桥走"自写 MethodChannel + ArkTS 侧存储", 不等上游修复

把 L21 数据桥拆成两段, **刻意绕开受阻的联邦插件**:

```
Dart (timeline JSON)
  → MethodChannel('app.folio/ohos_widget')   ← 自写, 注册在 EntryAbility, 非 pub 插件
  → EntryAbility.ets (ArkTS)
  → @ohos.data.preferences 写入应用沙箱        ← ArkTS 系统 API, 不经联邦插件
  → formProvider.updateForm() 主动刷新卡片
FormExtensionAbility.onUpdateForm / 卡片首帧
  → @ohos.data.preferences 读同一份数据 → 渲染
```

**为什么这能绕开上游 #1**: 上游 bug 只影响**从 pub-cache 集成的联邦插件**
(它们的 har 子工程 srcPath 多算一层)。而:

- `MethodChannel` 是 Flutter 引擎核心能力, 不是 pub 插件; 像 L18 在 Android
  `MainActivity` 自写 `app.folio/wallpaper` / `app.folio/widget_alarm`
  channel 一样, 我们在鸿蒙 `EntryAbility.ets` 里自己注册 channel handler,
  不触发 `MissingPluginException` (那是给未背书的 pub 插件 home_widget 报的)。
- 所有**持久化都在 ArkTS 侧**用 `@ohos.data.preferences` / `@ohos.file.fs`
  系统 API 完成 —— 这些是鸿蒙原生 API, 根本不走联邦插件机制, 不受 #1 影响。

**因此 L21 的数据桥不必等上游修复, 只需真机验证。** 这是本 ADR 最重要的
判断: 把 L21 从"被上游阻塞"重新定性为"可行, 待真机验证"。

被否决的备选:

- **备选 A: 等 `shared_preferences_ohos` 修好, 复用 L18 的 prefs 桥** ——
  被否。把 L21 的工期绑死在上游 fork 的修复节奏上, 不可控; 且即便修好,
  Flutter 插件写的 prefs 命名空间未必跟 ArkTS `@ohos.data.preferences`
  默认库同一个, 仍要对齐。
- **备选 B: Dart 直接写共享文件 (file.fs)** —— 被否。Dart 端没有
  `path_provider` 拿不到 filesDir 路径; 即便从 ArkTS 启动时把路径透传给
  Dart, 也还是要先有一条 channel —— 那不如直接用 channel 传数据 (决策一),
  存储交给更可控的 ArkTS 侧。

### 决策二: 复用纯 Dart 的 `WidgetTimeline`, 卡片不做 shuffle

L18 的 `lib/domain/widget_timeline.dart` (`WidgetTimeline.generate` +
`serialize`) 是**纯 Dart, 零平台依赖**。L21 直接复用: Dart 端照样预生成
N 条 timeline JSON, 经 channel 推给 ArkTS。卡片 (ArkTS) 跟 native Kotlin
一样**只按 cursor 取 timeline[cursor], 不参与 shuffle**, 保证 app 屏保和
卡片显示完全同一份 `NoRepeatShuffle` 序列。

v0.17.1 已把 home_widget 共享存储的 key 收敛成 `WidgetSyncService._kKey*`
命名常量 —— ArkTS 侧读 preferences 用**同名 key** (`widgetTimeline` /
`widgetTimelineCursor` / `widgetColorTheme`), 维持这份跨语言契约。

### 决策三: 刷新走 "应用主动 updateForm + 卡片 updateDuration 兜底"

鸿蒙 form 的系统定时刷新粒度受限: `updateDuration` 以 30 分钟为单位
(最小 1 = 30 分钟), `scheduledUpdateTime` 只能指定每天定点。对照 L18 的
15 分钟下限取舍, L21 采用双轨:

1. **应用在前台/数据变化时主动推**: Dart 侧 quotes / cadence / colorTheme
   变化 → channel 推新 timeline → ArkTS `formProvider.updateForm()` 立即刷新。
   这条覆盖"用户刚在 app 里改了金库, 卡片马上跟上"的体验。
2. **系统定时兜底**: `form_config.json` 设 `updateEnabled: true` +
   `updateDuration: 1` (30 分钟), 让 app 不在前台时卡片也能每 30 分钟自己
   推进一次 cursor (在 `onUpdateForm` 里读 cursor → +1 取模 → 写回 → 渲染)。

**鸿蒙卡片刷新下限 = 30 分钟** (平台硬约束), 写进文档与设置说明, 跟
Android 的 15 分钟下限并列。cadence < 30min 时, 卡片只能靠"应用主动推"
做到更快, 后台仍是 30 分钟。

### 决策四: 降级 —— 数据桥未通时显示静态种子金句

分三个可独立验证的里程碑, 每个里程碑本身是一个可用的降级态:

- **里程碑 ① 静态卡片 spike**: `FormExtensionAbility` + 一张卡片页, 写死
  一句种子金句 (青纸主题)。验证"卡片能加到桌面 + 正常显示 + 不崩"。
  **不含任何数据桥**, 纯静态。← 本程交付 scaffold, 待真机验证。
- **里程碑 ② 数据桥单向**: 接通 channel + ArkTS preferences, app 推一次
  timeline, 卡片读首条渲染。验证 Dart→ArkTS 数据确实到位。
- **里程碑 ③ 刷新闭环**: 接 `formProvider.updateForm` + `updateDuration`
  cursor 推进, 卡片随 cadence 换句。对齐 L18 体验。

任何里程碑未达成时, 卡片回落到"显示最后一次成功写入的句子"或"静态种子
金句", 不白屏、不崩溃。

## 后果

- L21 不再被上游 #1 阻塞, 可在真机就绪后按里程碑①②③推进; 数据持久化
  这次落在 ArkTS 侧 (`@ohos.data.preferences`), 反而比 Dart 侧降级态更可靠。
- 引入鸿蒙独有的 ArkTS 原生面 (`FormExtensionAbility` + 卡片页), 这是
  ADR 0001 "原生层替换" 的延伸; 代码量小且隔离在 `ohos/entry/src/main/ets/`,
  不污染 Dart 跨平台层。
- Dart 侧新增一个 ohos-only 的 `MethodChannel` 调用点, 用
  `PlatformCapabilities.isOhos` 守卫, 其他平台不触发 (沿用 v0.16.2 能力开关
  原则: UI/service 只问能力)。
- 真机刷新粒度 30 分钟比 Android 的 15 分钟更粗, 需在设置说明里区分平台。
- 风险: 本 ADR 的数据桥方案 **尚未真机验证**, "自写 channel 能在 ohos
  fork 上注册" 这一前提虽有 L18 Android 同构先例支撑, 仍需里程碑②落地时
  证实; 若证伪, 回退备选 A (等上游) 并重新评估。
