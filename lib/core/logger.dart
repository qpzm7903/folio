import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

/// 全局日志 —— 写到 `getApplicationSupportDirectory()/logs/folio.log`,
/// 方便用户出问题时把日志发过来分析。
class AppLogger {
  AppLogger._();

  static final Talker _talker = Talker(
    settings: TalkerSettings(maxHistoryItems: 500),
  );

  static Talker get instance => _talker;

  static File? _logFile;

  /// 在 main() 里调用一次。Web/不支持 file IO 的平台会自动 fallback 到只打印。
  static Future<void> init() async {
    if (kIsWeb) {
      _talker.info('folio logger initialised (web, console only)');
      return;
    }
    try {
      final Directory supportDir = await getApplicationSupportDirectory();
      final Directory logsDir = Directory('${supportDir.path}/logs');
      if (!logsDir.existsSync()) {
        logsDir.createSync(recursive: true);
      }
      _logFile = File('${logsDir.path}/folio.log');
      _talker.configure(observer: _FileObserver(_logFile!));
      _talker.info('folio logger initialised, path=${_logFile!.path}');
    } catch (e, st) {
      _talker.handle(e, st, 'failed to set up file logger');
    }
  }

  static Future<String?> logFilePath() async {
    if (_logFile != null) return _logFile!.path;
    return null;
  }
}

class _FileObserver extends TalkerObserver {
  _FileObserver(this.file);

  final File file;

  void _append(String line) {
    try {
      file.writeAsStringSync('$line\n', mode: FileMode.append, flush: false);
    } catch (_) {
      // 故意吞掉 —— 写日志失败不能影响主流程
    }
  }

  String _fmt(TalkerData data) {
    final String level = data.logLevel?.name ?? 'log';
    final String time = data.time.toIso8601String();
    return '$time [$level] ${data.generateTextMessage()}';
  }

  @override
  void onLog(TalkerData log) => _append(_fmt(log));

  @override
  void onError(TalkerError err) => _append(_fmt(err));

  @override
  void onException(TalkerException err) => _append(_fmt(err));
}
