import '../data/quote.dart';
import 'tag_filter.dart';

/// 小组件来源标签 (v0.29.0, 设计源 widget-editor.jsx「来自哪个标签」) ——
/// timeline 生成前用这一个纯函数决定取句范围。
///
/// [sourceTag] 为 null 或 [kAllTagsLabel] 时取整库; 否则按
/// [filterQuotesByTag] 筛选。筛选结果为空 (标签被删/改名后设置遗留) 时
/// **回退整库**: 桌面组件宁可退回全库轮播, 也不能变成一张死卡。
List<Quote> widgetSourceQuotes(List<Quote> all, String? sourceTag) {
  if (sourceTag == null || sourceTag == kAllTagsLabel) return all;
  final List<Quote> filtered = filterQuotesByTag(all, sourceTag);
  return filtered.isEmpty ? all : filtered;
}
