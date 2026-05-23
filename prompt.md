# Claude Code 指令
- 必须按照prompt.md文件中的开发流程完成新版本的开发




# 注意事项
- prompt.md文件用于下达指令给Claude Code, 禁止AI修改prompt.md文件
- .github/workflows/build.yml文件用于GitHub Actions构建, 除了0.1.0版本从脚手架代码复制例外, 禁止AI修改.github/workflows/build.yml文件
- 隐私秘钥等文件禁止上传到GitHub仓库
- 授权Claude Code自动执行命令和计划, 无需批准确认
- 必须使用main分支开发新版本
- 必须实现日志系统, 日志文件保存在`path_provider`的`getApplicationSupportDirectory()`目录下(全平台通用), 方便出问题时提供日志文件以供分析定位
- 代码量必须少于10000行(以Dart源码行数为准, 不含生成代码), 如果超过10000行需要对功能的优先级做出取舍, 移除不重要的功能
- 由于本地缺少完整的多平台构建环境(尤其是iOS/macOS需要Xcode), 构建相关操作必须放在GitHub Actions上执行
- `gh`命令必须在代码仓目录下执行
- 首个版本号必须从0.1.0开始
- 0.1.0版本的开发必须复制脚手架代码 http://192.168.31.120:3020/github/flutter-app-example/archive/main.zip 来搭建项目基础框架, 大于0.1.0版本的开发则不用再参考
- 必须基于`pubspec.yaml`文件中的`version`字段确定新版本的版本号(格式为`x.y.z+buildNumber`, 其中`buildNumber`自增)
- 必须使用仓库名称作为APP名称, 必须使用`app.仓库名称(snake_case命名法)`作为APP包名/Bundle ID/Application ID

- 所有 UI 视觉、颜色、字体、图标、布局必须严格遵循 .claude/skills/xiao-jinku-design 
  这个 skill 提供的设计规范, 实现任何新页面或组件前必须先读取该 skill 中对应的参考
  文件 (colors_and_type.css / ui_kits/android-app/screens.jsx / 
  ui_kits/android-widgets/widgets.jsx 等), 禁止凭空设计 UI

  
# 开发流程

每次任务的执行遵循新版本迭代开发全流程。

## **规划与准备 (Planning)**

在写代码之前，先明确新版本的目标。

- **创建或更新项目规划**：根据prompt.md文件中的要求, 在plan.md文件中创建或者更新项目短期、中期、长期功能规划, 确保可以长期迭代演进。
- **确定新版本需求范围原则**：按照以下约束条件优先级顺序规划新版本需求范围：
    - 如果有未关闭的GitHub Issues `gh issue list --state open --limit 3 --search "sort:created-desc"`, 则必须立即规划一个**PATCH**新版本修复问题
    - 如果GitHub Actions最新workflow有报错 `gh run list --limit 3`, 则必须立即规划一个**PATCH**新版本修复报错
    - 如果当前**MINOR**版本在plan.md文件中还没有一个已完成的用于重构优化的**PATCH**版本, 则必须立即规划一个**PATCH**新版本重构优化存量代码
    - 不在以上场景, 则规划一个**MINOR**新版本开发plan.md文件中还未实现的功能
    - 示例: 0.2.0(新功能)->0.2.1(修复issue)->0.2.2(修复workflow)->0.2.3(重构优化)->0.3.0(新功能)->0.3.1(重构优化)->0.4.0(新功能)
- **归档新版本目标**：在plan.md文件中更新新版本的目标和任务。

## **开发与测试 (Development & Testing)**

根据plan.md文件中规划的新版本需求清单, 完成开发与测试。

- **更新版本号**：将涉及到版本号的地方(`pubspec.yaml`的`version`、Android `build.gradle`的`versionName/versionCode`、iOS `Info.plist`的`CFBundleShortVersionString/CFBundleVersion`等)更新为新版本的版本号。
- **需求开发**：完成plan.md文件中规划的新版本需求清单。
- **测试用例开发**：编写单元测试(`test/`)和Widget测试, 必要时编写集成测试(`integration_test/`), 确保所有测试通过 (`flutter test`)。
- **代码静态检查**：必须通过 `flutter analyze` 零警告, 并使用 `dart format .` 格式化代码。
- **代码审查 (Code Review)**：Review 代码, 对架构、稳定性、易用性、可用性、可靠性、用户体验、性能、安全方面进行改进, 移除不需要的功能, 保持Clean Code。
- **提交代码**：建议每个小功能单独提交，保持 Commit 信息清晰, 提交时不要遗漏必要的文件, 也不要多提交不需要的文件, 设置合理的.gitignore (至少包含 `build/`、`.dart_tool/`、`.idea/`、`*.iml`、`.flutter-plugins`、`.flutter-plugins-dependencies`、`ios/Pods/`、`ios/.symlinks/`、`macos/Pods/`、`**/*.g.dart`是否提交按团队约定)。
- **通过CI流水线**：确保GitHub Actions workflow无报错, 各目标平台构建产物正常生成。

## **版本发布**

- 使用新版本的版本号创建 Git Tag 并推送到 GitHub 即可自动触发 GitHub Actions 流水线发布新版本(产物包括 Android APK/AAB、iOS IPA、Web bundle、Windows/macOS/Linux 桌面包)

## **文档完善**

- 在plan.md文件中更新需求开发进展和状态
- 仓库的最新详细介绍更新到README.md文件
- 最多保留最新5个版本的介绍, 旧版本的介绍合并压缩成1个版本介绍

## **问题闭环**

- 关闭已解决的issue, 在issue里使用MarkDown格式回复问题是在哪个新版本解决的并提供新版本下载地址, 提醒用户进行验证.


# 设计规范

## 技术栈
- 使用最新稳定版 Flutter SDK (stable channel)
- 使用最新稳定版 Dart 语言, 启用 sound null safety
- 必须支持的目标平台: Android / iOS / Web / Windows / macOS / Linux
- Android: 最小 SDK 21 (Android 5.0), 目标 SDK 跟随 Flutter 默认最新版
- iOS: 最低支持版本跟随 Flutter 默认 (当前为 iOS 12.0)
- 使用 `flutter_riverpod` + `riverpod_annotation` 作为状态管理方案
- 使用 `go_router` 处理路由导航(支持 Web URL 与深链)
- 使用 `freezed` + `json_serializable` 处理不可变数据类与序列化
- 使用 `drift` 存储结构化数据(跨平台 SQLite, 优于直接用 sqflite)
- 使用 `shared_preferences` 存储简单键值对数据
- 使用 `path_provider` 获取跨平台文件路径
- 使用 `cached_network_image` 处理网络图片加载与缓存(若有联网需求)
- 使用 `logger` 或 `talker` 实现日志系统, 日志文件落盘到 `getApplicationSupportDirectory()`
- 使用 `dio` 处理网络请求(若有联网需求), 否则不引入
- 使用 `intl` 处理国际化与本地化
- 使用 `flutter_localizations` 支持简体中文等多语言

## 架构
- 采用 Clean Architecture + MVVM 分层:
    - `lib/presentation/` UI 层(Widget + Riverpod Notifier/ViewModel)
    - `lib/domain/` 领域层(Entity + UseCase + Repository 接口)
    - `lib/data/` 数据层(Repository 实现 + DataSource + Model)
    - `lib/core/` 通用基础设施(日志、路由、主题、工具类)
- 异步处理统一使用 `Future` / `Stream` / `async-await`
- 依赖注入通过 Riverpod 的 `Provider` 体系完成, 不引入额外 DI 框架

## UI 与体验
- 使用 Material 3 设计语言, 自定义紧凑型 `ThemeData` 让布局更紧凑
- 支持浅色/深色主题, 跟随系统切换
- 使用 `LayoutBuilder` / `MediaQuery` / `NavigationRail` 等实现响应式布局, 适配手机、折叠屏、平板、桌面、Web 多窗口尺寸
- 开启高刷新率支持, 在 Android 上调用 `FlutterDisplayMode` 或使用 Flutter 默认能力, 桌面端确保不限制帧率
- 界面精美, 操作与目标平台主流应用习惯一致(Android 走 Material, iOS/macOS 适度借鉴 Cupertino)
- 默认界面文本支持简体中文, 通过 `intl` 与 ARB 文件管理文案
- 标题栏(`AppBar`)按钮不要超过 3 个
- 搜索栏或搜索按钮合并到标题栏(可用 `SearchAnchor` / `SearchBar`)
- 联网能力按版本规划引入: 默认本地单机优先, 需要联网的功能必须在 plan.md 中明确标注并做好离线降级


# Git 提交规范

## 行为准则
在生成 Git 提交信息时：
- **严格禁止**：切勿包含任何表明该信息由 AI 生成的文字（例如"Written by Claude"、"AI-generated"等）。
- **无尾部签名**：除非明确指示为特定用户添加，否则不要附加"Signed-off-by"或"Co-authored-by"行。
- **直接输出**：直接给出提交信息，不要包含任何引言性文字（例如跳过"好的，这是提交信息……"这类内容）。
- **禁止额外作者**：使用git默认用户为作者, 绝对禁止添加"claude"为额外作者。
- **使用简体中文**：git提交信息必须以简体中文为主。

## 格式标准
- 采用 Conventional Commits 格式：`<类型>(<范围>): <主题>`
- 允许的类型包括：feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert。
- 首行长度必须控制在 72 个字符以内。


# 版本号规范

**版本号规范**：版本号为 `MAJOR.MINOR.PATCH`, 遵循SemVer语义化版本规范, 在 `pubspec.yaml` 中以 `version: MAJOR.MINOR.PATCH+BUILD` 形式表达, 其中 `BUILD` 自增整数:
- **MAJOR** (重大不兼容更新)
- **MINOR** (新功能，向下兼容)
- **PATCH** (Bug 修复, 代码重构，向下兼容)