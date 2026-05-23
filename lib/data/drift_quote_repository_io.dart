import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'drift/quotes_database.dart';
import 'quote.dart';
import 'quote_codec.dart';
import 'quote_repository.dart';

/// drift 后端的 [QuoteRepository]。
///
/// 启动 loadAll 时若 SQLite 空且 `quotes.json` 存在 → 解析旧 JSON 导入 +
/// 把旧文件 rename 成 `quotes.json.migrated-<ts>` 作为备份。
///
/// Web 上不可用 (dart:ffi 链); web build 走 [drift_quote_repository_stub.dart],
/// 通过 [conditional import](https://dart.dev/guides/libraries/create-packages#conditionally-importing-and-exporting-library-files) 隔离。
class DriftQuoteRepository implements QuoteRepository {
  DriftQuoteRepository(this._db, {File? legacyJson}) : _legacyJson = legacyJson;

  final QuotesDatabase _db;
  final File? _legacyJson;
  bool _migrationChecked = false;

  @override
  Future<List<Quote>> loadAll() async {
    if (!_migrationChecked) {
      _migrationChecked = true;
      await _maybeMigrateFromJson();
    }
    return _db.loadAll();
  }

  @override
  Future<void> saveAll(List<Quote> quotes) => _db.saveAll(quotes);

  Future<void> _maybeMigrateFromJson() async {
    final File? legacy = _legacyJson;
    if (legacy == null) return;
    if (!legacy.existsSync()) return;
    try {
      final List<Quote> existing = await _db.loadAll();
      if (existing.isNotEmpty) {
        AppLogger.instance.info(
          'drift already has ${existing.length} quotes, skip JSON migration',
        );
        return;
      }
      final String raw = await legacy.readAsString();
      final List<Quote>? decoded = QuoteCodec.tryDecode(
        raw,
        context: 'drift legacy json migration',
      );
      if (decoded == null || decoded.isEmpty) {
        AppLogger.instance.info(
          'legacy quotes.json empty or invalid, skip migration',
        );
        return;
      }
      await _db.saveAll(decoded);
      final String backup =
          '${legacy.path}.migrated-${DateTime.now().millisecondsSinceEpoch}';
      await legacy.rename(backup);
      AppLogger.instance.info(
        'migrated ${decoded.length} quotes JSON → drift; backup at $backup',
      );
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'JSON → drift migration failed');
    }
  }
}

/// 工厂: 打开默认 drift DB + 必要时种子化 + 包成 [DriftQuoteRepository]。
Future<QuoteRepository> buildDriftQuoteRepository() async {
  final Directory dir = await getApplicationSupportDirectory();
  final File legacyJson = File('${dir.path}/quotes.json');
  final QuotesDatabase db = QuotesDatabase.openDefault();

  // drift 首次 (库空) 且 legacy JSON 也不存在 → 种子数据
  final List<Quote> existing = await db.loadAll();
  if (existing.isEmpty && !legacyJson.existsSync()) {
    await db.saveAll(buildSeedQuotes());
    AppLogger.instance.info('seeded drift with default quotes');
  }
  return DriftQuoteRepository(db, legacyJson: legacyJson);
}
