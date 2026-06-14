import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quote_repository.dart';
import '../presentation/providers.dart';
import 'logger.dart';
import 'platform_capabilities.dart';

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

    // 鸿蒙 (L20): path_provider / shared_preferences 的 ohos 联邦插件受
    // flutter_ohos 工具链 bug 阻塞 (见 docs/wiki/ohos/upstream-issues.md),
    // 暂以内存版 prefs 降级 —— app 可正常浏览金句/屏保/主题, 数据不跨重启
    // 持久化。待上游修复后移除本守卫即可恢复 drift 持久化。
    if (PlatformCapabilities.isOhos) {
      // setMockInitialValues 是官方提供的内存版 store 注入点 (标注 visibleFor
      // Testing, 但这里是鸿蒙缺插件时的生产降级 shim, 非测试)。注入后所有
      // SharedPreferences.getInstance() 走内存, 不碰未注册的 ohos 原生通道。
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(<String, Object>{});
    }

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
