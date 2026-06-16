import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/settings_repository.dart';
import 'package:folio/presentation/providers.dart';
import 'package:folio/theme/tokens.dart';
import 'package:folio/theme/xjk_theme_id.dart';

void main() {
  group('XJKThemeId 注册表', () {
    test('每个主题都有非空标签 + 可取 tokens', () {
      for (final XJKThemeId id in XJKThemeId.values) {
        expect(id.nameZh, isNotEmpty, reason: '$id 中文名');
        expect(id.nameEn, isNotEmpty, reason: '$id 英文名');
        expect(id.label, contains('·'), reason: '$id 标签形如 中文 · En');
        expect(id.tokens, isA<XJKTokens>(), reason: '$id 必须能查到 tokens');
      }
    });

    test('亮暗默认对正确 (跟随系统用)', () {
      expect(XJKThemeId.lightDefault.isDark, isFalse);
      expect(XJKThemeId.darkDefault.isDark, isTrue);
      expect(XJKThemeId.lightDefault, XJKThemeId.paper);
      expect(XJKThemeId.darkDefault, XJKThemeId.night);
    });

    test('v0.18.2 只注册 paper / night (扩展前的基线)', () {
      expect(XJKThemeId.values, <XJKThemeId>[
        XJKThemeId.paper,
        XJKThemeId.night,
      ]);
    });
  });

  group('XJKTokens.forId 单一可信源', () {
    test('forId 与旧工厂逐一对应 (值不漂移)', () {
      // const 工厂规范化 → 同实参得同一 const 实例, identical 即逐字段相等。
      expect(
        identical(XJKTokens.forId(XJKThemeId.paper), XJKTokens.paper()),
        isTrue,
      );
      expect(
        identical(XJKTokens.forId(XJKThemeId.night), XJKTokens.night()),
        isTrue,
      );
    });

    test('paper 是浅底深字, night 是深底浅字 (亮暗合理)', () {
      final XJKTokens paper = XJKTokens.forId(XJKThemeId.paper);
      final XJKTokens night = XJKTokens.forId(XJKThemeId.night);
      // 粗略亮度: 浅主题页底比文字亮; 暗主题相反。
      expect(paper.bgPage.computeLuminance(),
          greaterThan(paper.fg1.computeLuminance()));
      expect(night.bgPage.computeLuminance(),
          lessThan(night.fg1.computeLuminance()));
    });
  });

  group('AppThemeMode.themeId 映射', () {
    test('system → null, paper/night → 对应 id', () {
      expect(AppThemeMode.system.themeId, isNull);
      expect(AppThemeMode.paper.themeId, XJKThemeId.paper);
      expect(AppThemeMode.night.themeId, XJKThemeId.night);
    });
  });

  group('resolveIsDark 行为等价 (重构基线)', () {
    test('paper 永远浅, night 永远暗 (忽略平台亮度)', () {
      for (final Brightness platform in Brightness.values) {
        expect(resolveIsDark(AppThemeMode.paper, platform), isFalse);
        expect(resolveIsDark(AppThemeMode.night, platform), isTrue);
      }
    });

    test('system 跟随平台亮度', () {
      expect(resolveIsDark(AppThemeMode.system, Brightness.light), isFalse);
      expect(resolveIsDark(AppThemeMode.system, Brightness.dark), isTrue);
    });
  });
}
