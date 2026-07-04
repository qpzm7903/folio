/// 批量导入的分句纯函数 (v0.24.0) —— 设计源 HANDOFF.md 第三轮:
/// "自动按换行符分句, 去重, 去空白, 让他在列表里勾选保留"。
///
/// 规则: 按连续换行切分 → 逐行 trim → 丢空行 → 去重 (保留首次出现的顺序)。
/// 去重让勾选列表可以直接用"行文本"当身份键, 不需要额外索引簿记。
List<String> splitImportLines(String raw) {
  final Set<String> seen = <String>{};
  final List<String> out = <String>[];
  for (final String s in raw.split(RegExp(r'\n+'))) {
    final String t = s.trim();
    if (t.isEmpty || !seen.add(t)) continue;
    out.add(t);
  }
  return List<String>.unmodifiable(out);
}
