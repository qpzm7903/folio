import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/presentation/providers.dart';

/// 记录 saveAll 调用次数的 fake, 用来验证批量删除只落盘一次。
class _CountingRepo implements QuoteRepository {
  _CountingRepo(this._data);
  List<Quote> _data;
  int saveCount = 0;

  @override
  Future<List<Quote>> loadAll() async => List<Quote>.of(_data);

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    saveCount++;
    _data = List<Quote>.of(quotes);
  }
}

Quote _q(String id) =>
    Quote(id: id, text: '句子 $id', tag: '', createdAt: DateTime(2026, 5, 23));

ProviderContainer _container(_CountingRepo repo) {
  return ProviderContainer(
    overrides: <Override>[
      quoteRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('QuotesNotifier.removeMany', () {
    test('一次取出多句, 命中的删掉, 其余保留', () async {
      final _CountingRepo repo = _CountingRepo(<Quote>[
        _q('1'),
        _q('2'),
        _q('3'),
        _q('4'),
      ]);
      final ProviderContainer c = _container(repo);
      await c.read(quotesProvider.notifier).ensureLoaded();

      await c.read(quotesProvider.notifier).removeMany(<String>['2', '4']);

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.map((Quote q) => q.id), <String>['1', '3']);
      c.dispose();
    });

    test('只落盘一次 (不是逐句 saveAll)', () async {
      final _CountingRepo repo = _CountingRepo(<Quote>[
        _q('1'),
        _q('2'),
        _q('3'),
      ]);
      final ProviderContainer c = _container(repo);
      await c.read(quotesProvider.notifier).ensureLoaded();
      repo.saveCount = 0; // 忽略加载阶段

      await c.read(quotesProvider.notifier).removeMany(<String>['1', '2', '3']);

      expect(c.read(quotesProvider).value, isEmpty);
      expect(repo.saveCount, 1);
      c.dispose();
    });

    test('空集合不动状态也不落盘', () async {
      final _CountingRepo repo = _CountingRepo(<Quote>[_q('1')]);
      final ProviderContainer c = _container(repo);
      await c.read(quotesProvider.notifier).ensureLoaded();
      repo.saveCount = 0;

      await c.read(quotesProvider.notifier).removeMany(<String>[]);

      expect(c.read(quotesProvider).value!.single.id, '1');
      expect(repo.saveCount, 0);
      c.dispose();
    });

    test('不存在的 id 静默跳过, 不报错', () async {
      final _CountingRepo repo = _CountingRepo(<Quote>[_q('1'), _q('2')]);
      final ProviderContainer c = _container(repo);
      await c.read(quotesProvider.notifier).ensureLoaded();

      await c
          .read(quotesProvider.notifier)
          .removeMany(<String>['2', 'nope-999']);

      expect(c.read(quotesProvider).value!.map((Quote q) => q.id), <String>['1']);
      c.dispose();
    });
  });
}
