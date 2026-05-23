import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/l10n/generated/app_localizations.dart';
import 'package:folio/presentation/providers.dart';
import 'package:folio/theme/app_theme.dart';
import 'package:folio/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 内存版 QuoteRepository —— widget 测试用, 不动文件 / prefs。
class FakeQuoteRepository implements QuoteRepository {
  FakeQuoteRepository([List<Quote>? seed, this.loadDelay = Duration.zero])
    : _data = List<Quote>.of(seed ?? <Quote>[]);

  List<Quote> _data;

  /// 模拟"金库正在加载中"的延时, 让测试可以验证 mutate 调用在 _ready
  /// 阻塞期间被排队 (v0.9.1)。默认 0, 不延时。
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

/// 把 [child] 挂到一个完整的 MaterialApp + XJKTheme + Riverpod + i18n delegate 树下。
///
/// 用法:
/// ```dart
/// final repo = FakeQuoteRepository([_q('1', '...')]);
/// await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
/// await tester.pumpAndSettle();
/// expect(find.text('小金库'), findsOneWidget);
/// ```
Future<void> pumpAppWith(
  WidgetTester tester, {
  required Widget child,
  FakeQuoteRepository? repo,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FakeQuoteRepository effectiveRepo = repo ?? FakeQuoteRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        quoteRepositoryProvider.overrideWithValue(effectiveRepo),
      ],
      child: MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildThemeData(XJKTokens.paper(), brightness: Brightness.light),
        builder: (BuildContext _, Widget? c) => XJKTheme(
          tokens: XJKTokens.paper(),
          child: c ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          // Consumer 包一层强制 watch quotesProvider, 让 QuotesNotifier 在
          // widget build 时就构造 + 启动 _load; 否则像 EditorScreen 这种
          // 只在事件回调里 `ref.read(quotesProvider.notifier)` 的屏会让 _load
          // 在 update 那一瞬才被触发, state 还是 loading, 然后 update 静默
          // 失败 (warning + return)。
          body: Consumer(
            builder: (BuildContext _, WidgetRef ref, Widget? __) {
              ref.watch(quotesProvider);
              return child;
            },
          ),
        ),
      ),
    ),
  );

  // QuotesNotifier 构造时 `unawaited(_load())` 是真实 event-loop async;
  // tester.pumpAndSettle 只 pump frame, 不释放 event loop。要等 _load
  // 完成必须显式 runAsync 把 microtask / I/O 跑完, 再 pump 一帧让 widget
  // 看到 state.data 而不是 state.loading。
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pump();
}

Quote testQuote({
  String id = 't',
  String text = '光从裂痕里照进来。',
  String tag = '完整而非完美',
  DateTime? createdAt,
}) {
  return Quote(
    id: id,
    text: text,
    tag: tag,
    createdAt: createdAt ?? DateTime(2026, 5, 23),
  );
}
