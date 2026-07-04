import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/import_lines.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/xjk_icon.dart';

/// 批量导入 —— 对应 screens.jsx 的 `ImportSheet`。
///
/// v0.24.0 增强 (HANDOFF 第三轮 + 用户需求"导入文本批量建句"):
/// 分句后**去重**, 并给出可勾选的句列表 (默认全选, 点行切换),
/// 只把勾选的句收入金库。
class ImportSheet extends ConsumerStatefulWidget {
  const ImportSheet({super.key});

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  final TextEditingController _text = TextEditingController();

  /// 被用户取消勾选的句 (以去重后的行文本为键)。
  ///
  /// 文本一变就整体清空 (见 onChanged): 勾选状态只属于"当前这批文本",
  /// 否则上一批的取消会残留到重贴的新批次上 (同文本行静默未选),
  /// 违背"默认全选"的承诺, 用户可能没察觉就丢句。
  final Set<String> _dropped = <String>{};

  static const String _placeholder = '你在心里种下的种子，时间会帮它找出口。\n'
      '真正的强大不是没有裂痕，而是光从裂痕里照进来。\n'
      '你不必完美，你只需要真实且完整地活着。';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _toggle(String line) {
    setState(() {
      if (!_dropped.remove(line)) _dropped.add(line);
    });
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final List<String> lines = splitImportLines(_text.text);
    final List<String> selected = <String>[
      for (final String l in lines)
        if (!_dropped.contains(l)) l,
    ];
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: 24 + media.viewInsets.bottom,
      ),
      // 勾选列表出现后内容可能超过小屏可视高度 (尤其键盘弹起时),
      // 包一层滚动避免 RenderFlex overflow。
      child: SingleChildScrollView(
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
              onChanged: (_) => setState(_dropped.clear),
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
          if (lines.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 168),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: lines.length,
                separatorBuilder: (BuildContext _, int __) =>
                    const SizedBox(height: 6),
                itemBuilder: (BuildContext _, int i) {
                  final String line = lines[i];
                  return _ImportLineRow(
                    line: line,
                    picked: !_dropped.contains(line),
                    onTap: () => _toggle(line),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Opacity(
            opacity: selected.isEmpty ? 0.4 : 1,
            child: ElevatedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      // 先把 BuildContext-依赖的对象捕获下来, 再 await,
                      // 避免在 async gap 后再去用 context。
                      final NavigatorState navigator = Navigator.of(context);
                      final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);
                      final String failText =
                          AppL10n.of(context).snackSaveFailed;
                      final int n = selected.length;
                      final bool ok = await ref
                          .read(quotesProvider.notifier)
                          .addMany(selected);
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
              child: Text(
                lines.isEmpty || selected.length == lines.length
                    ? '全部收入金库'
                    : '收入 ${selected.length} 句',
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// 单行可勾选句 —— 圆形勾选框沿用 kit.css `.qcheck` 视觉
/// (22px 圆, 选中 accent 实底 + 13px check), 未勾选行文字压淡。
class _ImportLineRow extends StatelessWidget {
  const _ImportLineRow({
    required this.line,
    required this.picked,
    required this.onTap,
  });

  final String line;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: XJKTokens.durFast,
            curve: XJKTokens.easePaper,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: picked ? t.accent : Colors.transparent,
              border: Border.all(
                color: picked ? t.accent : t.border2,
                width: 1.5,
              ),
            ),
            child: picked
                ? Center(
                    child: XJKIcon('check', size: 13, color: t.fgOnAccent),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 14,
                height: 1.5,
                color: picked ? t.fg1 : t.fg3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
