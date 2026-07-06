# 小金库 · Folio

> 一句话停一停。

Flutter 跨平台应用 —— 收集你读到的金句, 让它们以屏保、桌面组件的方式再次遇见你自己。
视觉与交互严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范 (传统色六主题, 衬线为主, 不用 emoji)。

## 状态

最新版本: **v0.28.1** — 重构 PATCH: sheet 骨架 + SnackBar 样板收敛。
长期规划 **21/23 完成** (L20 鸿蒙 6.0 适配 / L21 鸿蒙服务卡片 已核心可用, L22 设计系统 2.0 已真机验收, L23 标签管理已发布)。

最近版本:

- **v0.28.x** — 纯文本导出: 导出 sheet 双格式切换 —— JSON 完整备份 /
  纯文本每行一句 (可读, 可被批量导入吃回, 不含标签日期), 落地设计源
  「备份为 .txt」; 重构 PATCH: `XJKSheetBody` 收敛 4 个 sheet 头部骨架 +
  `showText` 扩展清零全仓 SnackBar 样板。
- **v0.27.x** — 字号设置: 设置屏「字号」行可选 标准/大/特大 三档,
  全局文字随档缩放且与系统无障碍缩放叠乘 (不覆盖系统设置);
  重构 PATCH: 设置层泛型 decoder/picker 收敛七份同构样板。
- **v0.26.x** — 屏保轮播续位: 无重复洗牌顺序以 quote-id 序列持久化,
  重启后接着上次的位置继续放 (HANDOFF 第二轮收尾); 金库内容变更时
  自动放弃旧档重新洗牌, 数据损坏静默回退不打扰屏保。重构 PATCH:
  测试基建收敛 (FakeQuoteRepository 等四份副本合一)。
- **v0.25.x** — 屏保版式补齐 (L22 收官, 全 9 版式) + 版式样式收敛重构。
- **v0.24.x** — 批量导入增强 (分句/去重/勾选保留, 用户需求"导入文本批量建句");
  重构 PATCH: 共享 `XJKSelectCheck` 勾选组件 + 导入行按压反馈与读屏语义。
- **v0.23.x 及更早** — 标签管理内联模式 (L23) + 写入链路健壮化 / 金库批量操作
  (多选+批量取出) / 标签接缝收敛 / 小组件配色 3→6 / 三栏导航对齐设计系统 /
  鸿蒙卡片视觉改版 / 设计系统 2.0 (六主题+5版式) / 鸿蒙服务卡片 / 鸿蒙 6.0 适配 /
  桌面小组件自动刷新 / drift 持久化 / 全平台 CI 等, 详见 [plan.md](./plan.md) 版本日志。

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
