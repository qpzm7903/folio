import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/presentation/providers.dart';

import 'support/quotes_test_support.dart';

/// saveAll 可控爆炸的仓储 —— 模拟磁盘满 / SQLite 写锁失败。
class _ExplodingRepo implements QuoteRepository {
  _ExplodingRepo(this._data);

  List<Quote> _data;
  bool explode = false;
  int saveCalls = 0;

  List<Quote> get persisted => List<Quote>.unmodifiable(_data);

  @override
  Future<List<Quote>> loadAll() async => List<Quote>.of(_data);

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    saveCalls++;
    if (explode) throw Exception('disk full');
    _data = List<Quote>.of(quotes);
  }
}

Quote _q(String id, String tag) =>
    Quote(id: id, text: '句 $id', tag: tag, createdAt: DateTime(2026, 6, 1));

void main() {
  // v0.23.1 重构: _mutate 落盘失败时回滚 state 并返回 false (审查遗留 F9)。
  // 此前先写 state 再 await saveAll 且无 try/catch: 失败时 UI 显示成功,
  // 重启后数据复活, 异常成为无用户反馈的 unhandled async error。
  group('QuotesNotifier mutate 落盘失败', () {
    late _ExplodingRepo repo;
    late ProviderContainer c;

    setUp(() async {
      repo = _ExplodingRepo(<Quote>[_q('1', '坚持'), _q('2', '旅程')]);
      c = ProviderContainer(
        overrides: <Override>[
          quoteRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await awaitQuotesLoaded(c);
    });

    tearDown(() => c.dispose());

    test('add 落盘失败 → 返回 false, state 回滚, 持久层不变', () async {
      repo.explode = true;

      final bool ok =
          await c.read(quotesProvider.notifier).add('新句子', '');

      expect(ok, isFalse);
      expect(c.read(quotesProvider).value!.length, 2);
      expect(repo.persisted.length, 2);
    });

    test('removeTag 落盘失败 → 返回 false, 标签原样回滚', () async {
      repo.explode = true;

      final bool ok =
          await c.read(quotesProvider.notifier).removeTag('坚持');

      expect(ok, isFalse);
      final List<Quote> got = c.read(quotesProvider).value!;
      expect(got.where((Quote q) => q.tag == '坚持').length, 1);
    });

    test('失败后恢复正常 → 下一次 mutate 成功且返回 true', () async {
      repo.explode = true;
      await c.read(quotesProvider.notifier).add('丢失的句子', '');

      repo.explode = false;
      final bool ok =
          await c.read(quotesProvider.notifier).add('存住的句子', '');

      expect(ok, isTrue);
      expect(c.read(quotesProvider).value!.length, 3);
      expect(repo.persisted.length, 3);
    });

    test('update 未找到 id → 返回 false 且不触发落盘', () async {
      final int before = repo.saveCalls;

      final bool ok = await c
          .read(quotesProvider.notifier)
          .update('ghost', '文本', '标签');

      expect(ok, isFalse);
      expect(repo.saveCalls, before);
    });

    test('成功路径返回 true', () async {
      final bool ok =
          await c.read(quotesProvider.notifier).add('好句子', '标签');
      expect(ok, isTrue);
    });

    test('renameTag 无事可做 (同名/空 oldTag) → 返回 true 不落盘', () async {
      final int before = repo.saveCalls;
      expect(
        await c.read(quotesProvider.notifier).renameTag('坚持', '坚持'),
        isTrue,
      );
      expect(
        await c.read(quotesProvider.notifier).renameTag('', '生根'),
        isTrue,
      );
      expect(repo.saveCalls, before);
    });
  });
}
