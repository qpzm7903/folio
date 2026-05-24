import 'dart:convert';
import 'dart:math';

import '../data/quote.dart';
import 'shuffle.dart';

/// 桌面小组件的"未来 N 条" 时间线 —— Dart 端预生成, native 按 cursor 推进。
///
/// 跟 iOS WidgetKit `TimelineProvider` 思路同构: 因为 native widget 进程
/// 不跑 Dart, 必须把"下一句是什么"提前算好交给系统。我们用
/// [NoRepeatShuffle] 同样的"先洗一轮再换"语义跨过若干 round 抽 [length]
/// 条出来, 让 app 屏保和小组件的展示序列保持一致。
///
/// 序列化为紧凑 JSON 写到 SharedPreferences (`widgetTimeline` key) 供
/// native Kotlin 解析, 单条只保留 text + tag (id / createdAt 对 widget
/// 渲染无意义, 省 prefs 空间)。
class WidgetTimeline {
  const WidgetTimeline._();

  /// 默认 timeline 长度。20 条 × 15min 下限 = 5 小时, 用户不打开 app
  /// 的窗口里小组件至少能轮换 5 小时不重复, 之后下次开 app 重新生成。
  static const int defaultLength = 20;

  /// 从 [quotes] 抽 [length] 条出来组成 timeline。
  ///
  /// - quotes 为空 → 返回空 list (native 会回落到 empty hint)
  /// - quotes 比 length 短 → 走若干轮 [NoRepeatShuffle] 拼到 length
  /// - quotes 比 length 长 → 走一轮 [NoRepeatShuffle] 取前 length 条
  ///
  /// [seed] 仅用于测试确定性, 生产路径传 null 走默认 Random。
  static List<Quote> generate(
    List<Quote> quotes, {
    int length = defaultLength,
    int? seed,
  }) {
    if (quotes.isEmpty || length <= 0) return const <Quote>[];
    final Random? random = seed != null ? Random(seed) : null;
    final NoRepeatShuffle shuffle = NoRepeatShuffle(
      itemCount: quotes.length,
      random: random,
    );
    final List<Quote> out = <Quote>[];
    for (int i = 0; i < length; i++) {
      out.add(quotes[shuffle.currentIndex]);
      shuffle.next();
    }
    return out;
  }

  /// 序列化成紧凑 JSON 字符串 (无空白) 写 SharedPreferences。
  /// 格式: `[{"q":"...","s":"..."}, ...]`, 字段名 q/s 跟 widgets.jsx
  /// mock 里 `quote.q` / `quote.src` 保持视觉对应, 便于 native 端读。
  static String serialize(List<Quote> timeline) {
    final List<Map<String, String>> raw = timeline
        .map(
          (Quote q) => <String, String>{'q': q.text, 's': q.tag},
        )
        .toList(growable: false);
    return jsonEncode(raw);
  }

  /// 反序列化 (仅测试用; native Kotlin 自己解析)。
  static List<({String text, String tag})> deserialize(String json) {
    if (json.isEmpty) return const <({String text, String tag})>[];
    final Object? decoded = jsonDecode(json);
    if (decoded is! List) return const <({String text, String tag})>[];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> m) => (
            text: (m['q'] as String?) ?? '',
            tag: (m['s'] as String?) ?? '',
          ),
        )
        .toList(growable: false);
  }
}
