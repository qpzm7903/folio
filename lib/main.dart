import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/bootstrap.dart';
import 'core/logger.dart';
import 'presentation/widget_sync_bridge.dart';

/// 进程入口。
///
/// 用 `runZonedGuarded` 包住 Bootstrap + runApp, 配合 [FlutterError.onError]
/// 与 [PlatformDispatcher.instance.onError] 把 v0.13.0 那种"未捕获异常 →
/// 整个进程闪退"的情况 (#1) 兜底到日志 + 错误屏幕, 而不是直接 SIGKILL。
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
        runApp(_BootstrapErrorApp(error: e, stack: st));
      }
    },
    (Object error, StackTrace stack) {
      AppLogger.instance.handle(error, stack, 'runZonedGuarded');
    },
  );
}

/// 启动彻底失败时显示, 避免黑屏闪退。
class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.error, required this.stack});

  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小金库',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF3EFE6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '小金库启动失败',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text('请把下方错误截图反馈给开发者:'),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '$error\n\n$stack',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
