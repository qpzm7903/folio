# 小金库 · Folio

> 一句话停一停。

Flutter 跨平台应用 —— 收集你读到的金句, 让它们以屏保、桌面组件的方式再次遇见你自己。
视觉与交互严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范 (传统色六主题, 衬线为主, 不用 emoji)。

## 状态

最新版本: **v0.19.0** — 设计系统 2.0: 传统色六主题 + 屏保精选 5 版式。
长期规划 **20/22 完成** (L20 鸿蒙 6.0 适配 / L21 鸿蒙服务卡片 已核心可用, L22 设计系统 2.0 待真机验收)。

最近版本:

- **v0.19.0** — 设计系统 2.0: 主题 2→6 (青纸/天青/月白/绛霞/林夜/青黛, 含 2 暗);
  屏保 5 版式 (页/满/印/时/片) + 黄金比锚点 + 句长分级字号 + 换版式/持久化。
- **v0.18.2** — 重构 PATCH: 主题系统注册表化 + 屏保版式宿主抽象 (L22 铺路, 无可见变化)。
- **v0.18.1** — 修鸿蒙数据丢失: app 数据落盘 ArkTS preferences (真机验证)。
- **v0.18.0** — L21 鸿蒙服务卡片 (静态卡片 + 数据桥, 真机验证)。
- **v0.17.x** — L20 鸿蒙 6.0 适配 (OpenHarmony Flutter fork, 纯 Dart 核心功能跑通)。

更早版本见 [plan.md](./plan.md) 版本日志。

## 截图

> v0.1 暂未提供截图; 后续版本补充。

## 跑起来

```bash
# 1. 下载本地字体 (OFL 许可, 一次性, 不进 git)
bash tool/fetch_fonts.sh

# 2. 装依赖
flutter pub get

# 3. 生成平台目录 (首次)
flutter create --org app --project-name folio --platforms=android,web .

# 4. 跑起来
flutter run -d chrome      # web
flutter run -d <device>    # Android
```

## 构建产物

每个 tag (`v*`) 推送都会触发 GitHub Actions, 生成以下产物并挂到 GitHub Release:

**v0.15.2 起 (Issue #10)** 暂时只发 Android APK, 待 Android 端彻底稳定后再恢复其他平台构建:

- Android APK (`folio-<version>-android.apk`)

历史版本 (v0.4.0 ~ v0.15.1) 还包含 Web bundle / Linux / Windows / macOS,
对应 workflow 见 `git show v0.15.1:.github/workflows/build.yml`。
iOS IPA 一直未构建 (需要 Apple 开发者证书, L08 一并处理)。
流水线在 `.github/workflows/build.yml`。

## 设计

颜色 / 字号 / 间距 / 圆角的唯一来源是 skill 里的 `colors_and_type.css`,
翻译到 `lib/theme/tokens.dart` 的 `XJKTokens` 类。六个主题经 `XJKThemeId`
注册表 (`lib/theme/xjk_theme_id.dart`) + `XJKTokens.forId` 查表, 新增主题
只需追加枚举值 + token 工厂。屏保版式见 `lib/presentation/display/display_layouts.dart`。

字体: 本地加载 Noto Serif SC + EB Garamond + Noto Sans SC (`assets/fonts/`),
**禁止运行时走 Google Fonts CDN**。

图标: 28 个 Lucide SVG, 落在 `assets/icons/`, 通过 `flutter_svg` 渲染。

## 长期规划

见 [plan.md](./plan.md)。
