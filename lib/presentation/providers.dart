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

  /// 把所有用 [oldTag] 的句子改成 [newTag]; 句子本身不动。
  /// `newTag` trim 后为空 → 等价于 [removeTag] (从这些句子上"取下"标签)。
  Future<void> renameTag(String oldTag, String newTag) async {
    final String from = oldTag.trim();
    final String to = newTag.trim();
    if (from.isEmpty || from == to) return;
    await _mutate(
      log: 'renamed tag "$from" → "$to"',
      transform: (List<Quote> cur) => <Quote>[
        for (final Quote q in cur)
          if (q.tag == from) q.copyWith(tag: to) else q,
      ],
    );
  }

  /// 从所有句子上取下这个标签 (清空 tag 字段, 句子保留)。
  Future<void> removeTag(String tag) => renameTag(tag, '');

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

/// 派生: 每个非空标签的句数 (用于标签管理屏)。
/// 按句数倒序排, 最大的在前。
final Provider<List<TagCount>> tagCountsProvider = Provider<List<TagCount>>((
  Ref ref,
) {
  final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
  final List<Quote> data = async.value ?? const <Quote>[];
  final Map<String, int> counts = <String, int>{};
  for (final Quote q in data) {
    final String tag = q.tag.trim();
    if (tag.isEmpty) continue;
    counts[tag] = (counts[tag] ?? 0) + 1;
  }
  final List<TagCount> result = <TagCount>[
    for (final MapEntry<String, int> e in counts.entries)
      (tag: e.key, count: e.value),
  ];
  result.sort((TagCount a, TagCount b) => b.count.compareTo(a.count));
  return result;
});

/// (tag, count) 的轻量 record。
typedef TagCount = ({String tag, int count});

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
