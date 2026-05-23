import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// 标签横滑条 —— 对应 kit.css 中 `.tag-row` + `.tag` (active).
class TagRow extends StatelessWidget {
  const TagRow({
    required this.tags,
    required this.active,
    required this.onSelect,
    super.key,
  });

  final List<String> tags;
  final String active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemBuilder: (BuildContext _, int i) {
          final String tag = tags[i];
          final bool isActive = tag == active;
          return GestureDetector(
            onTap: () => onSelect(tag),
            child: AnimatedContainer(
              duration: XJKTokens.durFast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? t.fg1 : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isActive ? t.fg1 : t.border1),
              ),
              child: Center(
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: XJKTokens.serifDisplay,
                    fontSize: 13,
                    color: isActive ? t.fgOnAccent : t.fg2,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 8),
        itemCount: tags.length,
      ),
    );
  }
}
