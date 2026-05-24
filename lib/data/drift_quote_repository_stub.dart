import 'quote.dart';
import 'quote_repository.dart';

/// Web stub —— drift native 仓储在 Web 上不可用 (dart:ffi / sqlite3 不可达)。
///
/// 实际不会被调用: [buildQuoteRepository] 在 `kIsWeb` 分支提前 return
/// SharedPreferences 实现。这里只是让 conditional import 能编译过去。
Future<QuoteRepository> buildDriftQuoteRepository({
  List<Quote>? bootstrapQuotes,
}) {
  throw UnsupportedError(
    'drift native quote repository is not available on web',
  );
}
