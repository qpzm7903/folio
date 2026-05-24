import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/drift/quotes_database.dart';
import 'package:folio/data/quote.dart';

void main() {
  late QuotesDatabase db;

  setUp(() {
    db = QuotesDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Quote q(String id, String text, {String tag = '', int day = 1}) =>
      Quote(id: id, text: text, tag: tag, createdAt: DateTime(2026, 5, day));

  group('QuotesDatabase', () {
    test('空库 loadAll 返回空', () async {
      expect(await db.loadAll(), isEmpty);
    });

    test('saveAll → loadAll 双向无损, 按 createdAt desc 排', () async {
      await db.saveAll(<Quote>[
        q('a', '早', day: 1),
        q('b', '晚', day: 5, tag: '完整'),
        q('c', '中', day: 3),
      ]);
      final List<Quote> got = await db.loadAll();
      expect(got.map((Quote x) => x.id), <String>['b', 'c', 'a']);
      expect(got.firstWhere((Quote x) => x.id == 'b').tag, '完整');
    });

    test('再次 saveAll 用新集合覆盖旧的 (整组替换)', () async {
      await db.saveAll(<Quote>[q('a', '甲'), q('b', '乙')]);
      await db.saveAll(<Quote>[q('c', '丙')]);
      final List<Quote> got = await db.loadAll();
      expect(got.length, 1);
      expect(got.single.id, 'c');
    });

    test('空 tag 字段默认 ""', () async {
      await db.saveAll(<Quote>[q('a', '无标签句子')]);
      final Quote got = (await db.loadAll()).single;
      expect(got.tag, '');
    });
  });
}
