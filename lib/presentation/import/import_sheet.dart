import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';

/// 批量导入 —— 对应 screens.jsx 的 `ImportSheet`.
/// 用 \n 分隔, 自动 trim 空行。
class ImportSheet extends ConsumerStatefulWidget {
  const ImportSheet({super.key});

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  final TextEditingController _text = TextEditingController();
  static const String _placeholder = '你在心里种下的种子，时间会帮它找出口。\n'
      '真正的强大不是没有裂痕，而是光从裂痕里照进来。\n'
      '你不必完美，你只需要真实且完整地活着。';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  List<String> _splitLines() {
    return _text.text
        .split(RegExp(r'\n+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final List<String> lines = _splitLines();
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: 24 + media.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '批量导入',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '把一整段话粘进来，会自动分行。',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 14,
              color: t.fg3,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: TextField(
              controller: _text,
              autofocus: true,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 15,
                height: 1.7,
                color: t.fg1,
              ),
              decoration: InputDecoration(
                hintText: _placeholder,
                hintStyle: TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  fontSize: 14,
                  height: 1.7,
                  color: t.fgMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
                  borderSide: BorderSide(color: t.border1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
                  borderSide: BorderSide(color: t.border1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
                  borderSide: BorderSide(color: t.accent, width: 1.5),
                ),
                filled: true,
                fillColor: t.bgRaised,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                '识别到',
                style: TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  color: t.fg3,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${lines.length}',
                style: TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  fontSize: 24,
                  color: t.fg1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '句',
                  style: TextStyle(
                    fontFamily: XJKTokens.serifDisplay,
                    fontSize: 13,
                    color: t.fg3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: lines.isEmpty ? 0.4 : 1,
            child: ElevatedButton(
              onPressed: lines.isEmpty
                  ? null
                  : () async {
                      // 先把 BuildContext-依赖的对象捕获下来, 再 await,
                      // 避免在 async gap 后再去用 context。
                      final NavigatorState navigator = Navigator.of(context);
                      final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);
                      final String failText =
                          AppL10n.of(context).snackSaveFailed;
                      final int n = lines.length;
                      final bool ok = await ref
                          .read(quotesProvider.notifier)
                          .addMany(lines);
                      if (!mounted) return;
                      if (!ok) {
                        // 落盘失败: 不关 sheet, 粘贴的内容还在, 可重试。
                        messenger.showSnackBar(
                          SnackBar(content: Text(failText)),
                        );
                        return;
                      }
                      unawaited(navigator.maybePop());
                      messenger.showSnackBar(
                        SnackBar(content: Text('$n 句已收入金库。')),
                      );
                    },
              child: const Text('全部收入金库'),
            ),
          ),
        ],
      ),
    );
  }
}
