import 'package:flutter/material.dart';

/// `showSnackBar(SnackBar(content: Text(x)))` 的全仓样板收敛。
///
/// 只收敛"提示这一行": 各调用点在 await 前捕获 messenger、挂载检查、
/// 是否 pop 等流程差异保持原样。
extension XJKSnackText on ScaffoldMessengerState {
  /// [duration] 不传时保留 [SnackBar] 的框架默认时长 (不在这里复刻其数值)。
  void showText(String text, {Duration? duration}) {
    showSnackBar(
      duration == null
          ? SnackBar(content: Text(text))
          : SnackBar(content: Text(text), duration: duration),
    );
  }
}
