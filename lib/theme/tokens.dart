import 'package:flutter/material.dart';

import 'xjk_theme_id.dart';

/// XJK design tokens —— 与 `.claude/skills/xiao-jinku-desig/colors_and_type.css`
/// 一一对应。两个主题: 青纸 Paper (light) / 林夜 Night (dark)。
///
/// 命名规则:
/// - 原始色板用 `paper50/100/200…`、`ink900/700…`、`leaf500…` 等
/// - 语义层用 `bgPage`、`fgOnAccent`、`accent` 等 (UI 组件应该引用语义层)
///
/// 切换主题靠 `XJKTokens.paper()` / `XJKTokens.night()` 工厂方法。
@immutable
class XJKTokens {
  // ===== 原始色板 =====
  final Color paper50;
  final Color paper100;
  final Color paper200;
  final Color paper300;
  final Color paper400;

  final Color ink900;
  final Color ink700;
  final Color ink500;
  final Color ink300;

  final Color leaf300;
  final Color leaf500;
  final Color leaf700;

  final Color jade300;
  final Color jade500;
  final Color jade700;

  final Color bamboo500;
  final Color bamboo700;

  // ===== 语义层 =====
  final Color bgPage;
  final Color bgSurface;
  final Color bgCard;
  final Color bgRaised;
  final Color bgOverlay;

  final Color fg1;
  final Color fg2;
  final Color fg3;
  final Color fgMuted;
  final Color fgOnAccent;

  final Color accent;
  final Color accentPressed;
  final Color accentSoft;
  final Color accent2;
  final Color mark;

  final Color border1;
  final Color border2;
  final Color divider;

  final Color success;
  final Color warning;
  final Color danger;

  // ===== Typography family names =====
  static const String serifDisplay = 'NotoSerifSC';
  static const String serifItalic = 'EBGaramond';
  static const String sansUi = 'NotoSansSC';

  // ===== Font sizes =====
  static const double fsQuoteHero = 44;
  static const double fsQuote = 28;
  static const double fsH1 = 26;
  static const double fsH2 = 20;
  static const double fsH3 = 17;
  static const double fsBody = 15;
  static const double fsSmall = 13;
  static const double fsLabel = 11;

  // ===== Letter spacing =====
  static const double trackingTight =
      -0.02 * fsH1; // approximation in logical px
  static const double trackingNormal = 0;
  static const double trackingWide = 0.08 * fsBody;
  static const double trackingLabel = 0.16 * fsLabel;

  // ===== Line height multipliers =====
  static const double leadingTight = 1.15;
  static const double leadingSnug = 1.35;
  static const double leadingNormal = 1.55;
  static const double leadingLoose = 1.8;

  // ===== Spacing scale (4-based) =====
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  static const double space20 = 80;

  // ===== Radii =====
  static const double radiusXs = 2;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 14;
  static const double radiusXl = 22;
  static const double radiusPill = 999;

  // ===== Motion =====
  static const Duration durFast = Duration(milliseconds: 160);
  static const Duration durBase = Duration(milliseconds: 240);
  static const Duration durSlow = Duration(milliseconds: 480);
  static const Duration durPage = Duration(milliseconds: 640);

  static const Curve easePaper = Cubic(0.4, 0, 0.2, 1);

  const XJKTokens._({
    required this.paper50,
    required this.paper100,
    required this.paper200,
    required this.paper300,
    required this.paper400,
    required this.ink900,
    required this.ink700,
    required this.ink500,
    required this.ink300,
    required this.leaf300,
    required this.leaf500,
    required this.leaf700,
    required this.jade300,
    required this.jade500,
    required this.jade700,
    required this.bamboo500,
    required this.bamboo700,
    required this.bgPage,
    required this.bgSurface,
    required this.bgCard,
    required this.bgRaised,
    required this.bgOverlay,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.fgMuted,
    required this.fgOnAccent,
    required this.accent,
    required this.accentPressed,
    required this.accentSoft,
    required this.accent2,
    required this.mark,
    required this.border1,
    required this.border2,
    required this.divider,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// 青纸 · Tea Paper — 默认 light 主题
  factory XJKTokens.paper() {
    const paper50 = Color(0xFFF7F8ED);
    const paper100 = Color(0xFFEEF0DF);
    const paper200 = Color(0xFFE2E6CF);
    const paper300 = Color(0xFFCDD4B6);
    const paper400 = Color(0xFFA8B58C);

    const ink900 = Color(0xFF1D2A1F);
    const ink700 = Color(0xFF324638);
    const ink500 = Color(0xFF5E7263);
    const ink300 = Color(0xFF91A290);

    const leaf300 = Color(0xFFC4D5A8);
    const leaf500 = Color(0xFF7BA05B);
    const leaf700 = Color(0xFF4A6B35);

    const jade300 = Color(0xFFC2D8D5);
    const jade500 = Color(0xFF7EA8A3);
    const jade700 = Color(0xFF4A6E6A);

    const bamboo500 = Color(0xFFB8A866);
    const bamboo700 = Color(0xFF8A7C45);

    return const XJKTokens._(
      paper50: paper50,
      paper100: paper100,
      paper200: paper200,
      paper300: paper300,
      paper400: paper400,
      ink900: ink900,
      ink700: ink700,
      ink500: ink500,
      ink300: ink300,
      leaf300: leaf300,
      leaf500: leaf500,
      leaf700: leaf700,
      jade300: jade300,
      jade500: jade500,
      jade700: jade700,
      bamboo500: bamboo500,
      bamboo700: bamboo700,
      bgPage: paper100,
      bgSurface: paper50,
      bgCard: paper200,
      bgRaised: Color(0xFFFBFCF3),
      bgOverlay: Color(0x8C1D2A1F), // rgba(29,42,31,0.55)
      fg1: ink900,
      fg2: ink700,
      fg3: ink500,
      fgMuted: ink300,
      fgOnAccent: paper50,
      accent: leaf500,
      accentPressed: leaf700,
      accentSoft: leaf300,
      accent2: jade500,
      mark: bamboo500,
      border1: paper300,
      border2: paper400,
      divider: Color(0x141D2A1F), // rgba(29,42,31,0.08)
      success: Color(0xFF4A6B35),
      warning: Color(0xFFB8A866),
      danger: Color(0xFFA04030),
    );
  }

  /// 林夜 · Forest Night — dark 主题
  factory XJKTokens.night() {
    const paper50 = Color(0xFF1A2520);
    const paper100 = Color(0xFF0E1612);
    const paper200 = Color(0xFF182218);
    const paper300 = Color(0xFF243024);
    const paper400 = Color(0xFF34452E);

    const ink900 = Color(0xFFE6EBD9);
    const ink700 = Color(0xFFC0C9A9);
    const ink500 = Color(0xFF8A9A82);
    const ink300 = Color(0xFF5E6E57);

    const leaf300 = Color(0xFF5E7E48);
    const leaf500 = Color(0xFF9EC88A);
    const leaf700 = Color(0xFFB9D49D);

    const jade300 = Color(0xFF4A6E6A);
    const jade500 = Color(0xFF87AAA6);
    const jade700 = Color(0xFFB0D2CC);

    const bamboo500 = Color(0xFFD4C47E);
    const bamboo700 = Color(0xFFB8A866);

    return const XJKTokens._(
      paper50: paper50,
      paper100: paper100,
      paper200: paper200,
      paper300: paper300,
      paper400: paper400,
      ink900: ink900,
      ink700: ink700,
      ink500: ink500,
      ink300: ink300,
      leaf300: leaf300,
      leaf500: leaf500,
      leaf700: leaf700,
      jade300: jade300,
      jade500: jade500,
      jade700: jade700,
      bamboo500: bamboo500,
      bamboo700: bamboo700,
      bgPage: paper100,
      bgSurface: paper200,
      bgCard: paper200,
      bgRaised: Color(0xFF1F2A1F),
      bgOverlay: Color(0xB3000000), // rgba(0,0,0,0.7)
      fg1: ink900,
      fg2: ink700,
      fg3: ink500,
      fgMuted: ink300,
      fgOnAccent: paper100,
      accent: leaf500,
      accentPressed: leaf700,
      accentSoft: Color(0x299EC88A), // rgba(158,200,138,0.16)
      accent2: jade500,
      mark: bamboo500,
      border1: paper300,
      border2: paper400,
      divider: Color(0x14E6EBD9), // rgba(230,235,217,0.08)
      success: Color(0xFF9EC88A),
      warning: Color(0xFFD4C47E),
      danger: Color(0xFFD58A7A),
    );
  }

  /// 按主题标识查表取 tokens —— 注册表的单一可信源。
  ///
  /// v0.18.2 只有 paper / night; 新增主题时在此补一个 case。
  factory XJKTokens.forId(XJKThemeId id) {
    switch (id) {
      case XJKThemeId.paper:
        return XJKTokens.paper();
      case XJKThemeId.night:
        return XJKTokens.night();
    }
  }

  /// 卡片软阴影 (绿调低扩散)
  List<BoxShadow> get shadow1 => <BoxShadow>[
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  List<BoxShadow> get shadow2 => <BoxShadow>[
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.05),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  List<BoxShadow> get shadow3 => <BoxShadow>[
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.10),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ];

  Color get _shadowTint => ink900;
}

/// 通过 [InheritedWidget] 让 XJKTokens 全局可用。
class XJKTheme extends InheritedWidget {
  const XJKTheme({required this.tokens, required super.child, super.key});

  final XJKTokens tokens;

  static XJKTokens of(BuildContext context) {
    final XJKTheme? widget =
        context.dependOnInheritedWidgetOfExactType<XJKTheme>();
    assert(widget != null, 'XJKTheme not found above this widget');
    return widget!.tokens;
  }

  @override
  bool updateShouldNotify(XJKTheme oldWidget) => tokens != oldWidget.tokens;
}
