import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/bootstrap.dart';
import 'core/logger.dart';
import 'presentation/bootstrap_error_screen.dart';
import 'presentation/widget_sync_bridge.dart';

/// 进程入口。
///
/// 用 `runZonedGuarded` 包住 Bootstrap + runApp, 配合 [FlutterError.onError]
/// 与 [PlatformDispatcher.instance.onError] 把 v0.13.0 那种"未捕获异常 →
/// 整个进程闪退"的情况 (#1) 兜底到日志 + 错误屏幕, 而不是直接 SIGKILL。
///
/// 注意: 这层只能兜 Dart 层异常。native 崩溃 (如 v0.13.0~3 sqlite3 SIGSEGV,
/// 见 #5) 在进程被内核 kill 前 Dart 没机会运行, 必须从更外层 (依赖管理)
/// 修, 例如 v0.13.4 移除 drift 路径。
Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.instance.handle(
          details.exception,
          details.stack,
          'FlutterError.onError',
        );
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        AppLogger.instance.handle(error, stack, 'PlatformDispatcher.onError');
        return true;
      };

      try {
        final List<Override> overrides = await Bootstrap.initialize();
        runApp(
          ProviderScope(
            overrides: overrides,
            child: const WidgetSyncBridge(child: FolioApp()),
          ),
        );
      } catch (e, st) {
        AppLogger.instance.handle(e, st, 'Bootstrap fatal');
        runApp(BootstrapErrorScreen(error: e, stack: st));
      }
    },
    (Object error, StackTrace stack) {
      AppLogger.instance.handle(error, stack, 'runZonedGuarded');
    },
  );
}
