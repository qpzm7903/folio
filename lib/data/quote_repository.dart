import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'quote.dart';
import 'quote_codec.dart';

/// Quote 仓储 —— 抽象接口。
///
/// v0.13.4 起所有平台都走 SharedPreferences 实现。v0.13.0 ~ v0.13.3 native
/// 走 drift+sqlite3, 但用户机型上 `libsqlite3.so` 加载触发 SIGSEGV
/// (Issue #5), Dart try/catch 无法兜住 native 崩溃, 只能在更外层
/// "根本不调用 drift" 的方案上修。等真因定位 (机型/Android 版本/
/// sqlite3_flutter_libs commit) 后, drift 路径会作为 L12 重新启用。
abstract class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<void> saveAll(List<Quote> quotes);
}

/// 工厂入口 —— 所有平台都用 [_PrefsQuoteRepository]。
///
/// Native 端首次启动时若 `getApplicationSupportDirectory()/quotes.json`
/// (v0.12.x 文件存储残留) 存在且 prefs 为空 → 一次性导入 + rename 备份,
/// 不丢用户从 v0.12.x 升级过来的数据。
Future<QuoteRepository> buildQuoteRepository() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!kIsWeb) {
    await _maybeMigrateLegacyJson(prefs);
  }
  return _PrefsQuoteRepository(prefs);
}

Future<void> _maybeMigrateLegacyJson(SharedPreferences prefs) async {
  if (prefs.getString(_kPrefsKey) != null) return;
  try {
    final Directory dir = await getApplicationSupportDirectory();
    final File legacy = File('${dir.path}/quotes.json');
    if (!legacy.existsSync()) return;
    final String raw = await legacy.readAsString();
    final List<Quote>? decoded = QuoteCodec.tryDecode(
      raw,
      context: 'legacy quotes.json migration',
    );
    if (decoded == null || decoded.isEmpty) return;
    await prefs.setString(_kPrefsKey, QuoteCodec.encode(decoded));
    final String backup =
        '${legacy.path}.migrated-${DateTime.now().millisecondsSinceEpoch}';
    await legacy.rename(backup);
    AppLogger.instance.info(
      'migrated ${decoded.length} quotes JSON → prefs; backup at $backup',
    );
  } catch (e, st) {
    AppLogger.instance.handle(e, st, 'legacy JSON → prefs migration failed');
  }
}

const String _kPrefsKey = 'folio.quotes.v1';

class _PrefsQuoteRepository implements QuoteRepository {
  _PrefsQuoteRepository(this.prefs);

  final SharedPreferences prefs;

  @override
  Future<List<Quote>> loadAll() async {
    final String? raw = prefs.getString(_kPrefsKey);
    if (raw == null) {
      final List<Quote> seed = buildSeedQuotes();
      await saveAll(seed);
      return seed;
    }
    if (raw.isEmpty) return buildSeedQuotes();
    return QuoteCodec.tryDecode(raw, context: 'load prefs quotes') ??
        buildSeedQuotes();
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    await prefs.setString(_kPrefsKey, QuoteCodec.encode(quotes));
  }
}

/// 进程内兜底实现 (v0.13.1 引入, v0.13.4 起 drift 路径已切除,
/// 该类仅供测试 + 极端 prefs 读失败时使用)。
class InMemoryQuoteRepository implements QuoteRepository {
  InMemoryQuoteRepository(List<Quote> initial)
    : _quotes = List<Quote>.from(initial);

  List<Quote> _quotes;

  @override
  Future<List<Quote>> loadAll() async => List<Quote>.unmodifiable(_quotes);

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    _quotes = List<Quote>.from(quotes);
  }
}
