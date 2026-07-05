import 'dart:convert';

import '../core/logger.dart';
import 'quote.dart';

/// Quote 列表 ↔ JSON 字符串 的双向编解码。
///
/// 这一层独立出来 (而不是塞在 [QuoteRepository] 子类里),
/// 是为了让 File 与 SharedPreferences 两个仓储都能复用同一段格式逻辑,
/// 减少不一致迁移 (例如 v0.2 切到 drift 时, 只要换一处 codec)。
class QuoteCodec {
  const QuoteCodec._();

  static String encode(List<Quote> quotes) {
    return jsonEncode(<Map<String, dynamic>>[
      for (final Quote q in quotes) q.toJson(),
    ]);
  }

  /// 纯文本导出 (v0.28.0, 设计源「备份为 .txt」): 每行一句, 只含句子内容
  /// (不带标签/日期, 有损但可读), 可直接被批量导入按行吃回。
  static String encodePlainText(List<Quote> quotes) {
    return <String>[for (final Quote q in quotes) q.text].join('\n');
  }

  /// 解码失败时记日志并返回 `null`, 上层据此走 fallback (例如重新种子化)。
  static List<Quote>? tryDecode(String raw, {String? context}) {
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return <Quote>[
        for (final dynamic e in data) Quote.fromJson(e as Map<String, dynamic>),
      ];
    } catch (e, st) {
      AppLogger.instance.handle(
        e,
        st,
        context ?? 'QuoteCodec.tryDecode failed',
      );
      return null;
    }
  }
}
