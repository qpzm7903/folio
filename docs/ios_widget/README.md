# iOS 桌面 / 锁屏小组件 — 启用步骤

v0.12.0 起 Dart 端通过 `home_widget` 把"今日金句"同步给 iOS WidgetKit (key: `todayQuote` / `todayTag`)。iOS native 部分用 SwiftUI + WidgetKit 在独立的 Widget Extension target 实现，跟 Android 的 RemoteViews 是一一对应的设计 (`docs/android_widget/` 是它的 Android 镜像)。

## 为什么需要手动启用

- iOS Widget Extension 必须是 Xcode 项目里的独立 target，`flutter create` 不会生成。
- 真 IPA 需要 Apple Developer 证书 + provisioning profile，CI 上没有，因此 **本仓库 CI 暂不构建 iOS**。
- 用户在自己的 macOS + Xcode + Apple Developer 账号下打开 `ios/Runner.xcworkspace` 后，按下文步骤手动添加 widget extension target。

## 包含的文件 (Swift 模板)

- `QuoteWidget.swift` — `Widget` + `IntentConfiguration` + 三种 family (`.systemSmall` / `.systemMedium` / `.systemLarge`)，分别对应 Android 的小 / 中 / 大尺寸
- `QuoteEntry.swift` — `TimelineEntry`，从 App Group `UserDefaults` 读 `todayQuote` / `todayTag`
- `QuoteProvider.swift` — `TimelineProvider`，30 分钟更新一次 (跟 Android `updatePeriodMillis` 一致)
- `QuoteWidgetBundle.swift` — Widget bundle 入口 (`@main`)
- `Info.plist.fragment` — Widget Extension Info.plist 关键键值
- `Colors.swift` — XJK token 翻译到 SwiftUI `Color`，跟 `lib/theme/tokens.dart` 同步

## Xcode 启用步骤

1. 打开 `ios/Runner.xcworkspace`
2. File → New → Target → "Widget Extension"，bundle id `app.folio.widget`
3. 把 `docs/ios_widget/Swift/` 下的所有 `.swift` 文件加到新 target，覆盖 Xcode 自动生成的
4. Signing & Capabilities：
   - 给 Runner target 和 widget target 都启用 App Groups，添加 group `group.app.folio`
   - Runner 和 widget 用同一个 Apple Developer Team
5. `Runner` target 的 `Info.plist` 加 `WKAppBundleIdentifier` (跟 Watch 无关，可省略)
6. Build & Run: widget 出现在 Today View / Home Screen 添加列表里

## 颜色 token 对照 (Colors.swift)

| Swift 名 | XJK token | hex |
|---|---|---|
| `bgRaised` | `bgRaised` (paper) | `#FBFCF3` |
| `fg1` | `fg1` (paper) | `#1D2A1F` |
| `fg3` | `fg3` (paper) | `#5E7263` |
| `mark` | `mark` (paper) | `#B8A866` |
| `leaf700` | `leaf700` | `#4A6B35` |
| `darkQuoteBg` | 大组件渐变深色 | `#2C3D27` |
| `darkQuoteText` | 大组件文字 | `#EDF2DC` |

## Caveat

- CI **不**构建 iOS / IPA (没 Apple Developer 证书)。
- Widget Extension 添加后 `flutter build ios` 会编译两个 target，需要 macOS + Xcode。
- 锁屏 widget (`.accessoryRectangular` / `.accessoryCircular`) v0.12 暂不做。
