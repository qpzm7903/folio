# 小金库 · Folio

> 一句话停一停。

Flutter 跨平台应用 —— 收集你读到的金句, 让它们以屏保、桌面组件的方式再次遇见你自己。
视觉与交互严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范 (传统色六主题, 衬线为主, 不用 emoji)。

## 状态

最新版本: **v0.24.1** — 重构 PATCH: 勾选组件收敛。
长期规划 **21/23 完成** (L20 鸿蒙 6.0 适配 / L21 鸿蒙服务卡片 已核心可用, L22 设计系统 2.0 已真机验收, L23 标签管理已发布)。

最近版本:

- **v0.24.1** — 重构 PATCH (行为等价): 圆形勾选框抽成共享 `XJKSelectCheck`
  (金库多选卡片与导入勾选行共用一份 `.qcheck` 视觉, 消除复制漂移);
  导入勾选行换 InkWell 按压反馈并加 Semantics 复选框语义 (读屏可感知)。
- **v0.24.0** — 批量导入增强 (用户需求"导入文本批量建句"): 粘贴长文自动分句、
  去空白、**去重**, 识别出的句子进入可勾选列表 (默认全选, 点行切换, 圆形勾选
  沿用 `.qcheck` 视觉), 按钮按选中数收入; 文本一变勾选状态整体重置, 保证每批
  内容"默认全选"不残留。
- **v0.23.1** — 重构 PATCH: 金库写入链路健壮化 —— `_mutate` 落盘失败时回滚
  state 并返回 `false` (此前 UI 显示成功、重启后数据复活), 编辑/导入/删除/
  标签操作等 9 个调用点失败时 snackbar 提示且不关闭输入面, 内容保留可重试。
- **v0.23.0** — 标签管理内联模式 (L23): 金库标签行末新增「✎ 管理」pill, 管理态下
  具名标签变虚线可删 (x 图标), 点删弹确认 —— 删除后句子移到「未分类」虚拟标签
  (句子不删), 正筛选被删标签时自动回「全部」。写入侧净化: 标签输成「全部」视为
  无标签。经 14-agent 多维审查 workflow (正确性/设计/性能/安全 + 对抗验证) 修复
  8 项发现后发布。视觉 100% 对照 `xiao-jinku-desig` 的 managingTags 分支设计。
- **v0.22.x 及更早** — 金库批量操作 (多选+批量取出) / 标签接缝收敛 / 小组件配色
  3→6 / 三栏导航对齐设计系统 / 鸿蒙卡片视觉改版 / 设计系统 2.0 (六主题+5版式) /
  鸿蒙服务卡片 / 鸿蒙 6.0 适配 / 桌面小组件自动刷新 / drift 持久化 / 全平台 CI 等,
  详见 [plan.md](./plan.md) 版本日志。

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
