import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/seed_quotes.dart';
import 'drift_quote_repository_stub.dart'
    if (dart.library.io) 'drift_quote_repository_io.dart' as drift_impl;
import 'ohos_prefs_bridge.dart';
import 'quote.dart';
import 'quote_codec.dart';

/// Quote 仓储 —— 抽象接口。
///
/// - **Native** (Android / iOS / desktop): `DriftQuoteRepository` (drift + sqlite3, L12)
/// - **Web**: [_PrefsQuoteRepository] (SharedPreferences; drift web 需要 sqlite.wasm,
///   留到 v0.16+ 单独处理)
///
/// **v0.13.0 ~ v0.14.1 历史**: v0.13.0 首次引入 drift, v0.13.4 因 Issue #5
/// 误判为 sqlite3 native SIGSEGV 切除回 prefs, v0.14.1 用 adb 抓栈定位真因
/// 是 home_widget 拉进来的 androidx.work WorkManagerInitializer 在 Android 16
/// 上 Room 创建 WorkDatabase 失败 (跟 drift 无关), v0.15.0 重新引入 drift。
abstract class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<void> saveAll(List<Quote> quotes);
}

/// SharedPreferences 存 quotes 的 key (v0.13.4 ~ v0.14.1 时代用)。
/// drift 启动时如果 drift 库空 + 这里有数据 → 一次性迁入 drift + 清掉。
const String kPrefsQuotesKey = 'folio.quotes.v1';

/// 工厂入口 —— 自动按平台选择实现。
///
/// Native:
/// 1. 把 v0.13.4 ~ v0.14.1 时代的 prefs 数据 (`folio.quotes.v1`) drain 出来
/// 2. 交给 drift 启动, 库空时按 prefs → JSON → seed 优先级 bootstrap
/// 3. 任何一步失败 → fallback 到 [_PrefsQuoteRepository] 让 app 至少打得开
Future<QuoteRepository> buildQuoteRepository() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (kIsWeb) {
    return _PrefsQuoteRepository(prefs);
  }
  try {
    final List<Quote>? bootstrapQuotes = _drainPrefs(prefs);
    return await drift_impl.buildDriftQuoteRepository(
      bootstrapQuotes: bootstrapQuotes,
    );
  } catch (e, st) {
    AppLogger.instance.handle(
      e,
      st,
      'drift init failed, falling back to prefs repository',
    );
    return _PrefsQuoteRepository(prefs);
  }
}

/// 把 prefs 中的 quotes (v0.13.4 ~ v0.14.1 时代写入) 取出, 返给 drift
/// bootstrap。不在这里删 key, 等 drift 真正写入成功后由 drift_repo_io 删。
List<Quote>? _drainPrefs(SharedPreferences prefs) {
  final String? raw = prefs.getString(kPrefsQuotesKey);
  if (raw == null || raw.isEmpty) return null;
  return QuoteCodec.tryDecode(
    raw,
    context: 'drain prefs quotes for drift migration',
  );
}

class _PrefsQuoteRepository implements QuoteRepository {
  _PrefsQuoteRepository(this.prefs);

  final SharedPreferences prefs;

  @override
  Future<List<Quote>> loadAll() async {
    final String? raw = prefs.getString(kPrefsQuotesKey);
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
    await prefs.setString(kPrefsQuotesKey, QuoteCodec.encode(quotes));
    // 鸿蒙: 把内存 prefs 落盘到 ArkTS preferences (非鸿蒙平台 no-op)。
    await OhosPrefsBridge.instance.flush(prefs);
  }
}

/// 进程内兜底实现 (v0.13.1 引入, drift 极端失败时 fallback 配合)。
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
