import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'quote.dart';
import 'quote_codec.dart';

/// Quote 仓储 —— JSON 持久化 (v0.1.x 简化方案), 后续 MINOR 切到 drift。
///
/// 存储位置:
/// - 非 Web: `getApplicationSupportDirectory()/quotes.json`
/// - Web: 走 [SharedPreferences] (浏览器没有文件 IO)
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

/// 装载入口: 解析 [raw], 失败时记日志并 fallback 到种子数据。
List<Quote> _decodeOrSeed(String? raw, {required String context}) {
  if (raw == null || raw.isEmpty) return buildSeedQuotes();
  return QuoteCodec.tryDecode(raw, context: context) ?? buildSeedQuotes();
}

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
      return _decodeOrSeed(raw, context: 'load quotes.json');
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'failed to load quotes.json');
      return buildSeedQuotes();
    }
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    try {
      await file.writeAsString(QuoteCodec.encode(quotes), flush: true);
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
    return _decodeOrSeed(raw, context: 'load prefs quotes');
  }

  @override
  Future<void> saveAll(List<Quote> quotes) async {
    await prefs.setString(_kPrefsKey, QuoteCodec.encode(quotes));
  }
}
