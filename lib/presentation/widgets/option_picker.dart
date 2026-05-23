import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// 一项可选项 + 显示标签。用 record 避免引入新类。
typedef PickerOption<T> = ({T value, String label});

/// 通用单选 BottomSheet —— 一组 ListTile, 当前选中带 ✓, 点完返回值。
///
/// settings 屏多处选项 (主题 / cadence / 字号 / 字体) 都长这样,
/// 抽到这里。返回 `null` 表示用户没选 (e.g. 点屏幕外关闭)。
Future<T?> showOptionPicker<T>({
  required BuildContext context,
  required List<PickerOption<T>> options,
  required T current,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final PickerOption<T> opt in options)
              ListTile(
                title: Text(
                  opt.label,
                  style: const TextStyle(fontFamily: XJKTokens.serifDisplay),
                ),
                trailing: current == opt.value ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(opt.value),
              ),
          ],
        ),
      );
    },
  );
}
