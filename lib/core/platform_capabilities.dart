import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// 集中判断"当前运行时具备哪些能力", 让 service 层不必各自重复
/// `kIsWeb` + `try { Platform.isX } catch (_) { false }` 这套样板。
///
/// 用法:
/// ```dart
/// if (PlatformCapabilities.supportsHomeWidget) {
///   ...
/// }
/// ```
class PlatformCapabilities {
  const PlatformCapabilities._();

  /// 统一的平台探测守卫: Web 上 `dart:io` 的 [Platform] 不可用直接判 false,
  /// 其余平台跑 [probe] 并吞掉任何异常 (某些运行时访问 [Platform] 会抛)。
  /// 收敛掉各 getter 里重复的 `kIsWeb` + `try/catch` 样板。
  static bool _platformQuery(bool Function() probe) {
    if (kIsWeb) return false;
    try {
      return probe();
    } catch (_) {
      return false;
    }
  }

  static bool get isWeb => kIsWeb;

  static bool get isAndroid => _platformQuery(() => Platform.isAndroid);

  static bool get isIOS => _platformQuery(() => Platform.isIOS);

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => _platformQuery(
        () => Platform.isLinux || Platform.isMacOS || Platform.isWindows,
      );

  /// 鸿蒙 (OpenHarmony / HarmonyOS NEXT)。官方 dart:io 没有 isOhos getter,
  /// 鸿蒙化 Flutter fork 上 [Platform.operatingSystem] 返回 'ohos' —— 用
  /// 字符串判断让同一份代码在官方 SDK 与 fork 上都能编译 (L20)。
  static bool get isOhos =>
      _platformQuery(() => Platform.operatingSystem == 'ohos');

  /// `file_selector` 在非 Web、非鸿蒙平台可用。鸿蒙 (L20): file_selector_ohos
  /// 联邦插件受 flutter_ohos 工具链 bug 阻塞暂未集成, 故在鸿蒙关闭选图入口,
  /// 保留内置纯色背景 (见 docs/wiki/ohos/upstream-issues.md)。
  static bool get supportsFileSelector => !isWeb && !isOhos;

  /// `home_widget` plugin 只在 Android / iOS 端有真实实现 (其他平台是 stub)。
  static bool get supportsHomeWidget => isMobile;

  /// "设为系统壁纸" 只有 Android 有三方可用的 WallpaperManager API。
  /// 鸿蒙 @ohos.wallpaper 是系统 API, 三方应用不可用 (L20 spike 待最终裁决)。
  static bool get supportsSetWallpaper => isAndroid;

  /// 桌面小组件 cadence alarm 调度走 Android AlarmManager channel (L18)。
  /// iOS WidgetKit / 鸿蒙服务卡片 (L21) 各有自己的 timeline 机制, 不走这条通道。
  static bool get supportsWidgetAlarm => isAndroid;
}
