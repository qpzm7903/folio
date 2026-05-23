import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quote.dart';
import 'providers.dart';

/// 无 UI 的桥接器: 启动时 configure home widget, 之后监听 quotes 第一句变化
/// 同步给桌面小组件。
///
/// 用法: 把它放在 ProviderScope 内部, child 是 FolioApp。
/// FolioApp 本身保持纯 ConsumerWidget, 不混 widget sync 的状态。
class WidgetSyncBridge extends ConsumerStatefulWidget {
  const WidgetSyncBridge({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WidgetSyncBridge> createState() => _WidgetSyncBridgeState();
}

class _WidgetSyncBridgeState extends ConsumerState<WidgetSyncBridge> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(widgetSyncServiceProvider).configure());
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
      unawaited(ref.read(widgetSyncServiceProvider).syncToday(today));
    });
    return widget.child;
  }
}
