import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/import_lines.dart';

/// v0.24.0 批量导入增强 —— HANDOFF 第三轮: 分句/去空白/去重。
void main() {
  group('splitImportLines', () {
    test('按换行分句并 trim, 丢空行', () {
      expect(
        splitImportLines('  一句。 \n\n二句。\n   \n三句。'),
        <String>['一句。', '二句。', '三句。'],
      );
    });

    test('连续多个换行只算一个分隔', () {
      expect(splitImportLines('甲\n\n\n乙'), <String>['甲', '乙']);
    });

    test('重复句去重, 保留首次出现顺序', () {
      expect(
        splitImportLines('甲\n乙\n甲\n丙\n乙'),
        <String>['甲', '乙', '丙'],
      );
    });

    test('trim 后相同也算重复', () {
      expect(splitImportLines('甲\n  甲  '), <String>['甲']);
    });

    test('空输入与全空白输入返回空列表', () {
      expect(splitImportLines(''), isEmpty);
      expect(splitImportLines('  \n \n'), isEmpty);
    });
  });
}
