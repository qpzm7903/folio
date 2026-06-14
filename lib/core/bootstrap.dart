import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/ohos_prefs_bridge.dart';
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
    // 内存版 SharedPreferences 降级 —— 但通过 [OhosPrefsBridge] 自写 channel
    // 把数据落到 ArkTS @ohos.data.preferences, 启动时读回喂给内存 store, 实现
    // 真持久化 (用户导入的金句不再一关 app 就丢)。
    if (PlatformCapabilities.isOhos) {
      // 先经 channel 读回上次落盘的快照, 再注入内存 store, 这样内存 prefs
      // 一开始就带着持久化数据。setMockInitialValues 标注 visibleForTesting,
      // 但这里是鸿蒙缺插件时的生产降级 shim, 非测试。
      final Map<String, Object> restored =
          await OhosPrefsBridge.instance.loadSnapshot();
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(restored);
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
