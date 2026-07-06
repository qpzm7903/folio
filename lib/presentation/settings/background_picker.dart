import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/background_image_service.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/snack_text.dart';

/// 弹"换背景 / 取消"操作表 —— 用户选完直接落到 SettingsRepository。
///
/// 调用方负责拿到 [ScaffoldMessengerState] 兜 SnackBar (因为 await 跨 frame,
/// 直接用 BuildContext 会触发 use_build_context_synchronously)。
Future<void> showBackgroundPicker(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final BackgroundImageService svc = ref.read(backgroundImageServiceProvider);
  if (!svc.isSupported) return;
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  final _BgAction? action = await showModalBottomSheet<_BgAction>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext _) =>
        _BackgroundActionSheet(hasCustom: current != null),
  );
  if (action == null) return;

  switch (action) {
    case _BgAction.pick:
      final String? path = await svc.pickAndStore();
      if (path == null) return;
      await ref.read(settingsProvider.notifier).setBackgroundImagePath(path);
      messenger.showText('背景图已换上。');
    case _BgAction.clear:
      await svc.clearStored(current);
      await ref.read(settingsProvider.notifier).setBackgroundImagePath(null);
      messenger.showText('已经回到默认背景。');
  }
}

/// sub-label 文案: 跟当前平台 / 状态自适应。Settings 屏复用。
String backgroundSubLabel(WidgetRef ref, String? path) {
  if (!ref.read(backgroundImageServiceProvider).isSupported) {
    return 'Web 暂不支持自定义';
  }
  if (path == null) return '深绿渐变 / 纸纹叠加';
  return '从相册或文件选';
}

enum _BgAction { pick, clear }

class _BackgroundActionSheet extends StatelessWidget {
  const _BackgroundActionSheet({required this.hasCustom});
  final bool hasCustom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text(
              '从相册或文件选一张',
              style: TextStyle(fontFamily: XJKTokens.serifDisplay),
            ),
            onTap: () => Navigator.of(context).pop(_BgAction.pick),
          ),
          if (hasCustom)
            ListTile(
              title: const Text(
                '回到默认背景',
                style: TextStyle(fontFamily: XJKTokens.serifDisplay),
              ),
              onTap: () => Navigator.of(context).pop(_BgAction.clear),
            ),
        ],
      ),
    );
  }
}
