import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger.dart';
import '../../data/quote.dart';
import '../../data/quote_codec.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';

/// 导出金库 —— 打开 BottomSheet 显示 JSON, 顶部一键复制到剪贴板。
///
/// 文件格式跟 [QuoteCodec.encode] 一致, 之后可粘到 [showImportSheet] 还原。
Future<void> showExportSheet(BuildContext context, WidgetRef ref) async {
  final List<Quote> quotes =
      ref.read(quotesProvider).asData?.value ?? const <Quote>[];
  AppLogger.instance.info('export sheet opened, ${quotes.length} quotes');

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext ctx) => _ExportSheet(
      rawJson: QuoteCodec.encode(quotes),
      rawText: QuoteCodec.encodePlainText(quotes),
      count: quotes.length,
    ),
  );
}

/// 从剪贴板导入 —— 让用户粘贴 JSON, 校验后**合并**进金库 (不覆盖原有)。
///
/// 合并而非替换是有意的: 误粘贴坏数据时, 至少不丢原本的金库。
Future<void> showImportSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext ctx) => const _ImportSheet(),
  );
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.rawJson,
    required this.rawText,
    required this.count,
  });

  final String rawJson;
  final String rawText;
  final int count;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

/// v0.28.0: 完整备份 (JSON, 可无损还原) / 纯文本 (.txt 风格, 每行一句,
/// 可读、可被批量导入吃回, 不含标签与日期) 双格式切换。
class _ExportSheetState extends State<_ExportSheet> {
  bool _plainText = false;

  int get count => widget.count;

  String get _raw => _plainText ? widget.rawText : widget.rawJson;

  String get _help => _plainText
      ? '纯文本每行一句, 直接可读; 也能用「批量导入」粘回 (不含标签与日期)。'
      : '把这 $count 句原样抄出来, 粘到笔记里或另一台设备。';

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + media.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '导出金库',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _help,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 14,
              color: t.fg3,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.bgPage,
              border: Border.all(color: t.border1),
              borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _raw,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.5,
                  color: t.fg2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:
                count == 0 ? null : () => _copyAndClose(context, _raw, count),
            child: const Text('复制到剪贴板'),
          ),
          TextButton(
            onPressed: () => setState(() => _plainText = !_plainText),
            child: Text(
              _plainText ? '改用完整备份 (JSON)' : '改用纯文本 (.txt)',
              style: TextStyle(
                fontFamily: XJKTokens.sansUi,
                fontSize: 14,
                color: t.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyAndClose(
    BuildContext context,
    String raw,
    int count,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: raw));
    AppLogger.instance.info('exported $count quotes to clipboard');
    if (!context.mounted) return;
    unawaited(navigator.maybePop());
    messenger.showSnackBar(SnackBar(content: Text('已复制 $count 句到剪贴板。')));
  }
}

class _ImportSheet extends ConsumerStatefulWidget {
  const _ImportSheet();

  @override
  ConsumerState<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<_ImportSheet> {
  final TextEditingController _text = TextEditingController();
  String? _error;
  int _previewCount = 0;

  @override
  void initState() {
    super.initState();
    // 进屏自动尝试从剪贴板读取, 让用户少一步操作
    _tryPasteFromClipboard();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _tryPasteFromClipboard() async {
    final ClipboardData? clip = await Clipboard.getData(Clipboard.kTextPlain);
    final String? raw = clip?.text;
    if (raw == null || raw.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _text.text = raw;
      _validate();
    });
  }

  void _onChanged(String _) => setState(_validate);

  void _validate() {
    final String raw = _text.text.trim();
    if (raw.isEmpty) {
      _error = null;
      _previewCount = 0;
      return;
    }
    final List<Quote>? decoded = QuoteCodec.tryDecode(
      raw,
      context: 'import sheet preview',
    );
    if (decoded == null) {
      _error = '这段文本不是金库格式 (应该是 JSON 数组)。';
      _previewCount = 0;
    } else {
      _error = null;
      _previewCount = decoded.length;
    }
  }

  Future<void> _import() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<Quote>? decoded = QuoteCodec.tryDecode(_text.text.trim());
    if (decoded == null || decoded.isEmpty) return;
    // 用现有 addMany 把每句"作为新句"合并; tag/text 保留, id 重新生成
    final String failText = AppL10n.of(context).snackSaveFailed;
    final bool ok2 = await ref.read(quotesProvider.notifier).addMany(<String>[
      for (final Quote q in decoded) q.text,
    ]);
    if (!mounted) return;
    if (!ok2) {
      messenger.showSnackBar(SnackBar(content: Text(failText)));
      return; // sheet 不关, 文本还在, 可重试
    }
    AppLogger.instance.info('imported ${decoded.length} quotes');
    unawaited(navigator.maybePop());
    messenger.showSnackBar(
      SnackBar(content: Text('${decoded.length} 句已合并进金库。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final bool canImport = _previewCount > 0 && _error == null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + media.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '从剪贴板导入',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '粘贴之前导出的金库内容, 会合并进现有金库 (不会覆盖)。',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 14,
              color: t.fg3,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: TextField(
              controller: _text,
              maxLines: null,
              expands: true,
              onChanged: _onChanged,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
                color: t.fg1,
              ),
              decoration: InputDecoration(
                hintText:
                    '[{"id":...,"text":"...","tag":"...","createdAt":...}]',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: t.fgMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 13,
                color: t.danger,
              ),
            )
          else if (_previewCount > 0)
            Text(
              '识别到 $_previewCount 句。',
              style: TextStyle(
                fontFamily: XJKTokens.serifItalic,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: t.fg3,
              ),
            ),
          const SizedBox(height: 12),
          Opacity(
            opacity: canImport ? 1 : 0.4,
            child: ElevatedButton(
              onPressed: canImport ? _import : null,
              child: const Text('合并进金库'),
            ),
          ),
        ],
      ),
    );
  }
}
