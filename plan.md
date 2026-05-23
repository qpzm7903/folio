# folio · 小金库 项目规划

> 一个用来"再次遇见你自己摘下的句子"的 Flutter 跨平台应用。
> 视觉、交互、文案严格遵循 `.claude/skills/xiao-jinku-desig` 的设计规范。

---

## 长期规划 (Long-term)

终止条件依据：以下所有项全部为 `[x]` 已完成，且最新一次 GitHub Actions workflow 状态为 `success`。

- [ ] L01 · 单机金句金库 (CRUD + 标签 + 搜索)
- [ ] L02 · 全屏屏保模式 (无重复随机轮播 + 切换频率)
- [ ] L03 · 批量导入 (粘贴大段文本自动分行)
- [ ] L04 · 主题切换 (青纸 / 林夜) + 跟随系统
- [ ] L05 · 自托管 Noto Serif SC + EB Garamond 字体 (禁止 Google Fonts CDN)
- [ ] L06 · 本地化日志系统 (`getApplicationSupportDirectory()` 落盘)
- [ ] L07 · Android 桌面小组件 (小/中/大三尺寸)
- [ ] L08 · iOS 桌面小组件 + 全平台屏保 / 锁屏样式
- [ ] L09 · 自定义背景图 (用户相册 + 内置纯色 + 纸纹叠加)
- [ ] L10 · 金句导出 / 导入 (.txt / .json) + 跨设备迁移
- [ ] L11 · 全文搜索 + 标签管理 + 智能分组
- [ ] L12 · drift 持久化迁移 (替换 JSON 文件存储)
- [ ] L13 · go_router 路由 + Web 深链
- [ ] L14 · 响应式适配 (手机 / 折叠屏 / 平板 / 桌面 / Web)
- [ ] L15 · 国际化 (中文为主，预留 en 框架)
- [ ] L16 · 完整测试覆盖 (单元 + Widget + 集成)
- [ ] L17 · 多平台 CI 产物 (Android APK/AAB · iOS IPA · Web · Win · macOS · Linux)

---

## 中期规划 (Mid-term, 1-3 个 MINOR)

- v0.1 · 首版核心金库 + 屏保 + 主题
- v0.2 · 本地字体自托管 + drift 持久化迁移 (含一个重构 PATCH)
- v0.3 · 自定义背景图 + 导出/导入
- v0.4 · Android 桌面小组件
- v0.5 · 全文搜索 + 标签管理
- v0.6 · 响应式适配 + Web 深链

## 短期规划 (Short-term, 当前 MINOR 内)

见下方 v0.1.0 任务清单。

---

## 版本日志

### v0.1.1 — workflow 修复

- v0.1.0 的 `dart format --set-exit-if-changed` 在 CI 上拦下了 12 个未格式化文件 (本地没有 dart CLI, 没法预先校验)。
- 本版安装 dart-sdk 后 `dart format lib test` 重新整理 22 个文件 (含 widget/screen/test) 的换行与缩进; 风格检查现在 0 diff。
- 不动业务逻辑。

### v0.1.0 — 首版核心

目标：跑通 "写一句 → 进金库 → 屏保里再次遇见" 的核心闭环。

任务清单：

- [ ] T01 · Flutter 工程骨架 (pubspec / analysis / gitignore / Android / Web)
- [ ] T02 · XJKTokens (颜色 / 字号 / 间距 / 圆角 / 阴影) 翻译自 `colors_and_type.css`
- [ ] T03 · ThemeData (青纸 / 林夜 双主题，Material 3 紧凑型)
- [ ] T04 · 日志系统 (talker + 文件落盘 `getApplicationSupportDirectory`)
- [ ] T05 · Quote 实体 + JSON 文件持久化 + Riverpod Provider + 种子数据
- [ ] T06 · `TopBar` / `QuoteCard` / `BottomNav` / `SettingRow` / `Fab` 基础组件
- [ ] T07 · Library 屏 (今日金句 + 标签筛选 + 列表)
- [ ] T08 · Editor 屏 (新建金句)
- [ ] T09 · Display 屏 (全屏无重复轮播 + 640ms 交叉淡入)
- [ ] T10 · Settings 屏 (主题切换 + 频率展示 + 关于)
- [ ] T11 · Import Sheet (粘贴大段文本，自动分行)
- [ ] T12 · 本地化 Lucide 图标 SVG (28 个)
- [ ] T13 · `flutter_svg` 渲染图标 (禁止换图标库)
- [ ] T14 · 单元测试：无重复 shuffle 算法
- [ ] T15 · GitHub Actions workflow (Android APK + Web bundle)
- [ ] T16 · README.md (项目介绍 + 截图占位)
- [ ] T17 · tag v0.1.0 推送，验证 workflow 成功

非目标（推迟到后续版本）：

- 自托管字体文件 (v0.2 落地，本版本暂用系统中文衬线回退 + 在 README 标注 substitution flag)
- drift 持久化 (v0.2 重构 PATCH)
- 桌面小组件 (v0.4)
- 自定义背景图 / 导出 (v0.3)
- iOS / Windows / macOS / Linux 构建 (v0.x 启用，本版本仅 Android + Web)
- go_router (v0.6 引入，本版本 IndexedStack + Navigator.push 即可)
