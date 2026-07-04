import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/domain/tag_filter.dart';

Quote _q(String id, String tag) => Quote(
      id: id,
      text: '句 $id',
      tag: tag,
      createdAt: DateTime(2026, 5, int.parse(id)),
    );

void main() {
  // 金库普通模式与多选模式此前各内联一份 `activeTag == '全部' ? all : where`
  // 筛选; v0.22.1 收敛成 [filterQuotesByTag] 单一谓词, 这里锁住其行为等价,
  // 也是 v0.23.0 单标签→多标签迁移唯一要改的那一处。
  group('filterQuotesByTag (金库普通/多选共用筛选)', () {
    final List<Quote> data = <Quote>[
      _q('1', '坚持'),
      _q('2', '旅程'),
      _q('3', '坚持'),
      _q('4', ''), // 无标签
    ];

    test('kAllTagsLabel 不筛选, 原样返回整列', () {
      expect(filterQuotesByTag(data, kAllTagsLabel), equals(data));
    });

    test('按标签精确匹配, 命中全部同标签句', () {
      final List<Quote> hits = filterQuotesByTag(data, '坚持');
      expect(hits.map((Quote q) => q.id).toList(), <String>['1', '3']);
    });

    test('无匹配标签返回空', () {
      expect(filterQuotesByTag(data, '不存在'), isEmpty);
    });

    test('筛选结果保持原顺序', () {
      final List<Quote> hits = filterQuotesByTag(data, '坚持');
      expect(hits.first.id, '1');
      expect(hits.last.id, '3');
    });

    test('空串走筛选分支, 只命中无标签句 (不当作 kAllTagsLabel)', () {
      final List<Quote> hits = filterQuotesByTag(data, '');
      expect(hits.map((Quote q) => q.id).toList(), <String>['4']);
    });
  });

  // v0.23.0 标签管理: 删除标签后句子归「未分类」(空 tag 的展示名),
  // tag-row 的「未分类」pill 通过这里筛到它们。
  group('kUntaggedLabel (未分类虚拟标签)', () {
    final List<Quote> data = <Quote>[
      _q('1', '坚持'),
      _q('2', ''), // 无标签
      _q('3', '  '), // 全空白 tag 也算未分类
      _q('4', '旅程'),
    ];

    test('命中所有 trim 后为空的句子', () {
      final List<Quote> hits = filterQuotesByTag(data, kUntaggedLabel);
      expect(hits.map((Quote q) => q.id).toList(), <String>['2', '3']);
    });

    test('不命中具名标签句', () {
      final List<Quote> hits = filterQuotesByTag(data, kUntaggedLabel);
      expect(hits.any((Quote q) => q.tag.trim().isNotEmpty), isFalse);
    });

    test('句子标签字面就是「未分类」时也命中 (与虚拟 pill 行为一致)', () {
      final List<Quote> hits = filterQuotesByTag(
        <Quote>[_q('1', kUntaggedLabel), _q('2', '')],
        kUntaggedLabel,
      );
      expect(hits.length, 2);
    });
  });
}
