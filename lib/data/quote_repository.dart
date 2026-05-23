import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'drift_quote_repository_stub.dart'
    if (dart.library.io) 'drift_quote_repository_io.dart'
    as drift_impl;
import 'quote.dart';
import 'quote_codec.dart';

/// Quote 仓储 —— 抽象接口。
///
/// - **Native** (Android / iOS / desktop): `DriftQuoteRepository` (drift + sqlite3)
/// - **Web**: [_PrefsQuoteRepository] (SharedPreferences; drift web 留 v0.14+)
abstract class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<void> saveAll(List<Quote> quotes);
}

/// 工厂入口 —— 自动按平台选择实现。
///
/// 通过 conditional import 把 dart:io/drift/sqlite3 的链路完全隔离到
/// `drift_quote_repository_io.dart`, web build (dart2js) 只会解析
/// `drift_quote_repository_stub.dart`, 不会触达 dart:ffi。
Future<QuoteRepository> buildQuoteRepository() async {
  if (kIsWeb) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _PrefsQuoteRepository(prefs);
  }
  try {
    return await drift_impl.buildDriftQuoteRepository();
  } catch (e, st) {
    // drift / sqlite3 native 在某些设备上首次初始化失败 (v0.13.0 闪退 #1)。
    // 兜底用 in-memory 仓库, 让 app 至少打得开 + 显示种子金句。
    AppLogger.instance.handle(
      e,
      st,
      'drift init failed, falling back to in-memory repository',
    );
    return InMemoryQuoteRepository(buildSeedQuotes());
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

/// drift 初始化失败时的兜底实现。仅本进程内有效, 重启即丢。
/// 至少保证 app 不闪退 + 用户能看到种子金句 (v0.13.1 修复 #1)。
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
