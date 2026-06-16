import 'tokens.dart';

/// 主题标识 —— 主题注册表的 key。
///
/// 每个 id 对应一套 [XJKTokens] + 元数据 (中文名 / 英文名 / 亮暗)。
/// 把"主题身份"与"亮暗"解耦: 跟随系统时按平台亮度在 [lightDefault] /
/// [darkDefault] 之间取默认对; 显式选定主题时直接用该主题的 [isDark]。
///
/// v0.18.2 (重构 PATCH) 只注册 paper / night 两项, 行为与旧的二元
/// `AppThemeMode {paper, night}` 等价; v0.19.0 起扩展 4 个传统色主题
/// (天青 / 月白 / 绛霞 / 青黛)。新增主题只需在此追加枚举值 + 在
/// [XJKTokens.forId] 补对应 token 工厂。
enum XJKThemeId {
  paper(nameZh: '青纸', nameEn: 'Paper', isDark: false),
  night(nameZh: '林夜', nameEn: 'Forest', isDark: true);

  const XJKThemeId({
    required this.nameZh,
    required this.nameEn,
    required this.isDark,
  });

  /// 中文名 (用户可见, 主标签)。
  final String nameZh;

  /// 英文名 (作 italic Latin 副标签, 对齐 skill components.jsx)。
  final String nameEn;

  /// 是否暗色主题 —— 决定 Flutter [Brightness] 与暗色结构样式。
  final bool isDark;

  /// 设置屏可见标签, 形如 `青纸 · Paper`。
  String get label => '$nameZh · $nameEn';

  /// 该主题的设计 tokens (查表, 单一可信源)。
  XJKTokens get tokens => XJKTokens.forId(this);

  /// 跟随系统时的浅色默认。
  static const XJKThemeId lightDefault = XJKThemeId.paper;

  /// 跟随系统时的暗色默认。
  static const XJKThemeId darkDefault = XJKThemeId.night;
}
