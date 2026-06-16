import 'package:flutter/services.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';
import '../domain/widget_timeline.dart';
import 'quote.dart';
import 'widget_color_theme.dart';
import 'widget_play_mode.dart';

/// 鸿蒙服务卡片 (L21) 的数据桥 —— Dart 侧。
///
/// 鸿蒙没有 `home_widget` 的等价插件 ([WidgetSyncService] 在 ohos 上是 no-op),
/// 服务卡片由 ArkTS `FormExtensionAbility` 渲染。本服务通过一条**自写的**
/// [MethodChannel] (`app.folio/ohos_widget`, handler 注册在 `EntryAbility.ets`,
/// 不是 pub 插件) 把预生成的 timeline 推给 ArkTS 侧, 由 ArkTS 用
/// `@ohos.data.preferences` 落盘供卡片读取。设计见 docs/adr/0002。
///
/// 刻意绕开受阻的联邦插件 (上游 #1): channel 是 Flutter 引擎核心能力, 存储在
/// ArkTS 侧用系统 API, 两者都不走联邦插件机制。
///
/// 非鸿蒙平台 ([_supported] = false) 全 no-op。ArkTS handler 未注册时
/// (里程碑① 静态卡片阶段) invoke 会抛 [MissingPluginException], 这里吞掉并
/// 记日志 —— 卡片回落到静态种子金句, 不崩 (决策四降级)。
class OhosWidgetService {
  const OhosWidgetService();

  static const String _channelName = 'app.folio/ohos_widget';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// 推送方法名 —— 跟 `EntryAbility.ets` 的 handler 约定一致。
  static const String _methodSyncTimeline = 'syncTimeline';

  // 跨语言契约 key: ArkTS 侧 (EntryAbility 写 preferences、QuoteFormAbility 读)
  // 用同名字段。跟 Android home_widget 的 key 保持同名 (v0.17.1 已收敛)。
  static const String _argTimeline = 'widgetTimeline';
  static const String _argCursor = 'widgetTimelineCursor';
  static const String _argColorTheme = 'widgetColorTheme';
  static const String _argPlayMode = 'widgetPlayMode';

  bool get _supported => PlatformCapabilities.isOhos;

  /// 把 [quotes] 预生成的 timeline 推给 ArkTS 卡片侧。
  ///
  /// [colorTheme] 为 null 表示"颜色没变, 别覆盖"。调用方应在 quotes /
  /// colorTheme 变化时调用 (鸿蒙卡片刷新下限 30min 由 form_config 兜底,
  /// cadence 不经这条通道)。
  Future<void> syncTimeline(
    List<Quote> quotes, {
    WidgetColorTheme? colorTheme,
    WidgetPlayMode mode = WidgetPlayMode.random,
  }) async {
    if (!_supported) return;
    try {
      // 鸿蒙卡片**整库、库原序**推送 (Issue #11 整库 + v0.19.3 修"顺序仍随机"):
      // 卡片自己按 widgetPlayMode 决定随机(随机下标)/顺序(cursor+1)。若这里预洗牌,
      // 卡片"顺序"模式 cursor+1 走的是乱序 → 看起来还是随机。故一律库原序下发,
      // 随机性全交给卡片侧。mode 仍下发作卡片初始模式。
      final List<Quote> timeline =
          WidgetTimeline.generate(quotes, shuffle: false);
      final String timelineJson = WidgetTimeline.serialize(timeline);
      final Map<String, String> args = <String, String>{
        _argTimeline: timelineJson,
        _argCursor: '0',
        _argPlayMode: mode.name,
        if (colorTheme != null) _argColorTheme: colorTheme.name,
      };
      await _channel.invokeMethod<void>(_methodSyncTimeline, args);
      AppLogger.instance.debug(
        'ohos widget timeline pushed, len=${timeline.length}, '
        'colorTheme=${colorTheme?.name ?? "(unchanged)"}',
      );
    } on MissingPluginException {
      // ArkTS handler 未注册 (里程碑① 静态阶段) —— 静默降级, 卡片用种子金句。
      AppLogger.instance.debug(
        'ohos widget channel handler absent, card stays on seed quote',
      );
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'ohos widget timeline push failed');
    }
  }
}
