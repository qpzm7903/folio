import 'package:flutter/material.dart';

import 'tokens.dart';

/// 把 XJKTokens 包成 Flutter [ThemeData]。
///
/// 默认按钮、文本、AppBar 颜色都基于 tokens 的语义层，
/// 屏幕组件可以直接用 [XJKTheme.of(context)] 拿到 tokens。
ThemeData buildThemeData(XJKTokens t, {required Brightness brightness}) {
  final ColorScheme scheme = (brightness == Brightness.dark
          ? const ColorScheme.dark()
          : const ColorScheme.light())
      .copyWith(
    brightness: brightness,
    primary: t.accent,
    onPrimary: t.fgOnAccent,
    secondary: t.accent2,
    onSecondary: t.fgOnAccent,
    surface: t.bgSurface,
    onSurface: t.fg1,
    error: t.danger,
    onError: t.fgOnAccent,
    outline: t.border1,
    outlineVariant: t.divider,
  );

  final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsQuoteHero,
      height: XJKTokens.leadingLoose,
      color: t.fg1,
    ),
    displayMedium: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsQuote,
      height: XJKTokens.leadingLoose,
      color: t.fg1,
    ),
    headlineLarge: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsH1,
      fontWeight: FontWeight.w600,
      height: XJKTokens.leadingTight,
      color: t.fg1,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsH2,
      fontWeight: FontWeight.w500,
      height: XJKTokens.leadingSnug,
      color: t.fg1,
    ),
    headlineSmall: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsH3,
      fontWeight: FontWeight.w500,
      height: XJKTokens.leadingSnug,
      color: t.fg1,
    ),
    bodyLarge: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsBody,
      height: XJKTokens.leadingNormal,
      color: t.fg2,
    ),
    bodyMedium: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsBody,
      height: XJKTokens.leadingNormal,
      color: t.fg2,
    ),
    bodySmall: TextStyle(
      fontFamily: XJKTokens.serifDisplay,
      fontSize: XJKTokens.fsSmall,
      height: XJKTokens.leadingNormal,
      color: t.fg3,
    ),
    labelLarge: TextStyle(
      fontFamily: XJKTokens.sansUi,
      fontSize: XJKTokens.fsLabel,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.76,
      color: t.fg3,
    ),
    labelMedium: TextStyle(
      fontFamily: XJKTokens.sansUi,
      fontSize: XJKTokens.fsLabel,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      color: t.fg3,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.bgPage,
    canvasColor: t.bgPage,
    fontFamily: XJKTokens.serifDisplay,
    textTheme: textTheme,
    visualDensity: VisualDensity.compact,
    splashFactory: NoSplash.splashFactory, // 不要 Material ripple
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: t.bgPage,
      surfaceTintColor: Colors.transparent,
      foregroundColor: t.fg1,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: t.divider, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: t.fg2, size: 20),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: t.fgOnAccent,
        textStyle: const TextStyle(
          fontFamily: XJKTokens.sansUi,
          fontSize: XJKTokens.fsBody,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(XJKTokens.radiusMd),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.fg2,
        textStyle: const TextStyle(
          fontFamily: XJKTokens.sansUi,
          fontSize: XJKTokens.fsBody,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.bgRaised,
      hintStyle: TextStyle(
        color: t.fgMuted,
        fontFamily: XJKTokens.serifDisplay,
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
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.bgRaised,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: t.bgRaised,
      // 桌面/Web 上限宽 640px (skill README.md:169), 手机宽度自然不到这个值。
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(XJKTokens.radiusXl),
        ),
      ),
    ),
  );
}
