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

  static bool get isWeb => kIsWeb;

  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  /// 鸿蒙 (OpenHarmony / HarmonyOS NEXT)。官方 dart:io 没有 isOhos getter,
  /// 鸿蒙化 Flutter fork 上 [Platform.operatingSystem] 返回 'ohos' —— 用
  /// 字符串判断让同一份代码在官方 SDK 与 fork 上都能编译 (L20)。
  static bool get isOhos {
    if (kIsWeb) return false;
    try {
      return Platform.operatingSystem == 'ohos';
    } catch (_) {
      return false;
    }
  }

  /// `file_selector` 在所有非 Web 平台都能用; Web 上 path 是 blob, 无持久存储, no-op。
  static bool get supportsFileSelector => !isWeb;

  /// `home_widget` plugin 只在 Android / iOS 端有真实实现 (其他平台是 stub)。
  static bool get supportsHomeWidget => isMobile;

  /// "设为系统壁纸" 只有 Android 有三方可用的 WallpaperManager API。
  /// 鸿蒙 @ohos.wallpaper 是系统 API, 三方应用不可用 (L20 spike 待最终裁决)。
  static bool get supportsSetWallpaper => isAndroid;

  /// 桌面小组件 cadence alarm 调度走 Android AlarmManager channel (L18)。
  /// iOS WidgetKit / 鸿蒙服务卡片 (L21) 各有自己的 timeline 机制, 不走这条通道。
  static bool get supportsWidgetAlarm => isAndroid;
}
