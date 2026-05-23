import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/providers.dart';

import 'test_harness.dart';

void main() {
  group('QuotesNotifier._ready race protection', () {
    test('loading 期间调 add, 加载完后两条都在 (不丢)', () async {
      final List<Quote> seed = <Quote>[testQuote(id: 'seed-1', text: 'seed 1')];
      // 给 loadAll 加 80ms 延时, 模拟金库加载未完成
      final FakeQuoteRepository repo = FakeQuoteRepository(
        seed,
        const Duration(milliseconds: 80),
      );
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[quoteRepositoryProvider.overrideWithValue(repo)],
      );

      // 不等 _load, 立刻发起 add —— 在 v0.9.0 这条会被静默丢; v0.9.1
      // 应该排队等 _ready 后执行。
      final Future<void> addFut = c
          .read(quotesProvider.notifier)
          .add('new sentence', 'tag');

      await addFut; // _ready 内置 await loadAll 80ms, 完成后才执行 transform

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.length, 2);
      expect(
        got.map((Quote q) => q.text),
        containsAll(<String>['seed 1', 'new sentence']),
      );
      c.dispose();
    });

    test('loading 期间 update id 也能命中加载完后的真实数据', () async {
      final Quote original = testQuote(id: 'real', text: '旧');
      final FakeQuoteRepository repo = FakeQuoteRepository(<Quote>[
        original,
      ], const Duration(milliseconds: 80));
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[quoteRepositoryProvider.overrideWithValue(repo)],
      );

      // _load 还没完成, 立刻 update —— v0.9.0 会 'not found, ignoring'
      await c.read(quotesProvider.notifier).update('real', '新', '新标签');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.length, 1);
      expect(got.single.id, 'real');
      expect(got.single.text, '新');
      expect(got.single.tag, '新标签');
      c.dispose();
    });
  });
}
