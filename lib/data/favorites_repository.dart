import 'package:shared_preferences/shared_preferences.dart';

import 'ohos_prefs_bridge.dart';

/// 收藏过的 [Quote.id] 集合 —— 用 SharedPreferences 存 Set<String>,
/// 故意跟 drift schema 解耦, PATCH 范围内不引入数据库迁移。
///
/// 完整的"收藏列表屏"留到 v0.14.0 MINOR; 这版只让 Display 屏的 bookmark
/// 按钮真正可用 (Issue #4).
class FavoritesRepository {
  FavoritesRepository(this._prefs);

  static const String _kKey = 'folio.favorites.ids.v1';

  final SharedPreferences _prefs;

  Set<String> load() => _prefs.getStringList(_kKey)?.toSet() ?? <String>{};

  Future<void> save(Set<String> ids) async {
    await _prefs.setStringList(_kKey, ids.toList(growable: false));
    // 鸿蒙: 落盘到 ArkTS preferences (非鸿蒙平台 no-op)。
    await OhosPrefsBridge.instance.flush(_prefs);
  }
}
