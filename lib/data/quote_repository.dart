import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  return drift_impl.buildDriftQuoteRepository();
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
