# 0001 · 鸿蒙适配采用 OpenHarmony Flutter fork,而非 ArkTS 重写

日期: 2026-06-13
状态: 已接受

## 背景

目标设备 Mate 80 出厂即纯血鸿蒙(HarmonyOS 6.0),完全不能安装 APK,
适配意味着产出独立的 .hap 应用。Flutter 官方不支持鸿蒙。此时项目已有
约 16 个 MINOR 版本的 Flutter 代码,UI、数据层、测试全部在 lib/ 下,
Android 原生面刻意压得很薄(android/ 目录由 CI 从模板注入)。

候选路线:

1. **OpenHarmony-SIG 的 flutter_flutter 鸿蒙化 fork**——现有 Dart 代码
   基本原样复用,只重做原生层。
2. **ArkTS/ArkUI 原生重写**——体验最"纯血"(服务卡片、动效、系统集成
   都是一等公民),但全部代码作废,单人项目工作量数月级。
3. **ArkUI-X 等其他跨端框架**——同样意味着重写,且生态更不成熟。

## 决策

采用 OpenHarmony-SIG 的 flutter_flutter 鸿蒙化 fork,把现有 Flutter
应用编译为 hap。配套决策:

- **首发范围**:v1 只含纯 Dart 核心功能(金库 CRUD、屏保、主题、搜索
  标签、导入导出)。服务卡片(需 ArkTS 原生实现,无 home_widget 等价物)
  和"设为壁纸"(@ohos.wallpaper 为系统 API,三方应用大概率无权限,
  待 spike 验证)推到后续版本。
- **仓库结构**:ohos/ 工程直接进主仓库(不同于 android/ 的 CI 模板注入
  策略——ohos 工程含 ArkTS 入口、hvigor 配置,迭代频繁且无模板化先例),
  签名私钥/证书 gitignore。
- **平台差异隔离**:全部挡在 data 层与 PlatformCapabilities 能力开关
  之后,UI 只问能力不问平台;sqlite3 在 ohos 不可用时仓储降级走
  SharedPreferences 工厂分流(机制已存在于 Web 路径)。
- **分发**:先华为开发者账号 + 调试签名自用装机,上架 AGC 为后续目标。
- **CI**:v1 阶段鸿蒙构建不进 GitHub Actions,纯本地构建。本地工具链
  优先用鸿蒙 Command Line Tools(sdkmgr/ohpm/hvigor/hdc + 环境变量),
  不强制安装 DevEco Studio;调试签名材料(p12/cer/p7b)在 AGC 网页
  控制台一次性申请,DevEco 仅作为签名流程卡住时的兜底。

## 后果

- 现有 Dart 代码、测试、设计规范全部得以保留,适配工作量集中在
  环境搭建、依赖验证和原生层替换上。
- 项目从此绑定在社区维护的 fork 上:Flutter 版本通常落后官方 1-2 个
  minor,主线升级 Flutter 前需确认 fork 已跟进。
- 桌面小组件体验在鸿蒙上暂缺,等服务卡片立项(ArkTS 重写 L18 的
  timeline 刷新机制)后补齐。
- 本地需要维护两套 Flutter SDK(官方 + 鸿蒙化 fork)并切换。
