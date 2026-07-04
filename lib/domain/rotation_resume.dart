/// 屏保轮播续位 (v0.26.0, HANDOFF 第二轮收尾) —— 持久化侧存的是
/// quote-id 的洗牌顺序 (索引会随增删漂移, id 不会), 恢复时翻译回
/// 当前列表的索引顺序。
///
/// 返回 null 表示"续不上" (金库内容变了 / 数据损坏), 调用方应重新洗牌。
List<int>? mapOrderToIndices(List<String> savedIds, List<String> currentIds) {
  if (savedIds.length != currentIds.length) return null;
  final Map<String, int> indexOf = <String, int>{
    for (int i = 0; i < currentIds.length; i++) currentIds[i]: i,
  };
  final List<int> out = <int>[];
  final Set<String> seen = <String>{};
  for (final String id in savedIds) {
    final int? idx = indexOf[id];
    if (idx == null || !seen.add(id)) return null;
    out.add(idx);
  }
  return out;
}
