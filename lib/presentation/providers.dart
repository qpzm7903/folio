import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../data/background_image_service.dart';
import '../data/favorites_repository.dart';
import '../data/quote.dart';
import '../data/quote_repository.dart';
import '../data/settings_repository.dart';
import '../data/wallpaper_service.dart';
import '../data/widget_sync_service.dart';

/// SharedPreferences 由 main() 提前 await 后通过 [overrideWith] 注入。
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('overrideWith in ProviderScope');
});

final Provider<QuoteRepository> quoteRepositoryProvider =
    Provider<QuoteRepository>((Ref ref) {
  throw UnimplementedError('overrideWith in ProviderScope');
});

final Provider<BackgroundImageService> backgroundImageServiceProvider =
    Provider<BackgroundImageService>(
  (Ref ref) => const BackgroundImageService(),
);

final Provider<WidgetSyncService> widgetSyncServiceProvider =
    Provider<WidgetSyncService>((Ref ref) => const WidgetSyncService());

/// v0.15.9 Issue #8 起新增。v0.15.10 重构: 从 DisplayScreen widget state
/// 里直接 `new WallpaperService()` 抽到 provider, 跟其他 service 一致,
/// 让测试能 `overrideWithValue(_MockWallpaperService())` 不触真 MethodChannel。
final Provider<WallpaperService> wallpaperServiceProvider =
    Provider<WallpaperService>((Ref ref) => const WallpaperService());

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>((Ref ref) {
  return FavoritesRepository(ref.watch(sharedPreferencesProvider));
});

/// 收藏的 quote id 集合 —— Display 屏的 bookmark 按钮 toggle (Issue #4)。
/// 持久化到 SharedPreferences, 跟 drift schema 解耦。
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._repo) : super(_repo.load());

  final FavoritesRepository _repo;

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final Set<String> next = Set<String>.of(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _repo.save(next);
  }
}

final StateNotifierProvider<FavoritesNotifier, Set<String>> favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((Ref ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repo) : super(_repo.load());

  final SettingsRepository _repo;

  Future<void> setThemeMode(AppThemeMode mode) =>
      _apply(state.copyWith(themeMode: mode));

  Future<void> setShuffleNoRepeat(bool v) =>
      _apply(state.copyWith(shuffleNoRepeat: v));

  Future<void> setShowAttribution(bool v) =>
      _apply(state.copyWith(showAttribution: v));

  Future<void> setCadenceMinutes(int v) =>
      _apply(state.copyWith(cadenceMinutes: v));

  Future<void> setBackgroundImagePath(String? path) => _apply(
        state.copyWith(
          backgroundImagePath: path,
          clearBackgroundImage: path == null,
        ),
      );

  Future<void> setWidgetColorTheme(WidgetColorTheme t) =>
      _apply(state.copyWith(widgetColorTheme: t));

  /// 共用的"写 state + 落盘"流程, copyWith 差异收到 setter 各自一行 transform。
  Future<void> _apply(AppSettings next) async {
    state = next;
    await _repo.save(next);
  }
}

final StateNotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((Ref ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class QuotesNotifier extends StateNotifier<AsyncValue<List<Quote>>> {
  QuotesNotifier(this._repo) : super(const AsyncValue<List<Quote>>.loading()) {
    _ready = _load();
  }

  final QuoteRepository _repo;

  /// 首次 `_load()` 的 future。所有 mutate 操作在执行前 `await _ready`,
  /// 让用户在金库加载完之前的快点击不会因为 state == loading 而被静默丢弃。
  late final Future<void> _ready;

  /// 等首次加载完成。其他 widget / 测试 想在调用 mutate 前显式同步状态时用。
  Future<void> ensureLoaded() => _ready;

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
    // 先等首次加载完成, 避免 loading 期间用空 state 误判 not-found
    await _ready;
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
  /// 把所有 mutate 方法里重复的样板压成一行 transform。
  ///
  /// 关键: 先 `await _ready` 让首次加载完成, 防止 loading 期的并发 mutate
  /// 操作丢失数据。
  Future<void> _mutate({
    required String log,
    required List<Quote> Function(List<Quote>) transform,
  }) async {
    await _ready;
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
    quotesProvider =
    StateNotifierProvider<QuotesNotifier, AsyncValue<List<Quote>>>(
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
