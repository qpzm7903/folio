import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import 'quote.dart';
import 'quote_codec.dart';

/// 把旧格式的 quote 数据迁到当前 [SharedPreferences] 存储。
///
/// 历史背景:
/// - v0.1.0 ~ v0.12.x native 端用 `${supportDir}/quotes.json` 文件
/// - v0.13.0 ~ v0.13.3 native 端短暂走 drift + sqlite3, 但 Issue #5 触发
///   native SIGSEGV, v0.13.4 切回 SharedPreferences
/// - 当前用户可能是从 v0.12.x 升级, 数据还在 `quotes.json` 里
///
/// 迁完后把原文件 rename 成 `.migrated-<ts>` 作为备份, 不直接删 (用户能恢复)。
/// 任何步骤失败都 swallow + log, 不中断启动流程。
class LegacyQuotesMigration {
  const LegacyQuotesMigration({required this.prefs, required this.prefsKey});

  final SharedPreferences prefs;
  final String prefsKey;

  Future<void> run() async {
    if (prefs.getString(prefsKey) != null) return;
    try {
      final Directory dir = await getApplicationSupportDirectory();
      final File legacy = File('${dir.path}/quotes.json');
      if (!legacy.existsSync()) return;
      final String raw = await legacy.readAsString();
      final List<Quote>? decoded = QuoteCodec.tryDecode(
        raw,
        context: 'legacy quotes.json migration',
      );
      if (decoded == null || decoded.isEmpty) return;
      await prefs.setString(prefsKey, QuoteCodec.encode(decoded));
      final String backup =
          '${legacy.path}.migrated-${DateTime.now().millisecondsSinceEpoch}';
      await legacy.rename(backup);
      AppLogger.instance.info(
        'migrated ${decoded.length} quotes JSON → prefs; backup at $backup',
      );
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'legacy JSON → prefs migration failed');
    }
  }
}
