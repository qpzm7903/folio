import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/presentation/providers.dart';

/// 内存版 QuoteRepository —— 单元/Widget 测试共用, 不动文件 / prefs。
/// (v0.26.1 从 test_harness 与三个单测文件的私有副本收敛而来。)
class FakeQuoteRepository implements QuoteRepository {
  FakeQuoteRepository([List<Quote>? seed, this.loadDelay = Duration.zero])
      : _data = List<Quote>.of(seed ?? <Quote>[]);

  List<Quote> _data;

  /// 模拟"金库正在加载中"的延时, 验证 mutate 在 _ready 阻塞期间排队 (v0.9.1)。
  final Duration loadDelay;

  /// 当前持久化的快照, 测试断言用。
  List<Quote> get snapshot => List<Quote>.unmodifiable(_data);

  @override
  Future<List<Quote>> loadAll() async {
    if (loadDelay > Duration.zero) {
      await Future<void>.delayed(loadDelay);
    }
    return List<Quote>.of(_data);
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    _data = List<Quote>.of(quotes);
  }
}

/// 建一个只覆盖 quoteRepositoryProvider 的容器 (纯 Dart provider 测试用)。
ProviderContainer quotesContainer(List<Quote> seed) {
  return ProviderContainer(
    overrides: <Override>[
      quoteRepositoryProvider.overrideWithValue(FakeQuoteRepository(seed)),
    ],
  );
}

/// 等 QuotesNotifier 首次 `_load()` (fire-and-forget) 走出 loading。
Future<List<Quote>> awaitQuotesLoaded(ProviderContainer c) async {
  for (int i = 0; i < 50; i++) {
    final AsyncValue<List<Quote>> state = c.read(quotesProvider);
    if (state.hasValue) return state.value!;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('QuotesNotifier did not finish loading within 500ms');
}
