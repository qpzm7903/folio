import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Issue #7: 把"更换频率"从 9 档预设的 list picker 改成双滚轮
/// (小时 + 分钟), 让用户自由选 1 分钟 ~ 12 小时 (720 分钟) 之间任意值。
///
/// 视觉对照 skill `ui_kits/android-app/screens.jsx:244-273` 的 ImportSheet
/// 骨架: grabber + h2 + 内容区 + 主按钮; 滚轮区用 ListWheelScrollView 手撸,
/// 避开 CupertinoTimerPicker (iOS 蓝跟青纸/林夜衬线冲突)。
Future<int?> showCadenceWheelSheet({
  required BuildContext context,
  required int currentMinutes,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => _CadenceWheelSheet(
      initialMinutes: currentMinutes.clamp(1, _kMaxTotalMinutes),
    ),
  );
}

// v0.29.0: 12→24, 让设计源 CADENCES 的 1440「每日一句」可达。
const int _kMaxHours = 24;
const int _kMaxTotalMinutes = _kMaxHours * 60;

class _CadenceWheelSheet extends StatefulWidget {
  const _CadenceWheelSheet({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_CadenceWheelSheet> createState() => _CadenceWheelSheetState();
}

class _CadenceWheelSheetState extends State<_CadenceWheelSheet> {
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialMinutes ~/ 60;
    _minute = widget.initialMinutes % 60;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  int get _totalMinutes => _hour * 60 + _minute;
  bool get _isValid => _totalMinutes >= 1;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: t.bgRaised,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: const BoxConstraints(maxWidth: 640),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Grabber(color: t.fgMuted),
            const SizedBox(height: 12),
            _Title(t: t),
            const SizedBox(height: 4),
            _Subtitle(t: t),
            const SizedBox(height: 16),
            _PreviewLine(minutes: _totalMinutes, t: t),
            const SizedBox(height: 8),
            _Wheels(
              hour: _hour,
              minute: _minute,
              hourCtrl: _hourCtrl,
              minuteCtrl: _minuteCtrl,
              onHourChanged: (int v) => setState(() => _hour = v),
              onMinuteChanged: (int v) => setState(() => _minute = v),
              t: t,
            ),
            const SizedBox(height: 20),
            _SaveButton(
              enabled: _isValid,
              onTap: () => Navigator.of(context).pop(_totalMinutes),
              t: t,
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.t});
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return Text(
      '更换频率',
      style: TextStyle(
        fontFamily: XJKTokens.serifDisplay,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: t.fg1,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.t});
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return Text(
      '一句话停留多久',
      style: TextStyle(
        fontFamily: XJKTokens.serifItalic,
        fontStyle: FontStyle.italic,
        fontSize: 13,
        color: t.fgMuted,
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.minutes, required this.t});
  final int minutes;
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Center(
        child: Text(
          formatCadenceText(minutes),
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 17,
            color: minutes >= 1 ? t.fg1 : t.fgMuted,
          ),
        ),
      ),
    );
  }
}

class _Wheels extends StatelessWidget {
  const _Wheels({
    required this.hour,
    required this.minute,
    required this.hourCtrl,
    required this.minuteCtrl,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.t,
  });

  final int hour;
  final int minute;
  final FixedExtentScrollController hourCtrl;
  final FixedExtentScrollController minuteCtrl;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _Wheel(
              count: _kMaxHours + 1,
              controller: hourCtrl,
              onChanged: onHourChanged,
              suffix: '小时',
              t: t,
            ),
          ),
          Expanded(
            child: _Wheel(
              count: 60,
              controller: minuteCtrl,
              onChanged: onMinuteChanged,
              suffix: '分钟',
              t: t,
            ),
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.count,
    required this.controller,
    required this.onChanged,
    required this.suffix,
    required this.t,
  });

  final int count;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;
  final String suffix;
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Center(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: t.accentSoft.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 40,
          diameterRatio: 1.6,
          perspective: 0.003,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: count,
            builder: (BuildContext context, int i) {
              return Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: XJKTokens.serifDisplay,
                      fontSize: 18,
                      color: t.fg1,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: '$i '),
                      TextSpan(
                        text: suffix,
                        style: TextStyle(fontSize: 13, color: t.fgMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.onTap,
    required this.t,
  });

  final bool enabled;
  final VoidCallback onTap;
  final XJKTokens t;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: enabled ? onTap : null,
          style: TextButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.fgOnAccent,
            disabledForegroundColor: t.fgOnAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('保存'),
        ),
      ),
    );
  }
}

/// 把分钟数格式化成滚轮预览 / 设置行 value 用的可读文案。
///
/// 边界规则:
/// - 0 → "请选择" (没意义, 滚轮起初 hour=0 + minute=0 时显示)
/// - <60 分钟 → "每 X 分钟换一句"
/// - 整小时 → "每 X 小时换一句"
/// - 混合 → "每 X 小时 Y 分钟换一句"
String formatCadenceText(int minutes) {
  if (minutes <= 0) return '请选择';
  if (minutes == 1440) return '每日一句'; // 设计源 CADENCES (v0.29.0)
  if (minutes < 60) return '每 $minutes 分钟换一句';
  final int h = minutes ~/ 60;
  final int m = minutes % 60;
  if (m == 0) return '每 $h 小时换一句';
  return '每 $h 小时 $m 分钟换一句';
}

/// 设置屏 SettingRow 的 value 列显示文案 (短版本)。
String formatCadenceShort(int minutes) {
  if (minutes == 1440) return '每日';
  if (minutes < 60) return '$minutes 分钟';
  final int h = minutes ~/ 60;
  final int m = minutes % 60;
  if (m == 0) return '$h 小时';
  return '$h 小时 $m 分';
}
