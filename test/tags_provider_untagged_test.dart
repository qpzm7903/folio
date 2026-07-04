import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/domain/tag_filter.dart';
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

Quote _q(String id, String tag) =>
    Quote(id: id, text: '句 $id', tag: tag, createdAt: DateTime(2026, 6, 1));

ProviderContainer _container(List<Quote> seed) {
  return ProviderContainer(
    overrides: <Override>[
      quoteRepositoryProvider.overrideWithValue(_FakeRepo(seed)),
    ],
  );
}

Future<void> _ready(ProviderContainer c) async {
  for (int i = 0; i < 50; i++) {
    if (c.read(quotesProvider).hasValue) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('QuotesNotifier did not finish loading within 500ms');
}

void main() {
  // v0.23.0 标签管理: 存在无标签句时 tag-row 行末追加「未分类」虚拟 pill,
  // 让"删除标签会移到未分类"的确认文案在 UI 上兑现。
  group('tagsProvider 未分类 pill', () {
    test('有无标签句 → [全部, ...具名..., 未分类]', () async {
      final ProviderContainer c = _container(<Quote>[
        _q('1', '坚持'),
        _q('2', ''),
        _q('3', '旅程'),
      ]);
      await _ready(c);

      final List<String> tags = c.read(tagsProvider);
      expect(tags.first, kAllTagsLabel);
      expect(tags.last, kUntaggedLabel);
      expect(tags, containsAll(<String>['坚持', '旅程']));
      c.dispose();
    });

    test('全部句都有标签 → 不出现未分类', () async {
      final ProviderContainer c = _container(<Quote>[
        _q('1', '坚持'),
        _q('2', '旅程'),
      ]);
      await _ready(c);

      expect(c.read(tagsProvider), isNot(contains(kUntaggedLabel)));
      c.dispose();
    });

    test('全空白 tag 视同无标签', () async {
      final ProviderContainer c = _container(<Quote>[_q('1', '  ')]);
      await _ready(c);

      final List<String> tags = c.read(tagsProvider);
      expect(tags, <String>[kAllTagsLabel, kUntaggedLabel]);
      c.dispose();
    });

    test('金库为空 → 只有全部, 无未分类', () async {
      final ProviderContainer c = _container(<Quote>[]);
      await _ready(c);

      expect(c.read(tagsProvider), <String>[kAllTagsLabel]);
      c.dispose();
    });

    test('字面标签「未分类」归入未分类 pill, 不进具名集合 (不出重复 pill)', () async {
      final ProviderContainer c = _container(<Quote>[
        _q('1', kUntaggedLabel),
        _q('2', ''),
      ]);
      await _ready(c);

      expect(c.read(tagsProvider), <String>[kAllTagsLabel, kUntaggedLabel]);
      c.dispose();
    });

    test('add 标签「全部」被写入侧净化为无标签, 不与哨兵撞名', () async {
      final ProviderContainer c = _container(<Quote>[]);
      await _ready(c);

      await c.read(quotesProvider.notifier).add('一句话', kAllTagsLabel);

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.single.tag, '');
      expect(c.read(tagsProvider), <String>[kAllTagsLabel, kUntaggedLabel]);
      c.dispose();
    });
  });
}
