import 'dart:convert';
import 'dart:math';

import '../data/quote.dart';
import 'quote_display.dart';
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

  /// timeline 上限 —— 默认覆盖**整个金库** (Issue #11: 不再只取固定的几条),
  /// 仅在金库极大时截断, 防 prefs JSON / native RemoteViews 过大。
  static const int maxLength = 1000;

  /// 从 [quotes] 生成 timeline。
  ///
  /// 默认 ([length] 省略) 覆盖整个金库 (上限 [maxLength]), 让小组件能轮到
  /// 库里每一句, 而不是固定的前若干条 (Issue #11)。
  ///
  /// - [shuffle] = true (随机模式): 走一轮 [NoRepeatShuffle], 整库乱序不重复;
  /// - [shuffle] = false (顺序模式): 按金库原序 (新→旧) 取。
  /// - quotes 为空 → 返回空 list (native 回落到 empty hint)。
  /// - [seed] 仅用于测试确定性, 生产路径传 null 走默认 Random。
  static List<Quote> generate(
    List<Quote> quotes, {
    int? length,
    int? seed,
    bool shuffle = true,
  }) {
    if (quotes.isEmpty) return const <Quote>[];
    final int n = length ?? min(quotes.length, maxLength);
    if (n <= 0) return const <Quote>[];
    if (!shuffle) {
      // 顺序模式: 按库序取前 n (n 默认 = 整库长度时即整库)。
      return quotes.take(n).toList(growable: false);
    }
    final Random? random = seed != null ? Random(seed) : null;
    final NoRepeatShuffle noRepeat = NoRepeatShuffle(
      itemCount: quotes.length,
      random: random,
    );
    final List<Quote> out = <Quote>[];
    for (int i = 0; i < n; i++) {
      out.add(quotes[noRepeat.currentIndex]);
      noRepeat.next();
    }
    return out;
  }

  /// 序列化成紧凑 JSON 字符串 (无空白) 写 SharedPreferences。
  /// 格式: `[{"q":"...","s":"..."}, ...]`, 字段名 q/s 跟 widgets.jsx
  /// mock 里 `quote.q` / `quote.src` 保持视觉对应, 便于 native 端读。
  static String serialize(List<Quote> timeline) {
    final List<Map<String, String>> raw = timeline
        .map(
          (Quote q) =>
              <String, String>{'q': displayQuoteText(q.text), 's': q.tag},
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
