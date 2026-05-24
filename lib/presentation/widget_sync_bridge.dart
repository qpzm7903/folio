import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/logger.dart';
import '../core/router.dart';
import '../data/quote.dart';
import '../data/settings_repository.dart';
import 'providers.dart';

/// 无 UI 的桥接器: 启动时 configure home widget, 之后监听 quotes / cadence /
/// colorTheme 变化, 把 timeline 同步给桌面小组件 + 调度 AlarmManager。
///
/// v0.15.5 Issue #6 子任务 3 起增加 widget 点击路由: 用户点击桌面小组件,
/// app 启动到 `/display` (屏保) 路径。冷启动通过
/// [HomeWidget.initiallyLaunchedFromHomeWidget], 热启动 (app 已在后台)
/// 通过 [HomeWidget.widgetClicked] stream 拿到 URI。
///
/// v0.16.0: syncToday → syncTimeline, 同时把 settings.cadenceMinutes 也
/// 纳入监听, 让小组件按用户配的频率 (下限 15min) 自动换句。
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

  /// 把"当前 quotes 列表 + 当前 settings"打包给 widget service 同步。
  /// 三处 listener (quotes / colorTheme / cadence) 都收敛到这里, 避免发散。
  void _sync({required bool includeColor}) {
    final List<Quote>? quotes = ref.read(quotesProvider).value;
    if (quotes == null) return;
    final AppSettings settings = ref.read(settingsProvider);
    unawaited(
      ref.read(widgetSyncServiceProvider).syncTimeline(
        quotes,
        cadenceMinutes: settings.cadenceMinutes,
        colorTheme: includeColor ? settings.widgetColorTheme : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Quote>>>(quotesProvider, (
      AsyncValue<List<Quote>>? _,
      AsyncValue<List<Quote>> next,
    ) {
      if (next.value == null) return;
      // quotes 变化时一并刷颜色 (首次同步可能颜色还没被 listener 触发过)
      _sync(includeColor: true);
    });
    ref.listen<AppSettings>(settingsProvider, (
      AppSettings? prev,
      AppSettings next,
    ) {
      final bool colorChanged =
          prev?.widgetColorTheme != next.widgetColorTheme;
      final bool cadenceChanged = prev?.cadenceMinutes != next.cadenceMinutes;
      if (!colorChanged && !cadenceChanged) return;
      _sync(includeColor: colorChanged);
    });
    return widget.child;
  }
}
