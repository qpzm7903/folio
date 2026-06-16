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
/// 按 skill `display-layouts.jsx` 实现; 注册表与具体版式见
/// `display_layouts.dart`。新增版式只需实现本接口并加进 `kDisplayLayouts`。
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

/// 句长分级 —— 中文字数决定字号乘子, 短句放大、长句缩小以总能放下。
/// 阈值与乘子对照 skill kit.css 的 `.ds-layout[data-len="…"]`。
enum QuoteLengthTier { tiny, short, medium, long, xlong }

/// 按中文字符数 (含标点) 取分级。
QuoteLengthTier lengthTier(String text) {
  final int n = text.runes.length;
  if (n <= 10) return QuoteLengthTier.tiny;
  if (n <= 18) return QuoteLengthTier.short;
  if (n <= 30) return QuoteLengthTier.medium;
  if (n <= 46) return QuoteLengthTier.long;
  return QuoteLengthTier.xlong;
}

/// 字号乘子 (`--q-scale`): tiny 1.15 / short 1.0 / medium 0.82 /
/// long 0.64 / xlong 0.5。版式字号 = 基准 × 此乘子。
double qScale(String text) {
  switch (lengthTier(text)) {
    case QuoteLengthTier.tiny:
      return 1.15;
    case QuoteLengthTier.short:
      return 1.0;
    case QuoteLengthTier.medium:
      return 0.82;
    case QuoteLengthTier.long:
      return 0.64;
    case QuoteLengthTier.xlong:
      return 0.5;
  }
}

/// 黄金比竖向锚点 —— 把 [child] 夹在 0.382 : 0.618 的上下留白之间, 使其
/// 落在上黄金线 (≈38.2%), 比死居中更"有章法"。长内容填满时优雅退化。
/// 对照 skill README「黄金比」一节: 两个 `Spacer(flex: 382/618)`。
Widget goldenAnchor(Widget child) {
  // 中间放自然尺寸的 child (非 flex), 两侧 Spacer 按 382:618 分配剩余留白,
  // 使 child 落在上黄金线。child 不能用 Flexible, 否则会与 Spacer 抢 flex
  // 把内容挤成 0 高度 → 溢出。长内容自然变高时上下留白自动收窄。
  return Column(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      const Spacer(flex: 382),
      child,
      const Spacer(flex: 618),
    ],
  );
}
