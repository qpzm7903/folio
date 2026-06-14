import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';

/// 鸿蒙 (L20) 数据持久化桥 —— 让 app 数据真正落盘。
///
/// 背景: 鸿蒙上 `shared_preferences` / `path_provider` 的联邦插件被上游工具链
/// bug 阻塞 (upstream-issues #1), Folio 一直以**内存版 SharedPreferences 降级**
/// (bootstrap `setMockInitialValues`), 数据不跨重启 —— 用户导入的金句一关 app
/// 就没了。本桥用跟服务卡片同款技术绕开: 自写 `MethodChannel` →
/// `EntryAbility.ets` 用 ArkTS 系统 API `@ohos.data.preferences` 真落盘。
///
/// 工作方式 (全量快照, 简单可靠):
/// - 启动: [loadSnapshot] 经 channel 读回整份 prefs 快照 → 喂给
///   `setMockInitialValues`, 内存 prefs 一开始就带着上次的数据;
/// - 写后: 仓储 save 完调 [flush], 把当前所有 prefs 键值**带类型**序列化推回
///   ArkTS 落盘。
///
/// 安全: 只有 [loadSnapshot] 成功过 ([_loaded]=true) 才允许 [flush], 避免
/// channel 未就绪时把空数据覆盖掉已落盘的真实数据。非鸿蒙平台全 no-op。
class OhosPrefsBridge {
  OhosPrefsBridge._();

  static final OhosPrefsBridge instance = OhosPrefsBridge._();

  static const String _channelName = 'app.folio/ohos_store';
  static const MethodChannel _channel = MethodChannel(_channelName);

  bool _loaded = false;

  bool get _supported => PlatformCapabilities.isOhos;

  /// 启动时读回上次落盘的 prefs 快照, 解析成 `setMockInitialValues` 能吃的
  /// `Map<String, Object>`。读不到 / 解析失败返回空 map (但**不**置 [_loaded],
  /// 这样 channel 没就绪时不会触发 flush 覆盖真实数据)。
  Future<Map<String, Object>> loadSnapshot() async {
    if (!_supported) return <String, Object>{};
    // channel handler 在 EntryAbility 注册, 启动早期偶发未就绪 → 小重试。
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        final String json =
            await _channel.invokeMethod<String>('loadPrefs') ?? '';
        _loaded = true;
        if (json.isEmpty) return <String, Object>{};
        return _decode(json);
      } on MissingPluginException {
        await Future<void>.delayed(const Duration(milliseconds: 120));
      } catch (e, st) {
        AppLogger.instance.handle(e, st, 'ohos prefs load failed');
        return <String, Object>{};
      }
    }
    AppLogger.instance.warning(
      'ohos prefs channel not ready after retries; persistence disabled '
      'this session (existing on-disk data kept intact)',
    );
    return <String, Object>{};
  }

  /// 把当前所有 prefs 键值带类型序列化推回 ArkTS 落盘。
  /// 仓储 save 完成后调用 (写后, 保证快照含最新数据)。
  Future<void> flush(SharedPreferences prefs) async {
    if (!_supported || !_loaded) return;
    try {
      final String json = _encode(prefs);
      await _channel.invokeMethod<void>('savePrefs', <String, String>{
        'data': json,
      });
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'ohos prefs flush failed');
    }
  }

  String _encode(SharedPreferences prefs) {
    final Map<String, Object> values = <String, Object>{};
    for (final String key in prefs.getKeys()) {
      final Object? v = prefs.get(key);
      if (v != null) values[key] = v;
    }
    return encodeSnapshot(values);
  }

  Map<String, Object> _decode(String json) => decodeSnapshot(json);

  /// 带类型快照: `{key: {"t": "s|b|i|d|sl", "v": value}}`。
  /// 类型标签让 JSON 往返不丢 bool/int/List&lt;String&gt; (favorites)。
  /// 纯函数 + static, 便于单测往返保真 (数据安全的关键不变量)。
  static String encodeSnapshot(Map<String, Object> values) {
    final Map<String, Object> out = <String, Object>{};
    values.forEach((String key, Object v) {
      if (v is bool) {
        out[key] = <String, Object>{'t': 'b', 'v': v};
      } else if (v is int) {
        out[key] = <String, Object>{'t': 'i', 'v': v};
      } else if (v is double) {
        out[key] = <String, Object>{'t': 'd', 'v': v};
      } else if (v is String) {
        out[key] = <String, Object>{'t': 's', 'v': v};
      } else if (v is List) {
        out[key] = <String, Object>{'t': 'sl', 'v': v.cast<String>()};
      }
    });
    return jsonEncode(out);
  }

  static Map<String, Object> decodeSnapshot(String json) {
    if (json.isEmpty) return <String, Object>{};
    Object? decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      // 落盘数据损坏 → 当作空, 绝不让坏数据炸掉启动 (宁可丢也不崩)。
      return <String, Object>{};
    }
    if (decoded is! Map) return <String, Object>{};
    final Map<String, Object> out = <String, Object>{};
    decoded.forEach((Object? key, Object? env) {
      if (key is! String || env is! Map) return;
      final Object? t = env['t'];
      final Object? v = env['v'];
      if (v == null) return;
      switch (t) {
        case 'b':
          if (v is bool) out[key] = v;
          break;
        case 'i':
          if (v is int) out[key] = v;
          break;
        case 'd':
          if (v is num) out[key] = v.toDouble();
          break;
        case 's':
          if (v is String) out[key] = v;
          break;
        case 'sl':
          if (v is List) out[key] = v.cast<String>();
          break;
        default:
          break;
      }
    });
    return out;
  }
}
