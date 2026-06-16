/// 桌面小组件 / 鸿蒙服务卡片的"下一句"播放模式 (Issue #11)。
///
/// 决定 [WidgetTimeline] 如何从**整个金库**生成 timeline:
/// - [random]: 整库乱序不重复 (默认 —— 用户反馈"下一句不是随机的");
/// - [sequential]: 按金库原序 (新→旧) 轮播。
enum WidgetPlayMode { random, sequential }

extension WidgetPlayModeLabel on WidgetPlayMode {
  /// 用户可见标签 (设置屏)。
  String get displayLabel {
    switch (this) {
      case WidgetPlayMode.random:
        return '随机';
      case WidgetPlayMode.sequential:
        return '顺序';
    }
  }

  /// 生成 timeline 时是否乱序。
  bool get shuffle => this == WidgetPlayMode.random;
}
