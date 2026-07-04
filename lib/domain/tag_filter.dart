import '../data/quote.dart';

/// 金库标签筛选里"全部"这个虚拟标签的标签名 —— 唯一可信源。
///
/// 它从不真正存到任何 quote 上, 只作为"不筛选"的哨兵值: 标签列表把它放在首位,
/// 默认选中它, [filterQuotesByTag] 见到它就返回整列不筛。
const String kAllTagsLabel = '全部';

/// 「未分类」虚拟标签 (v0.23.0 标签管理) —— 空 tag 句子的展示名。
///
/// 跟 [kAllTagsLabel] 一样从不写进 quote: 删除标签只是把句子的 tag 清空,
/// tag-row 在存在空 tag 句时行末追加这枚 pill, 兑现确认弹窗
/// "标签下的金句会移到「未分类」" 的说法。句子标签字面写成「未分类」时
/// 也归入这枚 pill (与设计源 app.jsx onDeleteTag 的语义一致)。
const String kUntaggedLabel = '未分类';

/// 按标签筛选金句 —— 金库普通模式与多选模式共用的同一份谓词 (纯函数, 无 UI 依赖)。
///
/// [tag] 为 [kAllTagsLabel] 时不筛选, 原样返回 [quotes];
/// 为 [kUntaggedLabel] 时命中所有 trim 后为空 (或字面「未分类」) 的句子。
/// **这是金库标签筛选的唯一改动点**, 调用屏自动跟上。
List<Quote> filterQuotesByTag(List<Quote> quotes, String tag) {
  if (tag == kAllTagsLabel) return quotes;
  if (tag == kUntaggedLabel) {
    return quotes.where(_isUntagged).toList(growable: false);
  }
  return quotes.where((Quote q) => q.tag == tag).toList(growable: false);
}

bool _isUntagged(Quote q) {
  final String t = q.tag.trim();
  return t.isEmpty || t == kUntaggedLabel;
}
