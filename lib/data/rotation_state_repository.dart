import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';

/// 屏保轮播状态快照: 洗牌后的 quote-id 顺序 + 本轮位置 + 轮次。
typedef RotationSnapshot = ({List<String> ids, int pos, int round});

/// 屏保轮播状态的持久化 (v0.26.0, HANDOFF 第二轮"下次开机接着上次的位置")。
///
/// 存 SharedPreferences 而非 drift: 与收藏/设置同一套简单键值惯例,
/// Web / 鸿蒙 (prefs 桥) 平台同样生效; 数据量只有一份 id 列表。
class RotationStateRepository {
  RotationStateRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String prefsKey = 'folio.display.rotation.v1';

  /// 读取快照; 无存档或数据损坏返回 null (调用方重新洗牌)。
  RotationSnapshot? load() {
    final String? raw = _prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      final List<String> ids = <String>[
        for (final dynamic e in m['ids'] as List<dynamic>) e as String,
      ];
      return (ids: ids, pos: m['pos'] as int, round: m['round'] as int);
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'rotation state decode failed');
      return null;
    }
  }

  Future<void> save(RotationSnapshot snapshot) async {
    await _prefs.setString(
      prefsKey,
      jsonEncode(<String, dynamic>{
        'ids': snapshot.ids,
        'pos': snapshot.pos,
        'round': snapshot.round,
      }),
    );
  }
}
