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

  /// `file_selector` 在所有非 Web 平台都能用; Web 上 path 是 blob, 无持久存储, no-op。
  static bool get supportsFileSelector => !isWeb;

  /// `home_widget` plugin 只在 Android / iOS 端有真实实现 (其他平台是 stub)。
  static bool get supportsHomeWidget => isMobile;
}
