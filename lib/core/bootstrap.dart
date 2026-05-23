import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quote_repository.dart';
import '../presentation/providers.dart';
import 'logger.dart';

/// 进程级初始化: 给 [main] (生产入口) 和未来的集成测试入口共用。
///
/// 返回的 [Override] 列表直接喂给 [ProviderScope.overrides]。
class Bootstrap {
  const Bootstrap._();

  /// 完整初始化序列。调用方负责 [ProviderScope] + [runApp]。
  ///
  /// 顺序很关键:
  /// 1. ensureInitialized 让 plugin 通道可用
  /// 2. logger 落盘到 getApplicationSupportDirectory (要先于其他可能记日志的步骤)
  /// 3. intl zh_CN data, 让 DateFormat('M月 d日', 'zh_CN') 不抛 LocaleData unavailable
  /// 4. 加载需要 plugin 的实例: SharedPreferences / QuoteRepository
  static Future<List<Override>> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppLogger.init();
    await initializeDateFormatting('zh_CN');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final QuoteRepository quoteRepo = await buildQuoteRepository();

    return <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      quoteRepositoryProvider.overrideWithValue(quoteRepo),
    ];
  }
}
