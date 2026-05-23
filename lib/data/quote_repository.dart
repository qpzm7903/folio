import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/seed_quotes.dart';
import 'legacy_quotes_migration.dart';
import 'quote.dart';
import 'quote_codec.dart';

/// Quote 仓储 —— 抽象接口。
///
/// v0.13.4 起所有平台都走 [_PrefsQuoteRepository] (SharedPreferences)。
/// v0.13.0 ~ v0.13.3 native 走 drift + sqlite3, 但 Issue #5 触发
/// native SIGSEGV (`libsqlite3.so` 加载失败), Dart try/catch 无法
/// 兜住 native 崩溃, 只能在更外层 "根本不调用 drift" 的方案上修。
/// 等真因定位后, drift 路径会作为 L12 重新启用。
abstract class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<void> saveAll(List<Quote> quotes);
}

const String _kPrefsKey = 'folio.quotes.v1';

/// 工厂入口 —— 所有平台都用 [_PrefsQuoteRepository]。
///
/// Native 端启动时跑一次 [LegacyQuotesMigration] 把 v0.12.x 文件存储
/// (`${supportDir}/quotes.json`) 迁到 prefs, 不丢用户从老版本升级的数据。
Future<QuoteRepository> buildQuoteRepository() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!kIsWeb) {
    await LegacyQuotesMigration(prefs: prefs, prefsKey: _kPrefsKey).run();
  }
  return _PrefsQuoteRepository(prefs);
}

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
