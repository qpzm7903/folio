import 'package:home_widget/home_widget.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';
import 'quote.dart';

/// 跟桌面小组件 (home_widget plugin) 的桥接。
///
/// 目前仅 Android 端被 native widget provider 消费; iOS WidgetKit 留作 L08。
/// Web / Desktop 上是 no-op。
class WidgetSyncService {
  const WidgetSyncService();

  static const String _kAppGroup = 'app.folio';
  static const String _kAndroidProvider =
      'app.folio.widget.QuoteWidgetProvider';

  bool get _supported => PlatformCapabilities.supportsHomeWidget;

  /// 配置 widget 数据来源 —— main() 启动时调一次。
  Future<void> configure() async {
    if (!_supported) return;
    try {
      await HomeWidget.setAppGroupId(_kAppGroup);
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'HomeWidget.setAppGroupId failed');
    }
  }

  /// 把 [today] (今日金句) 写到 widget 共享数据 + 触发刷新。
  /// 调用方应该在 quotesProvider 变化时调一次。
  Future<void> syncToday(Quote? today) async {
    if (!_supported) return;
    try {
      await HomeWidget.saveWidgetData<String>('todayQuote', today?.text ?? '');
      await HomeWidget.saveWidgetData<String>('todayTag', today?.tag ?? '');
      await HomeWidget.updateWidget(
        androidName: _kAndroidProvider,
        // iOSName 留给 L08
      );
      AppLogger.instance.debug(
        'widget synced, todayQuote.len=${today?.text.length ?? 0}',
      );
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'widget sync failed');
    }
  }
}
