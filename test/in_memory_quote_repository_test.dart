import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';

void main() {
  group('InMemoryQuoteRepository (兜底实现, v0.13.4 起仅供测试 / prefs 失败兜底)', () {
    Quote mk(String id, String text) =>
        Quote(id: id, text: text, tag: '', createdAt: DateTime(2026, 1, 1));

    test('loadAll 返回初始 quotes 的不可变副本', () async {
      final List<Quote> seed = <Quote>[mk('a', '春风'), mk('b', '秋月')];
      final InMemoryQuoteRepository repo = InMemoryQuoteRepository(seed);

      final List<Quote> loaded = await repo.loadAll();
      expect(loaded.map((Quote q) => q.id), <String>['a', 'b']);
      expect(() => loaded.add(mk('c', '夏雨')), throwsUnsupportedError);
    });

    test('saveAll 覆盖原内容, loadAll 反映新状态', () async {
      final InMemoryQuoteRepository repo = InMemoryQuoteRepository(<Quote>[
        mk('a', '春风'),
      ]);
      await repo.saveAll(<Quote>[mk('z', '北窗')]);
      final List<Quote> loaded = await repo.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'z');
    });

    test('外部修改初始列表不影响 repo (防御性 copy)', () async {
      final List<Quote> seed = <Quote>[mk('a', '春风')];
      final InMemoryQuoteRepository repo = InMemoryQuoteRepository(seed);
      seed.clear();
      final List<Quote> loaded = await repo.loadAll();
      expect(loaded, hasLength(1));
    });
  });
}
