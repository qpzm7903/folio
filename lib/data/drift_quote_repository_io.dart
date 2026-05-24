import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'drift/quotes_database.dart';
import 'quote.dart';
import 'quote_codec.dart';
import 'quote_repository.dart';

/// drift 后端的 [QuoteRepository]。
///
/// Web 上不可用 (dart:ffi 链); web build 走 [drift_quote_repository_stub.dart],
/// 通过 [conditional import](https://dart.dev/guides/libraries/create-packages#conditionally-importing-and-exporting-library-files) 隔离。
class DriftQuoteRepository implements QuoteRepository {
  DriftQuoteRepository(this._db);

  final QuotesDatabase _db;

  @override
  Future<List<Quote>> loadAll() => _db.loadAll();

  @override
  Future<void> saveAll(List<Quote> quotes) => _db.saveAll(quotes);
}

/// 工厂: 打开默认 drift DB + 必要时种子化 / 迁数据 + 包成 [DriftQuoteRepository]。
///
/// 数据来源优先级 (只在 drift 库空时启用一次):
/// 1. [bootstrapQuotes] (v0.13.4 ~ v0.14.1 的 SharedPreferences 数据,
///    由 [buildQuoteRepository] 调用前 drain 出来)
/// 2. `${supportDir}/quotes.json` (v0.12.x 文件存储残留) → 解析 + rename 备份
/// 3. 都没有 → 种子数据
Future<QuoteRepository> buildDriftQuoteRepository({
  List<Quote>? bootstrapQuotes,
}) async {
  final Directory dir = await getApplicationSupportDirectory();
  final QuotesDatabase db = QuotesDatabase.openDefault();

  final List<Quote> existing = await db.loadAll();
  if (existing.isNotEmpty) {
    return DriftQuoteRepository(db);
  }

  // drift 库空, 按优先级初始化一次
  if (bootstrapQuotes != null && bootstrapQuotes.isNotEmpty) {
    await db.saveAll(bootstrapQuotes);
    AppLogger.instance.info(
      'migrated ${bootstrapQuotes.length} quotes prefs → drift (v0.13.4 ~ v0.14.1 era)',
    );
    // 写入成功后清掉 prefs key, 避免 v0.16+ 再次重复迁入
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(kPrefsQuotesKey);
    } catch (e, st) {
      AppLogger.instance.handle(
        e,
        st,
        'failed to clear prefs after drift migrate',
      );
    }
    return DriftQuoteRepository(db);
  }

  final File legacyJson = File('${dir.path}/quotes.json');
  if (legacyJson.existsSync()) {
    try {
      final String raw = await legacyJson.readAsString();
      final List<Quote>? decoded = QuoteCodec.tryDecode(
        raw,
        context: 'drift legacy json migration',
      );
      if (decoded != null && decoded.isNotEmpty) {
        await db.saveAll(decoded);
        final String backup =
            '${legacyJson.path}.migrated-${DateTime.now().millisecondsSinceEpoch}';
        await legacyJson.rename(backup);
        AppLogger.instance.info(
          'migrated ${decoded.length} quotes JSON → drift; backup at $backup',
        );
        return DriftQuoteRepository(db);
      }
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'JSON → drift migration failed');
    }
  }

  await db.saveAll(buildSeedQuotes());
  AppLogger.instance.info('seeded drift with default quotes');
  return DriftQuoteRepository(db);
}
