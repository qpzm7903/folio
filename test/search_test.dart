import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/library/search_screen.dart';

void main() {
  final DateTime now = DateTime(2026, 5, 23);
  final List<Quote> data = <Quote>[
    Quote(id: '1', text: '你在心里种下的种子，时间会帮它找出口。', tag: '坚持与回响', createdAt: now),
    Quote(id: '2', text: '光从裂痕里照进来。', tag: '完整而非完美', createdAt: now),
    Quote(
      id: '3',
      text: 'You only see what you can name.',
      tag: 'reading',
      createdAt: now,
    ),
  ];

  group('filterQuotes', () {
    test('空 query 返回空 (不是全集)', () {
      expect(filterQuotes(data, ''), isEmpty);
      expect(filterQuotes(data, '   '), isEmpty);
    });

    test('按 text 子串匹配', () {
      final List<Quote> hits = filterQuotes(data, '种子');
      expect(hits.map((Quote q) => q.id), <String>['1']);
    });

    test('按 tag 匹配', () {
      final List<Quote> hits = filterQuotes(data, '坚持');
      expect(hits.map((Quote q) => q.id), <String>['1']);
    });

    test('大小写不敏感', () {
      final List<Quote> hits = filterQuotes(data, 'YOU');
      expect(hits.map((Quote q) => q.id), <String>['3']);
    });

    test('查不到时返回空', () {
      expect(filterQuotes(data, 'xyz不存在'), isEmpty);
    });

    test('多条命中', () {
      final List<Quote> hits = filterQuotes(data, '。');
      expect(hits.length, 2); // 第 1, 第 2 句都以中文句号结尾
    });
  });
}
