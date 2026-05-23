# 交给 Claude Code 开发完整应用（Flutter 版）

> 这份设计系统已经按 Claude Code 的 **Agent Skill** 规范打好包了（见根目录的 `SKILL.md`）。
> 下面是用 **Flutter** 从「设计稿」到「能运行的跨平台应用」的完整路径。

---

## 一句话总结

把这整个文件夹丢进 Claude Code 的 skills 目录，然后在新建项目里说：「用 xiao-jinku-design 这个 skill，帮我建一个 Flutter 应用」。

---

## 推荐技术栈

| 部分 | 推荐 | 说明 |
|---|---|---|
| **框架** | **Flutter 3.22+ / Dart 3+** | 一份代码 → Android / iOS / macOS / Windows / Linux / Web |
| **主题系统** | `ThemeData` + `ThemeExtension<XJKTokens>` | 把 `colors_and_type.css` 的 token 装进自定义 `ThemeExtension`，组件用 `Theme.of(context).extension<XJKTokens>()` 取值 |
| **状态管理** | **Riverpod**（推荐）或 Provider | 简洁、可测、cross-platform |
| **本地存储** | **drift**（SQLite ORM）+ **shared_preferences** | drift 存金句库；shared_preferences 存设置 |
| **桌面小组件**（仅 Android / iOS） | **home_widget** plugin | Flutter 应用 + 一小段 native 代码（Android: Glance/Kotlin；iOS: WidgetKit/Swift）。组件 UI 必须用 native，但**数据 + 视觉规范从设计系统过来** |
| **屏保 / 桌面壁纸**（Android） | **wallpaper_manager_plus** | 把当前金句渲染成图片设为壁纸 |
| **后台轮播** | **workmanager** plugin | 周期性触发：换下一句、更新小组件 |
| **图片选择** | **image_picker** + **photo_manager** | 用户挑自定义背景 |
| **SVG 渲染** | **flutter_svg** | 直接渲染 `assets/` 里的 logo、Lucide 图标 |
| **字体** | `pubspec.yaml → fonts` | 自托管 Noto Serif SC + EB Garamond（**不要**走 Google Fonts CDN，首屏会闪烁） |

> 跨平台覆盖：
> - **Android**：完整体验，包含桌面组件
> - **iOS**：app + 桌面组件（home_widget 也支持）
> - **桌面（mac/Win/Linux）**：app + 全屏「屏保」模式（不能装系统级屏保，但可以做一个独立的全屏 idle window）
> - **Web**：可以跑展示版，但桌面组件 / 后台轮播会退化

---

## 三步走

### 第 1 步：把 skill 装进 Claude Code

Claude Code 的 skills 默认放在：
- 全局：`~/.claude/skills/`
- 项目内：`<your-flutter-project>/.claude/skills/`

把整个 `小金库 Design System/` 文件夹复制进去并改名为 `xiao-jinku-design`（要跟 `SKILL.md` 里的 `name:` 一致）：

```bash
# 项目内（推荐——这样多人协作可以一起带）
flutter create xiaojinku && cd xiaojinku
mkdir -p .claude/skills
cp -r "<解压目录>/小金库 Design System" .claude/skills/xiao-jinku-design

# 或：全局
mkdir -p ~/.claude/skills
cp -r "<解压目录>/小金库 Design System" ~/.claude/skills/xiao-jinku-design
```

下次 `claude` 启动时，skill 就可用了。

### 第 2 步：项目骨架

```bash
cd xiaojinku
claude
```

进入 Claude Code 后，第一次对话直接说：

> 我要做一个 Flutter 跨平台应用 **小金库**。请用 `.claude/skills/xiao-jinku-design` 里的设计指南、颜色、字体、UI kit 作为完整参考。
>
> 主要目标平台：Android + iOS；桌面其次。
>
> 第一步：
> 1. 搭好 Flutter 项目骨架（pubspec、目录、Riverpod、drift、go_router）
> 2. 把 `colors_and_type.css` 翻译成 `lib/theme/`：`tokens.dart`（ThemeExtension<XJKTokens>）+ `theme.dart`（青纸 light / 林夜 dark 两个 ThemeData）
> 3. 把 `assets/` 里的 logo SVG、paper-grain、Lucide 图标拷进 `assets/`，在 pubspec 里注册
> 4. 把 Noto Serif SC + EB Garamond 字体放进 `assets/fonts/`，在 pubspec 里注册
> 5. 主屏先放一个最简单的 ThemeScaffold 验证字体 / 颜色 / 图标都加载对了
>
> 跑通后给我命令，我再让你做下一步。

### 第 3 步：按 UI kit 逐屏实现

骨架搭好之后，按这个顺序让 Claude Code 一屏一屏做：

```
1. 金库（Library）页面           → 参考 ui_kits/android-app/screens.jsx 的 LibraryScreen
2. 编辑器（Editor）               → EditorScreen + 批量导入 ImportSheet
3. 屏保 / 全屏显示（Display）     → DisplayScreen + 不重复轮播逻辑（useNoRepeatShuffle）
4. 自定义小组件页（Widget editor）→ widget-editor.jsx（这是 app 里的"配置"页，不是真的桌面组件）
5. 设置页                        → SettingsScreen
6. 真正的桌面小组件（home_widget）→ Android: Glance Kotlin；iOS: WidgetKit Swift
                                   视觉照 ui_kits/android-widgets/widgets.jsx 的小/中/大三种
```

每一屏可以这样让它做：

> 实现 `library` 屏。**视觉** 100% 对照 `.claude/skills/xiao-jinku-design/ui_kits/android-app/screens.jsx` 的 `LibraryScreen` 组件；**颜色、间距、字号**严格用 `XJKTokens` 里的值；**图标**用 `flutter_svg` 加载 `assets/icons/` 下的 SVG。功能：列表展示、tag 过滤（FilterChip 横向滚动）、点击「今天的金句」push 屏保页、FloatingActionButton push 编辑器。

---

## 看哪些文件、读什么顺序

设计稿是这份文件夹本身。Claude Code 会按 skill 流程先读 `SKILL.md`，再读 `README.md`，但你可以主动指给它更高效：

| 文件 | 干什么用 |
|---|---|
| `README.md` | 总览 — 产品定位、内容语气、视觉基础、字体/图标取舍 |
| `colors_and_type.css` | **所有 token** 在这里。直接对应 Flutter `XJKTokens` ThemeExtension |
| `assets/logo-*.svg` | App icon + 启动屏 + 顶栏标识 |
| `assets/paper-grain.svg` | 纸纹理叠层 |
| `assets/icons/MANIFEST.json` | 用到的 Lucide 图标清单 |
| `ui_kits/android-app/screens.jsx` | **5 屏 UI 的「伪代码」** — 直接翻译到 Dart Widget |
| `ui_kits/android-app/widget-editor.jsx` | 自定义小组件页（在 app 内部） |
| `ui_kits/android-widgets/widgets.jsx` | 三种尺寸桌面组件的视觉参考 |
| `ui_kits/android-app/kit.css` | 所有组件的具体样式（圆角、阴影、状态、字号…） |

---

## token 翻译模板（直接给 Claude Code 看）

```dart
// lib/theme/tokens.dart
@immutable
class XJKTokens extends ThemeExtension<XJKTokens> {
  // surfaces
  final Color paper50, paper100, paper200, paper300, paper400;
  // ink
  final Color ink900, ink700, ink500, ink300;
  // accents
  final Color leaf300, leaf500, leaf700;
  final Color jade300, jade500, jade700;
  final Color bamboo500, bamboo700;
  // semantic (use these in components, not raw)
  final Color bgPage, bgCard, bgRaised, fg1, fg2, fg3, fgMuted;
  final Color accent, accentPressed, accentSoft, accent2, mark, border1, divider;
  // ...

  // 青纸 Tea Paper (light)
  static const light = XJKTokens(
    paper100: Color(0xFFEEF0DF),
    ink900: Color(0xFF1D2A1F),
    leaf500: Color(0xFF7BA05B),
    bamboo500: Color(0xFFB8A866),
    // … 其余对照 colors_and_type.css 的 :root 块
  );

  // 林夜 Forest Night (dark)
  static const dark = XJKTokens(
    paper100: Color(0xFF0E1612),
    ink900: Color(0xFFE6EBD9),
    leaf500: Color(0xFF9EC88A),
    // … 对照 colors_and_type.css 的 [data-theme="night"] 块
  );

  @override
  XJKTokens copyWith({...}) => ...;
  @override
  XJKTokens lerp(...) => ...;
}

// usage:
final t = Theme.of(context).extension<XJKTokens>()!;
Container(color: t.bgCard, ...);
```

字号 / 间距 / 圆角 / 阴影也照 `colors_and_type.css` 同样的方法塞进 `XJKTokens`。

---

## 重要：HTML 不是产线代码

这份设计系统里的 `.html` / `.jsx` 是 **设计参考稿**，不是要直接编译到产品里的代码。Claude Code 的工作是：

1. **读懂**这些 JSX/CSS 表达的视觉意图
2. **翻译**成 Flutter Widget（Dart）
3. **遵守**`colors_and_type.css` 的 token、`README.md` 的语气和图标规范

特别是：
- 列表用 **ListView.builder / SliverList**，不是 map render
- 状态用 **Riverpod NotifierProvider**，不是 React useState
- 路由用 **go_router**，不是 React-style 条件渲染
- 不要把 Lucide 当 dependency，把 SVG 拷进 `assets/icons/` 用 `flutter_svg` 渲染
- 字体一定要**本地**加载，不要靠 Google Fonts CDN

---

## 拿到第一版以后

跟 Claude Code 这样迭代：

> 第二轮：金句的 **不重复轮播逻辑** —— 每一轮把所有句子洗一次（Fisher-Yates），全部出现过才进入下一轮。参考 `screens.jsx` 里 `useNoRepeatShuffle` 这个 hook。在 Flutter 里把状态用 Riverpod 暴露成 `currentQuoteProvider`，shuffle 顺序持久化到 drift 数据库的 `display_queue` 表，下次开机接着上次的位置。

> 第三轮：**批量导入** —— 用户粘贴一大段文字，自动按换行符分句，去重，去空白，让他在列表里勾选保留。参考 `ImportSheet`。

> 第四轮：**Android 桌面组件** —— 用 `home_widget` 插件 + 一段 Kotlin Glance 代码。桌面组件视觉对照 `ui_kits/android-widgets/widgets.jsx` 的 Small / Medium / Large 三种。Flutter 侧用 workmanager 每 N 分钟触发更新；N 来自 settings。

> 第五轮：**iOS 桌面组件** —— 同上但用 WidgetKit / Swift。视觉一致。

---

## 可能的坑

| 问题 | 解决 |
|---|---|
| Noto Serif SC 字体太大（~10MB） | 用 `fontTools` / `pyftsubset` 按实际用到的字符子集化，能压到 1MB 内。让 Claude Code 在第一阶段就做 |
| home_widget 不能纯 Dart 写组件 UI | 桌面组件 UI 必须 native；Flutter 侧只是把数据写到 SharedPreferences，native 侧读出来渲染。复杂度可控 |
| Android 桌面组件圆角在 Android 12 以下退化 | Glance 自动降级 |
| iOS 屏保是系统级、第三方做不到 | 这是 iOS 限制。iOS 版的「屏保」可以做成「StandBy 模式 widget」或一个 always-on 全屏 view，需要用户主动打开 |
| Flutter Web 版组件 / 屏保都退化 | 接受。Web 版定位是「展示 + 编辑」，桌面 / 移动版才有完整体验 |
| iOS 上中文宋体效果稍逊于 macOS / Android | Noto Serif SC 自托管能解决 |

---

## 一条精炼的开场提示词

直接复制下面这段，第一次对 Claude Code 说：

```
我要开发一个 Flutter 跨平台应用「小金库」，金句收藏 + 桌面组件 + 全屏屏保展示。
主目标 Android + iOS，桌面其次。

请用 .claude/skills/xiao-jinku-design 这个 skill 作为完整的设计参考——
颜色、字体、图标、5 屏 UI 的 JSX 伪代码、桌面组件的三种尺寸。

技术栈：Flutter 3.22 + Dart 3 + Riverpod + drift + go_router + flutter_svg
       + home_widget（桌面组件）+ workmanager（后台轮播）+ shared_preferences。

第一阶段，请先：
1. 用 `flutter create` 初始化项目，配好 pubspec 依赖
2. 把 colors_and_type.css 翻译成 lib/theme/tokens.dart（ThemeExtension<XJKTokens>）
   和 lib/theme/theme.dart（青纸 light / 林夜 dark）。
3. assets/ 里的 logo SVG、paper-grain、Lucide 图标全部拷进 assets/，pubspec 里注册
4. Noto Serif SC + EB Garamond 字体放进 assets/fonts/（先用 Google Fonts 下载完整 ttf，
   后续阶段再做子集化），pubspec 里注册
5. 写一个 ThemeShowcase 页面，把 token 全部可视化（色块 + 字号 + 图标），跑起来验证

完成后给我 `flutter run` 命令；之后我会让你做"金库"页面。
```

---

如果你之后让 Claude Code 写出来的视觉跑偏了，把那一屏截图发回这里，我可以帮你定位是哪个 token / 间距被翻错了。
