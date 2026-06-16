import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';
import '../domain/widget_timeline.dart';
import 'quote.dart';
import 'widget_color_theme.dart';
import 'widget_play_mode.dart';

/// 跟桌面小组件 (home_widget plugin + AlarmManager) 的桥接。
///
/// v0.16.0 之前: 只把 quotes.first 写成 `todayQuote` 静态贴在 widget 上。
/// v0.16.0 起: 把"未来 N 条" timeline 预生成写 prefs, native 端
/// AlarmManager 按用户配的 cadence (下限 15min) 推进 cursor 自动换句。
///
/// Android: 走 `app.folio/widget_alarm` MethodChannel 调度
/// AlarmManager.setInexactRepeating。iOS WidgetKit 自动刷新留 L08 后续。
/// Web / Desktop 上 [_supported] = false, 全 no-op。
class WidgetSyncService {
  const WidgetSyncService();

  static const String _kAppGroup = 'app.folio';
  static const String _kAndroidProvider =
      'app.folio.widget.QuoteWidgetProvider';
  static const String _kIosWidgetKind = 'QuoteWidget';

  static const String _alarmChannelName = 'app.folio/widget_alarm';
  static const MethodChannel _alarmChannel = MethodChannel(_alarmChannelName);

  // home_widget 共享存储的 key —— 跟 native 端是一份跨语言契约 (Dart 写、
  // Kotlin `QuoteWidgetProvider`/`QuoteWidgetAlarmReceiver` 读相同字面量;
  // L21 鸿蒙 ArkTS 服务卡片也将读同一组 key)。改名时必须同步 native, 故在此
  // 收敛成命名常量, 杜绝两侧各写一遍魔法字符串导致拼写漂移。
  static const String _kKeyTimeline = 'widgetTimeline';
  static const String _kKeyCursor = 'widgetTimelineCursor';
  static const String _kKeyCadence = 'widgetCadenceMinutes';
  static const String _kKeyTodayQuote = 'todayQuote';
  static const String _kKeyTodayTag = 'todayTag';
  static const String _kKeyColorTheme = 'widgetColorTheme';

  /// 小组件刷新下限 (分钟)。AlarmManager doze 模式下实际能保证的最小间隔
  /// 约在 10-15 分钟, 而且 widget 1 分钟切一次会被用户当电池杀手卸载。
  /// 详细取舍见 plan.md / v0.16.0 设计取舍 #1。
  static const int kWidgetCadenceFloorMin = 15;

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

  /// 把 [quotes] 预生成的 timeline 写到 widget 共享存储, 并按
  /// [cadenceMinutes] 让 native 调度 alarm 推进 cursor。
  ///
  /// [colorTheme] 为 null 表示"颜色没变, 别覆盖", 仍走 alarm reschedule。
  /// 调用方应该在 quotes / cadence / colorTheme 任一变化时调一次。
  Future<void> syncTimeline(
    List<Quote> quotes, {
    int cadenceMinutes = kWidgetCadenceFloorMin,
    WidgetColorTheme? colorTheme,
    WidgetPlayMode mode = WidgetPlayMode.random,
  }) async {
    if (!_supported) return;
    final int effectiveCadence =
        math.max(cadenceMinutes, kWidgetCadenceFloorMin);
    try {
      // 整库生成 (Issue #11): 不再固定取前 20 条; mode 决定随机/顺序。
      final List<Quote> timeline =
          WidgetTimeline.generate(quotes, shuffle: mode.shuffle);
      final String timelineJson = WidgetTimeline.serialize(timeline);
      await HomeWidget.saveWidgetData<String>(_kKeyTimeline, timelineJson);
      // cursor / cadence 用 String 存避免 home_widget plugin 跨平台 int 类型
      // 不一致 (iOS UserDefaults vs Android SharedPreferences putInt/putLong),
      // native Kotlin 直接 toIntOrNull 解析就行。
      await HomeWidget.saveWidgetData<String>(_kKeyCursor, '0');
      await HomeWidget.saveWidgetData<String>(
        _kKeyCadence,
        effectiveCadence.toString(),
      );
      // 兼容字段: 老版本 widget layout 若 fallback 读 todayQuote/todayTag
      // 仍能拿到第一句。新的 QuoteWidgetProvider 优先走 timeline[cursor]。
      final Quote? first = timeline.isNotEmpty ? timeline.first : null;
      await HomeWidget.saveWidgetData<String>(
          _kKeyTodayQuote, first?.text ?? '');
      await HomeWidget.saveWidgetData<String>(_kKeyTodayTag, first?.tag ?? '');
      if (colorTheme != null) {
        await HomeWidget.saveWidgetData<String>(
          _kKeyColorTheme,
          colorTheme.name,
        );
      }
      await HomeWidget.updateWidget(
        androidName: _kAndroidProvider,
        iOSName: _kIosWidgetKind,
      );
      await _scheduleAlarm(effectiveCadence);
      AppLogger.instance.debug(
        'widget timeline synced, len=${timeline.length}, '
        'cadence=${effectiveCadence}min, '
        'colorTheme=${colorTheme?.name ?? "(unchanged)"}',
      );
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'widget timeline sync failed');
    }
  }

  /// 取消 alarm — quotes 变空时调用, 避免 native 一直在没数据时跑 onUpdate。
  Future<void> cancelAlarm() async {
    if (!_supported) return;
    if (!PlatformCapabilities.supportsWidgetAlarm) return;
    try {
      await _alarmChannel.invokeMethod<void>('cancel');
    } on PlatformException catch (e, st) {
      AppLogger.instance.handle(e, st, 'widget alarm cancel failed');
    }
  }

  Future<void> _scheduleAlarm(int cadenceMin) async {
    if (!PlatformCapabilities.supportsWidgetAlarm) return;
    try {
      await _alarmChannel.invokeMethod<void>(
        'schedule',
        <String, Object>{'cadenceMinutes': cadenceMin},
      );
    } on PlatformException catch (e, st) {
      AppLogger.instance.handle(e, st, 'widget alarm schedule failed');
    }
  }
}
