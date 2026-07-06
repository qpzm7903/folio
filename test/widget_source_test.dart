import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/domain/tag_filter.dart';
import 'package:folio/domain/widget_source.dart';

Quote _q(String id, String tag) => Quote(
      id: id,
      text: '句 $id',
      tag: tag,
      createdAt: DateTime(2026, 6, int.parse(id)),
    );

void main() {
  // v0.29.0 小组件来源标签 (设计源 widget-editor.jsx「来自哪个标签」):
  // timeline 生成前用这一个纯函数决定取句范围。
  group('widgetSourceQuotes (小组件来源标签)', () {
    final List<Quote> data = <Quote>[
      _q('1', '坚持'),
      _q('2', '旅程'),
      _q('3', '坚持'),
      _q('4', ''),
    ];

    test('null 来源 → 整库', () {
      expect(widgetSourceQuotes(data, null), same(data));
    });

    test('指定标签 → 只含该标签句', () {
      final List<Quote> out = widgetSourceQuotes(data, '坚持');
      expect(out.map((Quote q) => q.id), <String>['1', '3']);
    });

    test('「未分类」→ 空 tag 句', () {
      final List<Quote> out = widgetSourceQuotes(data, kUntaggedLabel);
      expect(out.map((Quote q) => q.id), <String>['4']);
    });

    test('失配标签 (被删/改名遗留) → 回退整库, 组件不变死卡', () {
      expect(widgetSourceQuotes(data, '已删除的标签'), same(data));
    });

    test('「全部」哨兵 → 整库', () {
      expect(widgetSourceQuotes(data, kAllTagsLabel), same(data));
    });
  });
}
