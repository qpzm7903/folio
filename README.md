# 小金库 · Folio

> 一句话停一停。

Flutter 跨平台应用 —— 收集你读到的金句, 让它们以屏保、桌面组件的方式再次遇见你自己。
视觉与交互严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范 (传统色六主题, 衬线为主, 不用 emoji)。

## 状态

最新版本: **v0.20.1** — 三栏导航对齐设计系统 (首页 / 金库 / 我的)。
长期规划 **20/22 完成** (L20 鸿蒙 6.0 适配 / L21 鸿蒙服务卡片 已核心可用, L22 设计系统 2.0 待真机验收)。

最近版本:

- **v0.20.1** — 重构 PATCH: 三栏导航对齐设计系统, 4 tab (金库/屏保/组件/设置) →
  3 tab (首页/金库/我的); 初始路由改首页 (display); 小组件配置从独立 tab 收进
  「我的」section; 新增 home / user-round 图标。
- **v0.20.0** — 鸿蒙卡片视觉改版 (对标西窗烛/句子控) + 展示去序号: 卡片黄金比
  重排 + 跟随主题配色; displayQuoteText 剥掉开头序号前缀 (卡片/屏保/金库列表)。
- **v0.19.3** — 修卡片图标太小 + 顺序模式仍随机 (真机反馈)。
- **v0.19.2** — 修 #13 鸿蒙卡片"换一句"文字按钮 → 音乐播放器式图标。
- **v0.19.1** — 修 #11 #12 小组件整库随机/顺序 + 金库滚动条。
- **v0.19.0 及更早** — 设计系统 2.0 (传统色六主题 + 屏保 5 版式) / 鸿蒙服务卡片 /
  鸿蒙 6.0 适配 / 桌面小组件自动刷新 / drift 持久化 / 全平台 CI 等, 详见
  [plan.md](./plan.md) 版本日志。

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
