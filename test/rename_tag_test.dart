import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/presentation/providers.dart';

class _FakeRepo implements QuoteRepository {
  _FakeRepo(this._data);
  List<Quote> _data;

  @override
  Future<List<Quote>> loadAll() async => List<Quote>.of(_data);

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    _data = List<Quote>.of(quotes);
  }
}

Quote _q(String id, String text, String tag) =>
    Quote(id: id, text: text, tag: tag, createdAt: DateTime(2026, 5, 23));

ProviderContainer _container(List<Quote> seed) {
  return ProviderContainer(
    overrides: <Override>[
      quoteRepositoryProvider.overrideWithValue(_FakeRepo(seed)),
    ],
  );
}

/// QuotesNotifier 构造时 fire-and-forget `_load()`; 这里 polling 等到
/// state 走出 loading 状态。
Future<List<Quote>> _ready(ProviderContainer c) async {
  for (int i = 0; i < 50; i++) {
    final AsyncValue<List<Quote>> state = c.read(quotesProvider);
    if (state.hasValue) return state.value!;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('QuotesNotifier did not finish loading within 500ms');
}

void main() {
  group('QuotesNotifier.renameTag / removeTag', () {
    test('renameTag 把所有 oldTag 改成 newTag, 其余不动', () async {
      final ProviderContainer c = _container(<Quote>[
        _q('1', '种子。', '坚持'),
        _q('2', '光。', '完整'),
        _q('3', '另一颗种子。', '坚持'),
      ]);
      await _ready(c);

      await c.read(quotesProvider.notifier).renameTag('坚持', '生根');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.where((Quote q) => q.tag == '生根').length, 2);
      expect(got.where((Quote q) => q.tag == '坚持').length, 0);
      expect(got.firstWhere((Quote q) => q.id == '2').tag, '完整');
      c.dispose();
    });

    test('removeTag 把命中句子的 tag 清空, 句子保留', () async {
      final ProviderContainer c = _container(<Quote>[
        _q('1', 'A', '完整'),
        _q('2', 'B', '完整'),
      ]);
      await _ready(c);

      await c.read(quotesProvider.notifier).removeTag('完整');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.length, 2);
      expect(got.every((Quote q) => q.tag.isEmpty), isTrue);
      c.dispose();
    });

    test('renameTag 同名 / 空 oldTag 不动状态', () async {
      final ProviderContainer c = _container(<Quote>[_q('1', 'A', '完整')]);
      await _ready(c);

      await c.read(quotesProvider.notifier).renameTag('完整', '完整');
      await c.read(quotesProvider.notifier).renameTag('', '生根');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.single.tag, '完整');
      c.dispose();
    });
  });
}
