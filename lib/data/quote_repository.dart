import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'quote.dart';

/// Quote 仓储 —— JSON 文件持久化 (v0.1.0 简化方案), 后续 PATCH 会切到 drift。
///
/// 存储位置:
/// - 非 Web: `getApplicationSupportDirectory()/quotes.json`
/// - Web: 走 [SharedPreferences] (因为浏览器没有文件 IO)
abstract class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<void> saveAll(List<Quote> quotes);
}

/// 工厂入口 —— 自动按平台选择实现。
Future<QuoteRepository> buildQuoteRepository() async {
  if (kIsWeb) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _PrefsQuoteRepository(prefs);
  }
  final Directory dir = await getApplicationSupportDirectory();
  return _FileQuoteRepository(File('${dir.path}/quotes.json'));
}

const String _kPrefsKey = 'folio.quotes.v1';

class _FileQuoteRepository implements QuoteRepository {
  _FileQuoteRepository(this.file);

  final File file;

  @override
  Future<List<Quote>> loadAll() async {
    try {
      if (!file.existsSync()) {
        final List<Quote> seed = buildSeedQuotes();
        await saveAll(seed);
        AppLogger.instance.info(
          'quotes.json missing, seeded ${seed.length} quotes',
        );
        return seed;
      }
      final String raw = await file.readAsString();
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return <Quote>[
        for (final dynamic e in data) Quote.fromJson(e as Map<String, dynamic>),
      ];
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'failed to load quotes.json');
      return buildSeedQuotes();
    }
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    try {
      final String raw = jsonEncode(<Map<String, dynamic>>[
        for (final Quote q in quotes) q.toJson(),
      ]);
      await file.writeAsString(raw, flush: true);
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'failed to write quotes.json');
    }
  }
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
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return <Quote>[
        for (final dynamic e in data) Quote.fromJson(e as Map<String, dynamic>),
      ];
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'failed to decode prefs quotes');
      return buildSeedQuotes();
    }
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    final String raw = jsonEncode(<Map<String, dynamic>>[
      for (final Quote q in quotes) q.toJson(),
    ]);
    await prefs.setString(_kPrefsKey, raw);
  }
}
