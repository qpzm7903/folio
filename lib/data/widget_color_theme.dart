/// 桌面小组件的配色预设 (Issue #6 子任务 4 v0.15.7 起)。
///
/// 三个预设跟 skill `colors_and_type.css` 的色板对齐:
/// - [paper] 青纸: bgRaised + border1, 白底浅边
/// - [night] 林夜: leaf700 → darkQuoteBg 135° 渐变, 深绿色底
/// - [bamboo] 翠竹: bamboo500 soft, 暖黄色底
///
/// 持久化 key 用 `name` (paper / night / bamboo), 反序列化时未知值
/// fallback 到 [paper]。
enum WidgetColorTheme {
  paper,
  night,
  bamboo;

  /// 用户可见的色卡标签。
  String get displayLabel {
    switch (this) {
      case WidgetColorTheme.paper:
        return '青纸';
      case WidgetColorTheme.night:
        return '林夜';
      case WidgetColorTheme.bamboo:
        return '翠竹';
    }
  }

  /// 副标题 (英文小字)。
  String get displaySub {
    switch (this) {
      case WidgetColorTheme.paper:
        return 'Paper · 浅底';
      case WidgetColorTheme.night:
        return 'Night · 深绿';
      case WidgetColorTheme.bamboo:
        return 'Bamboo · 暖黄';
    }
  }
}
