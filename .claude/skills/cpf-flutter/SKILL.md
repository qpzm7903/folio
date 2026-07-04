---
name: cpf-flutter
description: >
  用 CPF-Flutter (OpenHarmony 鸿蒙化 Flutter fork, gitcode.com/CPF-Flutter/
  flutter_flutter) 把任意 Flutter 应用搬到 HarmonyOS/OpenHarmony 的通用方法论:
  工具链获取、双 SDK 策略、ohos 工程配置、构建 hap、签名装机、联邦插件接入、
  hdc 调试, 以及 fork 的已知 bug。当要将 Flutter app 适配鸿蒙、评估鸿蒙化
  Flutter 可行性、排查 hvigor/ohpm/hap 构建问题时使用。
  本仓库 Folio 的具体落地见 skill `ohos-dev` + docs/wiki/ohos/。
version: 1.0.0
verified_with: "flutter_flutter 3.35.8-ohos-1.0.1 · OpenHarmony 6.1 SDK (API 23) + 6.0 SDK (API 20) 并存 · hvigor 5.19.8 · macOS arm64 · 真机 Mate 80 (HarmonyOS 6.1)"
caveat: CPF-Flutter 在快速演进, 下方版本/坑可能随版本变化; 用前对一下当前 tag。
---

# 用 CPF-Flutter 做 Flutter → 鸿蒙

> 仓库已迁移到 **CPF-Flutter** 组织 (旧 openharmony-sig/openharmony-tpc 不再维护)。
> 核心心智: **Dart 业务代码基本原样复用, 只重做原生层 + 工具链适配**。
> 平台差异全部挡在能力开关 (如 `PlatformCapabilities.isOhos`) 后面。

## 1. 工具链 (全部免登录, 华为云公开镜像)

官方 Command Line Tools 下载要登录, 但等价物在 `repo.huaweicloud.com` 全公开。

| 组件 | 取法 |
|------|------|
| Flutter 鸿蒙 fork | `git clone https://gitcode.com/CPF-Flutter/flutter_flutter.git`; **checkout 正式 tag** (如 `3.35.8-ohos-1.0.1`), 别用分支 HEAD (浅克隆无 tag → `flutter --version` = 0.0.0-unknown → SDK 约束失败) |
| OpenHarmony SDK | `repo.huaweicloud.com/openharmony/os/<ver>-Release/` 下 `L2-SDK-MAC-M1-PUBLIC.tar.gz` (Apple Silicon) / `ohos-sdk-mac-public.tar.gz` (Intel) / `ohos-sdk-windows_linux-public.tar.gz`。解包后把 5 个 zip 摆成 `<api>/{ets,js,native,toolchains,previewer}` |
| ohpm | `repo.huaweicloud.com/harmonyos/ohpm/5.0.2/oh-command-line-tools-20240715.zip` (纯 node, 跨平台) |
| hvigor | npm 装: `@ohos:registry=https://repo.harmonyos.com/npm/` + 主 registry npmjs, `--legacy-peer-deps`。**版本钉 5.19.x** (5.2.2 太旧报 "hvigorConfig not available", 6.x 报 "this.getInstance is not a function") |
| hdc (设备桥, 等价 adb) | 就在 SDK 的 `<api>/toolchains/hdc` |

下载提速: 镜像单流慢, curl `-r` 切 8 段并行 (zsh `rm part_*` 无匹配会中断, 写成 bash 脚本)。

## 2. 双 SDK 策略 (重要)

- **官方 stable Flutter** 跑 `flutter analyze` / `flutter test` / CI (lint、Dart 版本与 CI 对齐)。
- **CPF-Flutter fork** 只跑 `flutter build hap`。
- 别混: fork 的 Dart 版本旧、`pub get` 会把 `pubspec.lock` 降级重写 (构建后 `git checkout pubspec.lock` 还原)。用 PATH 前缀切换两个 SDK。

## 3. 关键环境变量 (build hap 必需)

```bash
export OHOS_SDK_HOME=<sdk>            # doctor 认这个 (OpenHarmony 布局)
export HOS_SDK_HOME=<hmos伪装>        # build hap 硬要 HmosSdk! 用符号链接把 OHOS SDK
                                     #   伪装成 <dir>/<api>/sdk-pkg.json 布局即可过校验
export OHOS_BASE_SDK_HOME=<sdk>
export NODE_PATH=<hvigor>/node_modules  # 让 pub-cache 里的插件 har 的 hvigorfile.ts
                                     #   能 require('@ohos/hvigor-ohos-plugin')
export PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```
`flutter create --platforms ohos` 生成的工程**不带 hvigorw**, 但 doctor 要它在
PATH; hvigor 是纯 node CLI, npm 装后手写 shim 脚本即可。

## 4. ohos 工程 OpenHarmony 化 (模板默认按 HarmonyOS 生成, 逐项改)

| 文件 | 字段 | 改为 |
|------|------|------|
| `ohos/build-profile.json5` | products[].runtimeOS | `OpenHarmony` |
| 同上 | compatibleSdkVersion / compileSdkVersion | **整数** e.g. `23` 或 `20` (HarmonyOS 才用 "5.1.0(18)" 字符串) |
| `ohos/entry/build-profile.json5` | targets[].runtimeOS | `OpenHarmony` |
| `ohos/entry/src/main/module.json5` | deviceTypes | `[default, tablet]` (**无 phone**, OpenHarmony device-define 里手机是 default) |
| `ohos/AppScope/app.json5` | bundleName | ≥3 段, 第三段不能用 **ohos/harmony/huawei/hms** 保留字 (AGC + schema 都拒) |

`flutter build hap` 末尾 exit≠0 + "请用 DevEco 配置签名" 是**正常**的; 看
"Running Hvigor task assembleHap" 那行判断成败, hap 在
`ohos/entry/build/default/outputs/default/entry-default-unsigned.hap`。

## 5. 签名装机

- **纯血鸿蒙零售机 (HarmonyOS NEXT, 如 Mate 系列) 必须华为 AGC 调试证书。**
  OpenHarmony SDK 自带的 `OpenHarmony.p12` 自签链能离线签出 hap, 但零售机拒装
  (`fail to verify pkcs7 file` code:9568257), 且绕过开关
  `persist.bms.ohCert.verify` 被设备拒绝 (errNum 1001)。自签只能用于开发板/模拟器。
- **AGC 流程 (唯一要华为账号的环节)**: `hap-sign-tool.jar generate-keypair`+`generate-csr`
  生成密钥+CSR → AGC 网页: 证书管理传 CSR 拿 `.cer` + 设备管理填 UDID
  (`hdc shell bm get --udid`) + 应用下加调试 Profile 拿 `.p7b` → `hap-sign-tool.jar
  sign-app -mode localSign -appCertFile .cer -profileFile .p7b ...` → `hdc install -r`。
- 不装 DevEco 也能全程命令行 (DevEco 的"自动生成签名"只是把这几步一键化)。

## 6. 联邦插件接入 (当前最大的坑)

要点按顺序:
1. **必须覆盖基础包到 CPF/tpc fork**, 不能只覆盖 `*_ohos`。官方
   `shared_preferences`/`path_provider`/`file_selector` 不背书鸿蒙实现, 只覆盖
   `*_ohos` 时 `GeneratedPluginRegistrant` 为空 → 运行时 `MissingPluginException`。
   fork 的基础包 pubspec 里有 `ohos: default_package: xxx_ohos` 背书。
2. 插件 har 的 hvigorfile.ts 在 pub-cache 下要 `@ohos/hvigor-ohos-plugin` → 靠
   `NODE_PATH` 兜底 (见 §3)。
3. **⚠ 已知阻塞 (verified_with 版本)**: 从 pub-cache 集成联邦插件时, hvigor 生成
   `.hvigor/dependencyMap/dependencyMap.json5` 的模块路径有 off-by-one / 模块解析
   bug → ohpm `module xxx_ohos does not exist`, 构建失败。flutter 侧改 `_relative`
   无效 (hvigor 自己重定相对化)。
   **务实绕过**: 启动期不依赖这些插件 —— 用内存版 shared_preferences
   (`setMockInitialValues`, 加 `// ignore: invalid_use_of_visible_for_testing_member`),
   path_provider 缺失靠 try/catch 兜住, drift 自动回退。代价: 数据不跨重启持久化。
   等上游修复后再恢复。Folio 的具体降级见 skill `ohos-dev` #PLUGIN。

## 7. 调试 (hdc / hilog)

```bash
hdc list targets                  # Unauthorized → 手机上点"允许调试"
hdc shell aa start -a EntryAbility -b <bundle> -m entry   # 拉起 (屏幕要解锁亮屏)
hdc shell hilog -r                # 清; hilog -x | grep <bundle> 看
hdc shell snapshot_display -f /data/local/tmp/s.jpeg && hdc file recv ... # 截屏
```
**Dart 未捕获异常会渲染成本地化错误页, 截屏看最快**, 比翻 hilog 准。
原生崩溃栈在 `/data/log/faultlog/faultlogger/`。

## 8. 给上游提 issue/PR

遇到 fork bug 记录 (现象 + 复现环境 + 根因 + 最小复现), 提到
`gitcode.com/CPF-Flutter/flutter_flutter`。Folio 已整理的清单见
`docs/wiki/ohos/upstream-issues.md` (5 个: 联邦插件路径、NODE_PATH、hvigor 版本、
背书提示、NavigationChannel null)。
