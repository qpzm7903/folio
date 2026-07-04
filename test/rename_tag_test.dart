import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/providers.dart';

import 'support/quotes_test_support.dart';

Quote _q(String id, String text, String tag) =>
    Quote(id: id, text: text, tag: tag, createdAt: DateTime(2026, 5, 23));

void main() {
  group('QuotesNotifier.renameTag / removeTag', () {
    test('renameTag 把所有 oldTag 改成 newTag, 其余不动', () async {
      final ProviderContainer c = quotesContainer(<Quote>[
        _q('1', '种子。', '坚持'),
        _q('2', '光。', '完整'),
        _q('3', '另一颗种子。', '坚持'),
      ]);
      await awaitQuotesLoaded(c);

      await c.read(quotesProvider.notifier).renameTag('坚持', '生根');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.where((Quote q) => q.tag == '生根').length, 2);
      expect(got.where((Quote q) => q.tag == '坚持').length, 0);
      expect(got.firstWhere((Quote q) => q.id == '2').tag, '完整');
      c.dispose();
    });

    test('removeTag 把命中句子的 tag 清空, 句子保留', () async {
      final ProviderContainer c = quotesContainer(<Quote>[
        _q('1', 'A', '完整'),
        _q('2', 'B', '完整'),
      ]);
      await awaitQuotesLoaded(c);

      await c.read(quotesProvider.notifier).removeTag('完整');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.length, 2);
      expect(got.every((Quote q) => q.tag.isEmpty), isTrue);
      c.dispose();
    });

    test('renameTag 同名 / 空 oldTag 不动状态', () async {
      final ProviderContainer c = quotesContainer(<Quote>[_q('1', 'A', '完整')]);
      await awaitQuotesLoaded(c);

      await c.read(quotesProvider.notifier).renameTag('完整', '完整');
      await c.read(quotesProvider.notifier).renameTag('', '生根');

      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.single.tag, '完整');
      c.dispose();
    });
  });
}
