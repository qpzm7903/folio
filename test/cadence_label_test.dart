import 'package:flutter_test/flutter_test.dart';
import 'package:folio/presentation/settings/cadence_wheel_sheet.dart';

void main() {
  group('formatCadenceText (滚轮预览大字)', () {
    test('0 分钟显示 "请选择"', () {
      expect(formatCadenceText(0), '请选择');
      expect(formatCadenceText(-5), '请选择');
    });

    test('小于 60 分钟显示纯分钟', () {
      expect(formatCadenceText(1), '每 1 分钟换一句');
      expect(formatCadenceText(15), '每 15 分钟换一句');
      expect(formatCadenceText(59), '每 59 分钟换一句');
    });

    test('整小时显示纯小时, 不带 0 分', () {
      expect(formatCadenceText(60), '每 1 小时换一句');
      expect(formatCadenceText(120), '每 2 小时换一句');
      expect(formatCadenceText(720), '每 12 小时换一句');
    });

    test('混合小时 + 分钟', () {
      expect(formatCadenceText(75), '每 1 小时 15 分钟换一句');
      expect(formatCadenceText(150), '每 2 小时 30 分钟换一句');
    });

    test('1440 分钟显示 "每日一句" (设计源 CADENCES, v0.29.0)', () {
      expect(formatCadenceText(1440), '每日一句');
      // 1440 附近不受特例影响
      expect(formatCadenceText(1380), '每 23 小时换一句');
    });
  });

  group('formatCadenceShort (SettingRow value 列)', () {
    test('小于 60 分钟显示纯分钟', () {
      expect(formatCadenceShort(1), '1 分钟');
      expect(formatCadenceShort(30), '30 分钟');
    });

    test('整小时显示纯小时', () {
      expect(formatCadenceShort(60), '1 小时');
      expect(formatCadenceShort(240), '4 小时');
    });

    test('混合小时 + 分钟用短文案', () {
      expect(formatCadenceShort(75), '1 小时 15 分');
      expect(formatCadenceShort(125), '2 小时 5 分');
    });

    test('1440 分钟显示 "每日" (v0.29.0)', () {
      expect(formatCadenceShort(1440), '每日');
      expect(formatCadenceShort(720), '12 小时');
    });
  });
}
