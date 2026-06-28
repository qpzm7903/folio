import '../data/quote.dart';

/// 金库标签筛选里"全部"这个虚拟标签的标签名 —— 唯一可信源。
///
/// 它从不真正存到任何 quote 上, 只作为"不筛选"的哨兵值: 标签列表把它放在首位,
/// 默认选中它, [filterQuotesByTag] 见到它就返回整列不筛。
const String kAllTagsLabel = '全部';

/// 按标签筛选金句 —— 金库普通模式与多选模式共用的同一份谓词 (纯函数, 无 UI 依赖)。
///
/// [tag] 为 [kAllTagsLabel] 时不筛选, 原样返回 [quotes]。
/// **这是金库标签筛选的唯一改动点**: v0.23.0 单标签→多标签迁移时,
/// 把 `q.tag == tag` 换成 `q.tags.contains(tag)` 即可, 所有调用方自动跟上。
List<Quote> filterQuotesByTag(List<Quote> quotes, String tag) {
  if (tag == kAllTagsLabel) return quotes;
  return quotes.where((Quote q) => q.tag == tag).toList(growable: false);
}
