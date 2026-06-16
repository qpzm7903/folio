import 'package:flutter/material.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';

/// 屏保版式渲染所需的一帧数据 (与轮播 / 淡入 / 壁纸 / 收藏等编排逻辑解耦)。
///
/// 版式只负责"把这一句话摆进矩形里", 不关心它从哪来、何时换。
@immutable
class DisplayLayoutData {
  const DisplayLayoutData({
    required this.quote,
    required this.tokens,
    required this.textColor,
    required this.subColor,
    required this.showAttribution,
    required this.onPhoto,
  });

  /// 当前要展示的金句。
  final Quote quote;

  /// 当前主题 tokens。
  final XJKTokens tokens;

  /// 主文字颜色 (photo 模式下为浅色)。
  final Color textColor;

  /// 出处 / 副文字颜色。
  final Color subColor;

  /// 是否显示出处 (来自用户设置)。
  final bool showAttribution;

  /// 是否处于深色照片背景上 (影响某些版式的装饰浓度)。
  final bool onPhoto;
}

/// 屏保版式接口 —— 一个"版式"就是壁纸体验的一页。
///
/// v0.18.2 (重构 PATCH) 只注册 [ClassicCenterLayout] 一项, 视觉与重构前
/// 完全一致; v0.19.0 起按 skill `display-layouts.jsx` 扩展 页/满/印/时/片
/// 等精选版式。新增版式只需实现本接口并加进 [kDisplayLayouts]。
abstract class DisplayLayout {
  const DisplayLayout();

  /// 稳定标识 (持久化 / 测试用)。
  String get key;

  /// 中文名 (layout-pip 主标签)。
  String get nameZh;

  /// 英文名 (layout-pip italic 副标签)。
  String get nameEn;

  /// 把一帧数据渲染成版式 Widget。
  Widget build(DisplayLayoutData data);
}

/// 经典居中版式 —— 重构前的固定屏保版式, 行为基准。
///
/// 居中大字 quote + 可选出处, 由 display_screen 外层套 640ms 交叉淡入。
class ClassicCenterLayout extends DisplayLayout {
  const ClassicCenterLayout();

  @override
  String get key => 'classic';

  @override
  String get nameZh => '居中';

  @override
  String get nameEn => 'Center';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote quote = data.quote;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          quote.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: XJKTokens.fsQuoteHero,
            height: XJKTokens.leadingLoose,
            color: data.textColor,
          ),
        ),
        if (data.showAttribution && quote.tag.isNotEmpty) ...<Widget>[
          const SizedBox(height: 28),
          Text(
            '— ${quote.tag}',
            style: TextStyle(
              fontFamily: XJKTokens.serifItalic,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: data.subColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// 屏保版式注册表 —— display_screen 按下标循环。
///
/// v0.18.2 只有 1 项 (经典居中); v0.19.0 追加精选 5 版式。
const List<DisplayLayout> kDisplayLayouts = <DisplayLayout>[
  ClassicCenterLayout(),
];
