import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../domain/tag_filter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// 标签横滑条 —— 对应 kit.css 中 `.tag-row` + `.tag` (active)。
///
/// v0.23.0 标签管理: 传入 [onToggleManaging] 后行末出现「✎ 管理 / ✓ 完成」
/// pill (`.tag.manage-tag`); [managing] 为 true 时具名标签变虚线可删
/// (`.tag.removable` + x), 点击走 [onDeleteTag] 而非 [onSelect]。
/// 哨兵「全部 / 未分类」永远不可删, 管理态下仍可正常筛选。
class TagRow extends StatelessWidget {
  const TagRow({
    required this.tags,
    required this.active,
    required this.onSelect,
    this.managing = false,
    this.onToggleManaging,
    this.onDeleteTag,
    super.key,
  });

  final List<String> tags;
  final String active;
  final ValueChanged<String> onSelect;

  /// 管理态 —— 对应 screens.jsx LibraryScreen 的 `managingTags`。
  final bool managing;

  /// 「管理/完成」pill 的开关回调; 不传则不渲染管理入口 (向后兼容)。
  final VoidCallback? onToggleManaging;

  /// 管理态下点具名标签 → 请求删除 (确认弹窗由调用方负责)。
  final ValueChanged<String>? onDeleteTag;

  bool _isRemovable(String tag) =>
      managing && tag != kAllTagsLabel && tag != kUntaggedLabel;

  @override
  Widget build(BuildContext context) {
    final bool hasManagePill = onToggleManaging != null;
    final int itemCount = tags.length + (hasManagePill ? 1 : 0);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemBuilder: (BuildContext _, int i) {
          if (i == tags.length) {
            return _ManagePill(managing: managing, onTap: onToggleManaging!);
          }
          final String tag = tags[i];
          final bool removable = _isRemovable(tag);
          return _TagPill(
            tag: tag,
            isActive: tag == active,
            removable: removable,
            onTap: () {
              if (removable) {
                onDeleteTag?.call(tag);
              } else {
                onSelect(tag);
              }
            },
          );
        },
        separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 8),
        itemCount: itemCount,
      ),
    );
  }
}

/// 单枚标签 pill。removable 时对应 `.tag.removable`: 虚线边框 +
/// 右侧 12px x 图标 (opacity 0.6), 右 padding 收窄到 6。
class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.tag,
    required this.isActive,
    required this.removable,
    required this.onTap,
  });

  final String tag;
  final bool isActive;
  final bool removable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final Color fg = isActive ? t.fgOnAccent : t.fg2;
    final Widget pill = AnimatedContainer(
      duration: XJKTokens.durFast,
      padding: EdgeInsets.fromLTRB(14, 6, removable ? 6 : 14, 6),
      decoration: BoxDecoration(
        color: isActive && !removable ? t.fg1 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: removable
            ? null
            : Border.all(color: isActive ? t.fg1 : t.border1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            tag,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 13,
              color: removable ? t.fg2 : fg,
            ),
          ),
          if (removable) ...<Widget>[
            const SizedBox(width: 4),
            Opacity(
              opacity: 0.6,
              child: XJKIcon('x', size: 12, color: t.fg2),
            ),
          ],
        ],
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: removable
          ? CustomPaint(
              foregroundPainter: _DashedRRectPainter(t.border1),
              child: pill,
            )
          : pill,
    );
  }
}

/// 行末「✎ 管理 / ✓ 完成」pill —— 对应 kit.css `.tag.manage-tag`:
/// 透明底 + border-2 实线边 + accent 前景 + 12px 图标。
class _ManagePill extends StatelessWidget {
  const _ManagePill({required this.managing, required this.onTap});

  final bool managing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final AppL10n l10n = AppL10n.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: t.border2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            XJKIcon(managing ? 'check' : 'pencil', size: 12, color: t.accent),
            const SizedBox(width: 3),
            Text(
              managing ? l10n.tagManageDone : l10n.tagManage,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: t.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 沿胶囊轮廓画虚线描边 —— Flutter Border 不支持 dashed,
/// 对应 kit.css `.tag.removable { border-style: dashed }`。
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter(this.color);

  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      const Radius.circular(999),
    );
    final Path path = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
