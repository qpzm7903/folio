import 'dart:ffi';

import 'package:sqlite3/open.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';

/// 鸿蒙上 `sqlite3_flutter_libs` 没有 ohos 原生产物, 但 OpenHarmony
/// 系统自带 `libsqlite3.so` (relational store 底层同款)。在 drift 打开
/// 数据库之前, 把 `package:sqlite3` 的加载器指到系统库 (L20 里程碑②)。
///
/// 系统库 dlopen 失败时, drift 首查会 throw, 由 [buildQuoteRepository]
/// 的 try/catch 兜底降级到 prefs 仓储 —— 跟 Web 路径同一套机制。
///
/// [isOhos] / [applyOverride] 仅测试注入用, 生产调用零参。
bool configureOhosSqlite({bool? isOhos, void Function()? applyOverride}) {
  final bool ohos = isOhos ?? PlatformCapabilities.isOhos;
  if (!ohos) return false;
  (applyOverride ?? _applySystemSqliteOverride)();
  return true;
}

void _applySystemSqliteOverride() {
  open.overrideForAll(() => DynamicLibrary.open('libsqlite3.so'));
  AppLogger.instance.info('ohos: sqlite3 loader -> system libsqlite3.so');
}
