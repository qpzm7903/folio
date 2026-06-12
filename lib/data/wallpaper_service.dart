import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/logger.dart';
import '../core/platform_capabilities.dart';

/// Issue #8 (v0.15.9): 把屏保画面设为 Android 系统壁纸。
///
/// native 侧通过 `MainActivity.kt` 的 `WallpaperManager.setBitmap`,
/// 跟 Flutter Dart 之间走 MethodChannel `app.folio/wallpaper`。
/// 不引入新 plugin (v0.14.1 教训), 自己写 platform channel 最稳。
///
/// iOS / Web / Desktop 上 [isSupported] 是 false, UI 入口需自行隐藏。
class WallpaperService {
  const WallpaperService();

  static const String _channelName = 'app.folio/wallpaper';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// 当前平台是否能设系统壁纸。
  bool get isSupported => PlatformCapabilities.supportsSetWallpaper;

  /// 把 [boundary] 渲染成 PNG, 保存到临时目录, 通过 channel 让 native
  /// 调 `WallpaperManager.setBitmap` 设为系统 + 锁屏壁纸。
  ///
  /// 返回 `true` 表示成功; 失败时 throw 让调用方 SnackBar 显示原因。
  Future<bool> setWallpaperFromBoundary(RenderRepaintBoundary boundary) async {
    if (!isSupported) {
      throw const WallpaperUnsupportedException();
    }
    final File png = await _renderBoundaryToFile(boundary);
    try {
      final bool ok = await _channel.invokeMethod<bool>(
            'setWallpaperFromFile',
            <String, Object>{'path': png.path},
          ) ??
          false;
      AppLogger.instance.info('wallpaper set ok=$ok path=${png.path}');
      return ok;
    } on PlatformException catch (e, st) {
      AppLogger.instance.handle(e, st, 'wallpaper channel platformException');
      throw WallpaperFailedException(e.message ?? e.code);
    } finally {
      // 不删 png — Android setBitmap 是 async 复制到系统目录, 保留一会儿
      // 让用户在 SnackBar 反馈期能从日志路径定位文件。
    }
  }

  /// 把 RepaintBoundary 截图保存到 application support / wallpapers / <ts>.png。
  Future<File> _renderBoundaryToFile(RenderRepaintBoundary boundary) async {
    // pixelRatio 高一点保证设到 1080p+ 屏幕不糊; 屏保大小通常 < 1440px,
    // 用 2.5 倍密度对手机壁纸够清晰。
    final ui.Image img = await boundary.toImage(pixelRatio: 2.5);
    final ByteData? bytes = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    img.dispose();
    if (bytes == null) {
      throw const WallpaperFailedException('toByteData returned null');
    }
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory('${base.path}/wallpapers');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final String ts = DateTime.now().millisecondsSinceEpoch.toString();
    final File f = File('${dir.path}/quote-$ts.png');
    await f.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return f;
  }
}

class WallpaperUnsupportedException implements Exception {
  const WallpaperUnsupportedException();
  @override
  String toString() => '当前平台不支持设为壁纸 (只有 Android 端可用)';
}

class WallpaperFailedException implements Exception {
  const WallpaperFailedException(this.reason);
  final String reason;
  @override
  String toString() => 'WallpaperFailedException: $reason';
}
