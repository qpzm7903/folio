/// 展示用的金句文本清洗。
///
/// 用户从别处批量导入的金句常带"序号前缀"(如 `200. ` / `9、` / `12．`),
/// 在卡片/屏保上显示出来很像列表项, 不够"金句感" (用户真机反馈)。
/// 这里在**展示**时剥掉开头的序号前缀, 原始数据不动。
library;

/// 开头序号前缀: 1~4 位数字 + 一个分隔符 (. 、 。 ． ) ） : ：) + 可选空白。
/// 要求必须有分隔符, 避免误伤以数字开头的正文 (如 "1984 年那个夏天")。
final RegExp _leadingIndex = RegExp(
  r'^\s*\d{1,4}\s*[.．、。\)）:：]\s*',
);

/// 返回用于展示的金句文本: 剥掉开头序号前缀。
/// 若剥完为空 (整句就是个编号) 则保留原文, 不显示空白。
String displayQuoteText(String raw) {
  final String stripped = raw.replaceFirst(_leadingIndex, '');
  return stripped.isEmpty ? raw : stripped;
}
