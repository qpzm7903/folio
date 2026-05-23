# Android 桌面小组件 — 启用步骤

v0.11.0 起，Dart 端通过 [`home_widget`](https://pub.dev/packages/home_widget) 把"今日金句"同步到 home widget 的共享数据 (`todayQuote` / `todayTag`)。Android native widget 的 RemoteViews / AppWidgetProvider 由本目录的模板文件提供。

`flutter create` 生成的 `android/` 目录是 boilerplate，本仓库不 commit；CI 在每次构建时跑 `flutter create --platforms=android,web .` 重建。要让 widget 真正显示在桌面，需要把本目录下的几个文件复制到 `android/` 后再 build —— CI 的 `flutter-setup` composite action 之后会自动做这一步。

## 包含的文件

- `app/src/main/res/layout/quote_widget_small.xml` — 1×1 小尺寸 RemoteViews 布局
- `app/src/main/res/layout/quote_widget_medium.xml` — 2×1 中尺寸
- `app/src/main/res/layout/quote_widget_large.xml` — 2×2 大尺寸
- `app/src/main/res/xml/quote_widget_info.xml` — AppWidget 配置 (尺寸 / 更新周期)
- `app/src/main/res/values/colors_folio.xml` — XJK token 中 widget 用到的颜色
- `app/src/main/kotlin/app/folio/widget/QuoteWidgetProvider.kt` — AppWidgetProvider 实现 (读 HomeWidget 共享数据并刷 RemoteViews)
- `app/src/main/AndroidManifest_widget_fragment.xml` — 需要追加到 `android/app/src/main/AndroidManifest.xml` `<application>` 节点的片段

## 手动启用 (本地开发)

```bash
flutter create --org app --project-name folio --platforms=android,web .
cp -r docs/android_widget/app/src/main/res/* android/app/src/main/res/
cp -r docs/android_widget/app/src/main/kotlin/* android/app/src/main/kotlin/
# 手动把 AndroidManifest_widget_fragment.xml 内容贴到 android/app/src/main/AndroidManifest.xml 的 <application> 内
```

> 当前 CI 只验证 `flutter build apk` 通过；widget 真机渲染需要用户在 Android 桌面长按 → "小组件" → "小金库" 添加。

## 颜色 token 对照

| Android 资源 | XJK token | hex |
|---|---|---|
| `xjk_bg_raised` | `bgRaised` (paper) | `#FBFCF3` |
| `xjk_fg_1` | `fg1` (paper) | `#1D2A1F` |
| `xjk_fg_3` | `fg3` (paper) | `#5E7263` |
| `xjk_mark` | `mark` (paper) | `#B8A866` |
| `xjk_leaf_700` | `leaf700` | `#4A6B35` |
| `xjk_dark_quote_bg` | 大组件渐变深色 | `#2C3D27` |

夜间主题 (night) 资源等下个 PATCH 补 `values-night/`。
