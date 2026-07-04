import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/quote_clauses.dart';

/// v0.25.0 织 (Interleaved) 版式的分句 —— 对照 display-layouts.jsx clauses():
/// 在中文标点处切分且标点留在句段末尾。
void main() {
  group('splitClauses', () {
    test('按中文标点切分, 标点保留在段尾', () {
      expect(
        splitClauses('种子会找到出口，时间知道。'),
        <String>['种子会找到出口，', '时间知道。'],
      );
    });

    test('支持 ，。！？；、 全部六种标点', () {
      expect(
        splitClauses('一、二；三！四？五。'),
        <String>['一、', '二；', '三！', '四？', '五。'],
      );
    });

    test('末尾无标点的余文单独成段', () {
      expect(splitClauses('走得慢，也是走'), <String>['走得慢，', '也是走']);
    });

    test('无任何标点 → 整句一段', () {
      expect(splitClauses('光从裂痕里照进来'), <String>['光从裂痕里照进来']);
    });

    test('空串 → 单元素空段 (与设计源 [q] 回落一致)', () {
      expect(splitClauses(''), <String>['']);
    });
  });
}
