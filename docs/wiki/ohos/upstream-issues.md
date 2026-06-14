# flutter_flutter (CPF-Flutter) 鸿蒙化 SDK 问题清单

> 适配 Folio (纯 Dart Flutter 应用) 到 HarmonyOS 6 / Mate 80 过程中, 在
> OpenHarmony Flutter fork 上遇到的可复现问题, 供向上游
> https://gitcode.com/CPF-Flutter/flutter_flutter 提 issue / PR。
>
> 环境: macOS arm64 · fork tag `3.35.8-ohos-1.0.1` · OpenHarmony 6.0 SDK
> (API 20) · hvigor 5.19.8 · ohpm 5.0.2 · 不装 DevEco Studio (纯命令行)。
> 目标机: Mate 80, doctor 识别为 `OpenHarmony-6.1.1.120 (API 24)`。

---

## #1 [致命] 联邦插件从 pub-cache 集成时, 模块 srcPath 相对路径多一层 (off-by-one)

**现象**: 依赖 `path_provider` / `shared_preferences` / `file_selector`
(官方 tpc fork, git 依赖, 落在 `~/.pub-cache/git/...`) 时,
`flutter build hap` 在 ohpm install 阶段失败:

```
ohpm ERROR: Install failed, detail: The module: "file_selector_ohos"
  configed in ".hvigor/dependencyMap/dependencyMap.json5" does not exist.
00306053 Specification Limit Violation: ohpm install failed.
```

**根因**: 生成的 `ohos/.hvigor/dependencyMap/dependencyMap.json5` 里插件
模块 srcPath 为:
```
"srcPath":"../../../../../../../../.pub-cache/git/.../file_selector_ohos/ohos"
```
共 **8 个 `../`**。但从 `ohos/.hvigor/dependencyMap/` 到 `~/.pub-cache`
实测只需 **7 个 `../`** (8 个会落到 `/Users/.pub-cache`, 不存在)。

确认非符号链接导致 (仓库与 pub-cache 物理路径均无 symlink)。从 `ohos/`
到 `~/.pub-cache` 是 5 个 `../`, dependencyMap 深 2 层 → 正确应为 7,
工具生成 8, 多一层。

**影响**: 任何从 pub-cache (git / pub.dev 缓存) 引入的 ohos 联邦插件都
装不上, 即"纯 Dart + 标准插件"应用无法在真机持久化数据。

**建议**: 核对 `ohos_plugins_manager.dart` 写入 build-profile.json5
`modules[].srcPath` 的基准, 以及 hvigor 把它重定基到 dependencyMap 目录
时的层级换算; 二者其一多算了一层。

---

## #2 [高] 插件 har 的 hvigorfile.ts 无法解析 @ohos/hvigor-ohos-plugin

**现象**: 构建插件 har 子工程时:
```
hvigor ERROR: Failed to load or execute hvigorfile.ts:
  Cannot find module '@ohos/hvigor-ohos-plugin'
At file: ~/.pub-cache/git/.../file_selector_ohos/ohos/hvigorfile.ts
```

**根因**: 插件 har 工程在 `~/.pub-cache` 下, node 逐级向上找 node_modules
的路径里不含用户的 hvigor 安装 (装在别处), 解析不到 hvigor 插件。

**绕过**: `export NODE_PATH=<hvigor>/node_modules` 给 node 全局兜底搜索路径。

**建议**: fork 构建插件 har 时应显式把 hvigor 工具链的 node_modules 注入
子工程的模块解析路径 (或在 spawn hvigor 时设 NODE_PATH), 不应依赖用户
全局环境。

---

## #3 [高] flutter create 生成的 ohos 工程缺 hvigorw, 且 hvigor 版本约束不清

**现象**:
- `flutter create --platforms ohos` 产出的工程**不含** hvigorw wrapper,
  但 doctor 又要求 PATH 上有 hvigorw。
- `flutter_tools/hvigor/package.json` devDep 钉 `@ohos/hvigor 5.2.2`, 但
  5.2.2 不支持模板里的 `hvigorconfig.ts` (报 "hvigorConfig is not yet
  available for build"); 6.x 又报 `TypeError this.getInstance is not a
  function`; 实测只有 5.19.x 可用。
- hvigor 核心与 `hvigor-ohos-plugin` 若版本/实例不一致, 报无指向性的
  `TypeError this.getInstance is not a function` (模块双实例)。

**建议**: 文档/脚手架明确给出兼容的 hvigor 版本与安装方式; 或随 fork
提供 hvigorw 与版本锁定。

---

## #4 [高] 只覆盖 *_ohos 插件不生效, 必须覆盖基础包 (背书缺失体验差)

**现象**: 仅 `dependency_overrides: shared_preferences_ohos: ...` 时,
`GeneratedPluginRegistrant.ets` 为空 → 运行时
`MissingPluginException(... getAll on channel .../shared_preferences)`。

**根因**: 官方 `shared_preferences` 等不背书 (endorse) 鸿蒙实现; 必须把
**基础包**也覆盖到 tpc fork (其 pubspec 含 `ohos: default_package:
xxx_ohos`) 才会注册。

**建议**: 这是联邦插件机制的固有约束, 但 fork 文档应显著提示"必须覆盖
基础包", 否则使用者极易踩 (注册表静默为空, 错误延迟到运行时)。

---

## #5 [中] NavigationChannel.ets: selectSingleEntryHistory 抛 null 异常

**现象**: go_router (Router API) 应用启动时, 原生侧日志:
```
NavigationChannel --> method = selectSingleEntryHistory
MethodChannel# --> Failed to handle method call: Cannot read property get of null
  at notifyPageChanged @ohos/flutter_ohos/.../NavigationChannel.ets:167:40
DartMessenger --> Uncaught exception in binary message listener:
  undefined is not callable  at .../MethodChannel.ets:228:75
```

非致命 (之后仍 onFirstFrame), 但每个 Router-based 应用启动都刷这个未捕获
异常。`NavigationChannel.ets:167` 对一个可能为 null 的对象调用 `.get`。

**建议**: 在 `notifyPageChanged` / `selectSingleEntryHistory` 处理里加
null 守卫。

---

## 已澄清 / 非 fork 问题 (记录备查)

- 纯血鸿蒙零售机 (Mate 80) 拒装 OpenHarmony 自签 hap
  (`fail to verify pkcs7 file`, code:9568257), 且
  `persist.bms.ohCert.verify` 被设备拒绝设置 (errNum 1001)。这是华为
  安全模型, 非 fork 问题 — 必须用 AGC 调试证书。
- OpenHarmony bundleName 至少三段且第三段不能用 ohos/harmony/huawei/hms
  等保留字, 是平台规范, 非 fork 问题。
