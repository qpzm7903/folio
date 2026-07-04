/// 织 (Interleaved) 版式的分句纯函数 (v0.25.0) ——
/// 对照设计源 display-layouts.jsx 的 `clauses()`:
/// 在中文标点「，。！？；、」处切分, 标点保留在句段末尾;
/// 无标点或空串时整句 (原样) 作为唯一一段回落。
const String _clauseMarks = '，。！？；、';

List<String> splitClauses(String text) {
  final List<String> segs = <String>[];
  final StringBuffer buf = StringBuffer();
  for (final String ch in text.split('')) {
    buf.write(ch);
    if (_clauseMarks.contains(ch)) {
      segs.add(buf.toString());
      buf.clear();
    }
  }
  if (buf.isNotEmpty) segs.add(buf.toString());
  return segs.isEmpty ? <String>[text] : segs;
}
