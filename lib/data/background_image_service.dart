import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/logger.dart';

/// 自定义背景图的选取与持久化。
///
/// 选好的图会**复制**到 `getApplicationDocumentsDirectory()/backgrounds/`,
/// 而不是直接保留 file_selector 给的临时 path —— 后者在 Android (content://) /
/// iOS (PHPicker) / Web (blob) 上重启后会失效。复制后的路径稳定到 app 卸载。
///
/// Web 不开放: dart:io 不可用; 调用方应该用 [isSupported] 守护 UI。
class BackgroundImageService {
  const BackgroundImageService();

  /// 当前平台是否支持自定义背景图。
  bool get isSupported => !kIsWeb;

  /// 弹文件选择器, 选定后复制到 app doc dir, 返回新路径; 用户取消返回 `null`。
  Future<String?> pickAndStore() async {
    if (!isSupported) return null;
    try {
      const XTypeGroup group = XTypeGroup(
        label: 'images',
        extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      final XFile? picked = await openFile(
        acceptedTypeGroups: <XTypeGroup>[group],
      );
      if (picked == null) return null;

      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory bgDir = Directory('${docs.path}/backgrounds');
      if (!bgDir.existsSync()) bgDir.createSync(recursive: true);

      // 用时间戳避免覆盖, 保留扩展名
      final String ext = _ext(picked.name);
      final String filename = 'bg-${DateTime.now().millisecondsSinceEpoch}$ext';
      final String dest = '${bgDir.path}/$filename';

      // file_selector 在 Android 走 SAF, 不一定能直接读 path; 用 bytes 兜底
      final List<int> bytes = await picked.readAsBytes();
      await File(dest).writeAsBytes(bytes, flush: true);

      // 顺手清掉同目录之前留下的旧图, 避免 app 占用越来越大
      await _purgeOlder(bgDir, keep: dest);

      AppLogger.instance.info('background image stored at $dest');
      return dest;
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'background image pick failed');
      return null;
    }
  }

  /// 删除当前自定义背景图文件 (如果存在)。
  Future<void> clearStored(String? path) async {
    if (path == null || !isSupported) return;
    try {
      final File f = File(path);
      if (f.existsSync()) await f.delete();
      AppLogger.instance.info('background image cleared');
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'background image clear failed');
    }
  }

  String _ext(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot < 0) return '.jpg';
    return name.substring(dot).toLowerCase();
  }

  Future<void> _purgeOlder(Directory dir, {required String keep}) async {
    try {
      for (final FileSystemEntity entity in dir.listSync()) {
        if (entity is File && entity.path != keep) {
          await entity.delete();
        }
      }
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'purge older backgrounds failed');
    }
  }
}
