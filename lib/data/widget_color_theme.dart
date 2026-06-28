/// 桌面小组件的配色预设 (Issue #6 子任务 4 v0.15.7 起)。
///
/// 六个预设跟 skill `colors_and_type.css` 的六主题色板一一对齐
/// (v0.21.0 从 3 个扩到 6 个):
/// - [paper] 青纸: 浅茶纸 + 墨绿
/// - [celadon] 天青: 宋瓷青绿
/// - [moonwhite] 月白: 冷月蓝灰
/// - [cinnabar] 绛霞: 朱砂暖霞
/// - [night] 林夜: 深绿夜
/// - [dai] 青黛: 水墨靛夜
///
/// 持久化 key 用 `name` (paper / celadon / …), 反序列化时未知值
/// fallback 到 [paper] (向后兼容旧值 night/bamboo —— bamboo 仍可读出
/// 但不再出现在选择器里, 旧用户设置会 fallback 到 paper)。
enum WidgetColorTheme {
  paper,
  celadon,
  moonwhite,
  cinnabar,
  night,
  dai;

  /// 用户可见的色卡标签 (对照 `XJKThemeId.label`)。
  String get displayLabel {
    switch (this) {
      case WidgetColorTheme.paper:
        return '青纸';
      case WidgetColorTheme.celadon:
        return '天青';
      case WidgetColorTheme.moonwhite:
        return '月白';
      case WidgetColorTheme.cinnabar:
        return '绛霞';
      case WidgetColorTheme.night:
        return '林夜';
      case WidgetColorTheme.dai:
        return '青黛';
    }
  }

  /// 副标题 (英文小字, 对照 `XJKThemeId.en`)。
  String get displaySub {
    switch (this) {
      case WidgetColorTheme.paper:
        return 'Tea Paper · 浅底';
      case WidgetColorTheme.celadon:
        return 'Celadon · 宋瓷青';
      case WidgetColorTheme.moonwhite:
        return 'Moon White · 冷月';
      case WidgetColorTheme.cinnabar:
        return 'Cinnabar · 朱砂暖';
      case WidgetColorTheme.night:
        return 'Forest Night · 深绿夜';
      case WidgetColorTheme.dai:
        return 'Ink Indigo · 水墨夜';
    }
  }

  /// 是否暗色 (卡片背景取深底) —— 对照 `XJKThemeId.isDark`。
  bool get isDark =>
      this == WidgetColorTheme.night || this == WidgetColorTheme.dai;
}
