import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../data/quote.dart';
import '../data/quote_repository.dart';
import '../data/settings_repository.dart';

/// SharedPreferences 由 main() 提前 await 后通过 [overrideWith] 注入。
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
      throw UnimplementedError('overrideWith in ProviderScope');
    });

final Provider<QuoteRepository> quoteRepositoryProvider =
    Provider<QuoteRepository>((Ref ref) {
      throw UnimplementedError('overrideWith in ProviderScope');
    });

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
      return SettingsRepository(ref.watch(sharedPreferencesProvider));
    });

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repo) : super(_repo.load());

  final SettingsRepository _repo;

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> setShuffleNoRepeat(bool v) async {
    state = state.copyWith(shuffleNoRepeat: v);
    await _repo.save(state);
  }

  Future<void> setShowAttribution(bool v) async {
    state = state.copyWith(showAttribution: v);
    await _repo.save(state);
  }

  Future<void> setCadenceMinutes(int v) async {
    state = state.copyWith(cadenceMinutes: v);
    await _repo.save(state);
  }
}

final StateNotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((Ref ref) {
      return SettingsNotifier(ref.watch(settingsRepositoryProvider));
    });

class QuotesNotifier extends StateNotifier<AsyncValue<List<Quote>>> {
  QuotesNotifier(this._repo) : super(const AsyncValue<List<Quote>>.loading()) {
    unawaited(_load());
  }

  final QuoteRepository _repo;

  Future<void> _load() async {
    try {
      final List<Quote> data = await _repo.loadAll();
      // 按时间倒序排, 让最新的在最上面
      data.sort((Quote a, Quote b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue<List<Quote>>.data(data);
      AppLogger.instance.debug('loaded ${data.length} quotes');
    } catch (e, st) {
      state = AsyncValue<List<Quote>>.error(e, st);
    }
  }

  Future<void> add(String text, String tag) async {
    final Quote q = Quote(
      id: _newId(),
      text: text.trim(),
      tag: tag.trim(),
      createdAt: DateTime.now(),
    );
    await _mutate(
      log: 'added quote id=${q.id}',
      transform: (List<Quote> cur) => <Quote>[q, ...cur],
    );
  }

  Future<void> addMany(Iterable<String> texts, {String tag = ''}) async {
    final DateTime now = DateTime.now();
    int i = 0;
    final List<Quote> created = <Quote>[
      for (final String t in texts)
        if (t.trim().isNotEmpty)
          Quote(
            id: _newId(suffix: i++),
            text: t.trim(),
            tag: tag.trim(),
            // 让批量导入的句子保持毫秒级间隔, 排序时不全部并列
            createdAt: now.add(Duration(milliseconds: i)),
          ),
    ];
    if (created.isEmpty) return;
    await _mutate(
      log: 'bulk added ${created.length} quotes',
      transform: (List<Quote> cur) => <Quote>[...created.reversed, ...cur],
    );
  }

  Future<void> update(String id, String text, String tag) async {
    final List<Quote> current = state.value ?? const <Quote>[];
    final int idx = current.indexWhere((Quote q) => q.id == id);
    if (idx < 0) {
      AppLogger.instance.warning('update id=$id not found, ignoring');
      return;
    }
    final Quote updated = current[idx].copyWith(
      text: text.trim(),
      tag: tag.trim(),
    );
    await _mutate(
      log: 'updated quote id=$id',
      transform: (List<Quote> cur) {
        final List<Quote> next = List<Quote>.of(cur);
        final int now = next.indexWhere((Quote q) => q.id == id);
        if (now >= 0) next[now] = updated;
        return next;
      },
    );
  }

  Future<void> remove(String id) async {
    await _mutate(
      log: 'removed quote id=$id',
      transform: (List<Quote> cur) =>
          cur.where((Quote q) => q.id != id).toList(growable: false),
    );
  }

  /// 共用的"读 current → 算 next → 落盘 + 写状态 + 记日志"流程。
  /// 把 4 个 mutate 方法里重复的样板压成一行 transform。
  Future<void> _mutate({
    required String log,
    required List<Quote> Function(List<Quote>) transform,
  }) async {
    final List<Quote> current = state.value ?? const <Quote>[];
    final List<Quote> next = transform(current);
    state = AsyncValue<List<Quote>>.data(next);
    await _repo.saveAll(next);
    AppLogger.instance.info(log);
  }

  String _newId({int suffix = 0}) {
    final int t = DateTime.now().microsecondsSinceEpoch;
    return 'q-$t-$suffix';
  }
}

final StateNotifierProvider<QuotesNotifier, AsyncValue<List<Quote>>>
quotesProvider = StateNotifierProvider<QuotesNotifier, AsyncValue<List<Quote>>>(
  (Ref ref) {
    return QuotesNotifier(ref.watch(quoteRepositoryProvider));
  },
);

/// 派生: 全部标签 (含"全部")。
final Provider<List<String>> tagsProvider = Provider<List<String>>((Ref ref) {
  final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
  final List<Quote> data = async.value ?? <Quote>[];
  final Set<String> set = <String>{};
  for (final Quote q in data) {
    if (q.tag.trim().isNotEmpty) set.add(q.tag);
  }
  return <String>['全部', ...set];
});

/// 当前选中的标签 (默认全部)。
final StateProvider<String> activeTagProvider = StateProvider<String>(
  (Ref ref) => '全部',
);

/// 当前是否处于深色模式 —— 综合 settings + system。
bool resolveIsDark(AppThemeMode mode, Brightness platform) {
  switch (mode) {
    case AppThemeMode.paper:
      return false;
    case AppThemeMode.night:
      return true;
    case AppThemeMode.system:
      return platform == Brightness.dark;
  }
}

/// 仅在 debug 模式输出 provider 列表, 用来诊断启动问题。
void logActiveProviders(ProviderContainer container) {
  if (!kDebugMode) return;
  AppLogger.instance.debug('active providers in container');
  for (final element in container.getAllProviderElements()) {
    AppLogger.instance.debug('  ${element.provider}');
  }
}
