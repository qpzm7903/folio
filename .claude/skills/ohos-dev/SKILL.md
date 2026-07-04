---
name: ohos-dev
description: >
  Folio 鸿蒙 (HarmonyOS/OpenHarmony) 开发速查 — 在本仓库构建 .hap、AGC 签名、
  hdc 装机、真机拉起、看日志/截屏、以及已知坑的规避。当任务涉及鸿蒙/ohos/
  HarmonyOS/Mate 80、构建或安装 hap、用 hdc/hilog 调试、改 ohos/ 工程或
  PlatformCapabilities.isOhos 时使用。深度背景见 docs/wiki/ohos/。
version: 1.0.0
source: L20 v0.17 真机适配实战
---

# Folio · 鸿蒙开发速查

> 一句话现状: 鸿蒙版**已在 Mate 80 / HarmonyOS 6 跑通** (金库/屏保/主题)。
> 全程命令行、不装 DevEco。存储走内存降级 (见下方"已知坑 #PLUGIN")。

## 0. 工具链位置 (已装好, 路径稳定)

| 用途 | 路径 |
|------|------|
| 官方 Flutter (analyze/test/CI 对齐) | `~/sdks/flutter-stable` (3.44, Dart 3.12) |
| 鸿蒙 fork (只用来 build hap) | `~/sdks/flutter-ohos` (3.35.8-ohos, Dart 3.9) |
| OpenHarmony SDK (API 23 + 20 并存) | `~/sdks/ohos-sdk/sdk` (`23/` 编译, `20/toolchains/hdc` 等) |
| HarmonyOS SDK 伪装 (build 要 HmosSdk) | `~/sdks/hos-sdk` (符号链接到 ohos-sdk, 20/23 分别链) |
| ohpm | `~/sdks/oh-command-line-tools/ohpm/bin` |
| hvigor 5.19.8 + 插件 | `~/sdks/hvigor` (核心+插件单实例, 勿换版本) |

环境变量都已封进 `tool/ohos/build_hap.sh`, 平时不用手动 export。
丢失/重装见 `docs/wiki/ohos/01-环境搭建.md` (免登录华为云镜像)。

## 1. 日常命令 (按这个顺序)

```bash
# analyze / test / 格式化 —— 永远用官方 stable, 不用 fork
export PATH="$HOME/sdks/flutter-stable/bin:$PATH"
flutter analyze        # 必须零警告
flutter test           # 必须全过
dart format .

# 构建鸿蒙 hap (脚本自带全部 env)
bash tool/ohos/build_hap.sh debug
#   ⚠ 脚本末尾 exit 1 + "请通过DevEco Studio配置调试签名" 是正常的!
#     hap 已产出在 ohos/entry/build/default/outputs/default/entry-default-unsigned.hap
#     判断成功看 "Running Hvigor task assembleHap ... 7s" 那行, 不看 exit code。

# AGC 签名 + 装机 (需 ohos/.signing/agc/ 下有 folio.p12 + folio.cer + folio.p7b)
SIGN_MODE=agc bash tool/ohos/sign_and_install.sh

# 真机拉起 + 看日志 + 截屏 (一键)
bash tool/ohos/run_device.sh
```

## 2. hdc 速查 (toolchains 已在 build/run 脚本里上 PATH)

```bash
export PATH="$HOME/sdks/ohos-sdk/sdk/20/toolchains:$PATH"
hdc list targets                         # 设备; 显示 "Unauthorized" 要在手机上点允许调试
hdc shell bm get --udid                  # 取 UDID (AGC 注册调试设备要用)
hdc shell aa start -a EntryAbility -b app.folio.quotes -m entry   # 拉起 (屏幕必须解锁亮屏)
hdc shell aa force-stop app.folio.quotes # 杀进程
hdc shell hilog -r                       # 清日志
hdc shell hilog -x | grep app.folio.quotes   # 看日志 (Dart 异常进 "flutter settings log message")
hdc shell snapshot_display -f /data/local/tmp/s.jpeg && hdc file recv /data/local/tmp/s.jpeg /tmp/s.jpeg  # 截屏 (再用 Read 看)
hdc install -r <signed.hap>              # 装机
```

看日志技巧: Dart 层未捕获异常会以本地化错误页显示, **直接截屏看最快** (比翻
hilog 准)。崩溃栈也可查 `hdc shell ls /data/log/faultlog/faultlogger/`。

## 3. 关键约定 (别改错)

- **包名 `app.folio.quotes`** — 鸿蒙要 ≥3 段, 且第三段不能用
  ohos/harmony/huawei/hms 等保留字 (AGC 会拒, hvigor schema 也会拒)。
  Android/iOS 仍是 `app.folio`。
- **ohos 差异全走 `PlatformCapabilities`** — UI/service 只问能力 (isOhos /
  supportsFileSelector / supportsHomeWidget / supportsSetWallpaper), 不问平台。
- **analyze/test 用 flutter-stable, build hap 用 flutter-ohos** — 别混 (Dart
  版本/lint 不同; fork 的 pub get 会把 pubspec.lock 降级, 脚本已自动 checkout 还原)。
- `ohos/` 工程**直接进仓库**; 签名材料在 `ohos/.signing/` (gitignore, 含 UDID/
  私钥, 永不入库)。

## 4. 已知坑 → 直接照修

| 现象 | 真因 | 修法 |
|------|------|------|
| **#PLUGIN** ohpm `module xxx_ohos does not exist` / 运行时 `MissingPluginException getAll on shared_preferences` | flutter_ohos 工具链集成 pub-cache 联邦插件有 bug (hvigor dependencyMap 路径 off-by-one) | **现状不集成这三个插件**; bootstrap 在 ohos 用内存 prefs 降级。别再把 path_provider/shared_preferences/file_selector 的 ohos override 加回去期待能用。详见 `docs/wiki/ohos/upstream-issues.md #1` |
| `No Hmos SDK found` | build 要 HmosSdk, doctor 只认 OHOS_SDK | 已设 `HOS_SDK_HOME=~/sdks/hos-sdk` (伪装布局, 含 sdk-pkg.json), build_hap.sh 里有 |
| `Cannot find module @ohos/hvigor-ohos-plugin` | pub-cache 插件 har 的 hvigorfile.ts 找不到 hvigor | build_hap.sh 已设 `NODE_PATH=~/sdks/hvigor/node_modules` |
| `TypeError this.getInstance is not a function` | hvigor 核心/插件双实例或版本错 | 用 5.19.8, 且 hvigor node_modules 单实例 (已配好, 勿动) |
| `fail to verify pkcs7 file` code:9568257 装机失败 | 用了 OpenHarmony 自签 | 零售机必须 AGC 调试证书 (`SIGN_MODE=agc`); 自签只能用于开发板/模拟器 |
| `runtimeOS ... does not match` / `compileSdkVersion` / `deviceTypes phone` 构建报错 | 模板按 HarmonyOS 生成 | build-profile 用 `runtimeOS: OpenHarmony` + 整数 `compileSdkVersion: 23` + `compatibleSdkVersion: 20`; module.json5 `deviceTypes: [default, tablet]` (无 phone)。compileSdkVersion 23 是为衬线字体 (getLocalInstance 需 API 22+), 纯无衬线仍可用 20。 |
| `screen is locked` 拉起失败 10106102 | 开发者模式下 hdc 不能自动解锁 | 手机解锁亮屏后再 `aa start` |

## 5. AGC 调试证书 (唯一要华为账号的环节)

只在证书/设备/profile 变更时做。本地已有 `ohos/.signing/agc/folio.p12`(密钥)
+ `folio.csr`(上传 AGC)。网页三步: 证书管理传 csr 拿 `.cer` → 设备管理填
UDID → 应用 (包名 app.folio.quotes) 加调试 Profile 拿 `.p7b`。详见
`docs/wiki/ohos/03-签名装机.md §2`。Profile 文件名 AGC 会带前缀, 放进
`ohos/.signing/agc/` 后脚本会自动找 `*.p7b` (或复制成 folio.p7b)。

## 6. 待办 / 恢复点

- 上游 (CPF-Flutter) 修复联邦插件 bug 后: 恢复 `tool/ohos/pubspec_overrides.ohos.yaml`
  里注释的覆盖 + 删 `bootstrap.dart` 的 ohos 内存 prefs 守卫 → 恢复 drift 真持久化。
- L21: 鸿蒙服务卡片 已完成 (含衬线字体 Noto Serif SC, compileSdkVersion 23)。
- "设为壁纸" 鸿蒙为系统 API, 三方大概率不可用。
