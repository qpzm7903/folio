import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// "从金库取出这句话？" 二选一确认对话框。
///
/// 返回 `true` 表示用户选择"取出" (即删除); `false`/`null` 表示"留着"或关闭。
/// Library / Search / Editor 三处都用它, 保持口吻与视觉一致。
///
/// 用法:
/// ```dart
/// final ok = await showConfirmDeleteDialog(context);
/// if (ok == true) {
///   await ref.read(quotesProvider.notifier).remove(q.id);
/// }
/// ```
Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  String message = '从金库取出这句话？',
  String? detail,
  String keepLabel = '留着',
  String removeLabel = '取出',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      final XJKTokens t = XJKTheme.of(ctx);
      return AlertDialog(
        backgroundColor: t.bgRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 17,
                color: t.fg1,
              ),
            ),
            if (detail != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                detail,
                style: TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  fontSize: 14,
                  height: 1.6,
                  color: t.fg3,
                ),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(keepLabel, style: TextStyle(color: t.fg2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(removeLabel, style: TextStyle(color: t.danger)),
          ),
        ],
      );
    },
  );
}
