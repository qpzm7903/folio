import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/logger.dart';
import '../core/router.dart';
import '../data/quote.dart';
import '../data/settings_repository.dart';
import 'providers.dart';

/// 无 UI 的桥接器: 启动时 configure home widget, 之后监听 quotes 第一句变化
/// 同步给桌面小组件。
///
/// v0.15.5 Issue #6 子任务 3 起增加 widget 点击路由: 用户点击桌面小组件,
/// app 启动到 `/display` (屏保) 路径。冷启动通过
/// [HomeWidget.initiallyLaunchedFromHomeWidget], 热启动 (app 已在后台)
/// 通过 [HomeWidget.widgetClicked] stream 拿到 URI。
class WidgetSyncBridge extends ConsumerStatefulWidget {
  const WidgetSyncBridge({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WidgetSyncBridge> createState() => _WidgetSyncBridgeState();
}

class _WidgetSyncBridgeState extends ConsumerState<WidgetSyncBridge> {
  StreamSubscription<Uri?>? _clickSub;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(widgetSyncServiceProvider).configure());
    unawaited(_handleColdStartLaunchUri());
    _clickSub = HomeWidget.widgetClicked.listen(_handleLaunchUri);
  }

  @override
  void dispose() {
    _clickSub?.cancel();
    super.dispose();
  }

  /// 冷启动时 HomeWidget 把 launch URI 缓存在 plugin, 这里取出来一次性消费。
  Future<void> _handleColdStartLaunchUri() async {
    try {
      final Uri? uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        _handleLaunchUri(uri);
      }
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'widget initial launch uri');
    }
  }

  /// `folio://display` → `/display` 等 path 映射。
  /// 路由表已知值集合: 当前只接受 `display` (子任务 3 唯一行为)。
  void _handleLaunchUri(Uri? uri) {
    if (uri == null) return;
    if (uri.host == 'display') {
      // post-frame 调度避开 "navigator not yet attached" — router delegate 在
      // MaterialApp.router 绑定之前不能 go(), 用 addPostFrameCallback 等到
      // 第一帧 build 后再触发。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          ref.read(routerProvider).go(FolioRoutes.display);
          AppLogger.instance.debug('widget click → /display');
        } catch (e, st) {
          AppLogger.instance.handle(e, st, 'router.go(/display) failed');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Quote>>>(quotesProvider, (
      AsyncValue<List<Quote>>? _,
      AsyncValue<List<Quote>> next,
    ) {
      final List<Quote>? data = next.value;
      final Quote? today = (data != null && data.isNotEmpty)
          ? data.first
          : null;
      final WidgetColorTheme color = ref
          .read(settingsProvider)
          .widgetColorTheme;
      unawaited(
        ref.read(widgetSyncServiceProvider).syncToday(today, colorTheme: color),
      );
    });
    ref.listen<AppSettings>(settingsProvider, (
      AppSettings? prev,
      AppSettings next,
    ) {
      // 只在 widgetColorTheme 真变化时同步, 避免其他设置改动触发不必要的
      // widget 刷新 (跟原 quotes 同步语义独立)。
      if (prev?.widgetColorTheme == next.widgetColorTheme) return;
      final List<Quote>? data = ref.read(quotesProvider).value;
      final Quote? today = (data != null && data.isNotEmpty)
          ? data.first
          : null;
      unawaited(
        ref
            .read(widgetSyncServiceProvider)
            .syncToday(today, colorTheme: next.widgetColorTheme),
      );
    });
    return widget.child;
  }
}
