# 小金库 · Folio

> 一句话停一停。

Flutter 跨平台应用 —— 收集你读到的金句, 让它们以屏保、桌面组件的方式再次遇见你自己。
视觉与交互严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范 (青纸 / 林夜 双主题, 衬线为主, 不用 emoji)。

## 状态

最新版本: **v0.4.0** — 多平台 CI 产物 (+ Linux / Windows / macOS 桌面包).
功能上等价于 v0.1.0: 首版核心金库 + 屏保 + 主题切换 + 批量导入。

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

- Android APK (`app-release.apk`)
- Web bundle (`folio-web.zip`)
- Linux x64 (`folio-linux-x64.tar.gz`)
- Windows x64 (`folio-windows-x64.zip`)
- macOS (`folio-macos.zip`, 不签名, 首次打开需 ctrl+click 绕过 Gatekeeper)

iOS IPA 暂不构建 (需要 Apple 开发者证书, L08 一并处理)。
流水线在 `.github/workflows/build.yml` 。

## 设计

颜色 / 字号 / 间距 / 圆角的唯一来源是 skill 里的 `colors_and_type.css`,
翻译到 `lib/theme/tokens.dart` 的 `XJKTokens` 类。

字体: 本地加载 Noto Serif SC + EB Garamond + Noto Sans SC (`assets/fonts/`),
**禁止运行时走 Google Fonts CDN**。

图标: 28 个 Lucide SVG, 落在 `assets/icons/`, 通过 `flutter_svg` 渲染。

## 长期规划

见 [plan.md](./plan.md)。
