#!/usr/bin/env bash
# L20: 在已连接的鸿蒙真机上拉起 Folio + 抓关键日志 + 截屏, 一条命令搞定。
# 前置: 已 SIGN_MODE=agc sign_and_install.sh 装好; 手机解锁亮屏。
# 用法: bash tool/ohos/run_device.sh [截屏输出路径(默认 /tmp/folio_screen.jpeg)]
set -uo pipefail

BUNDLE="app.folio.quotes"
ABILITY="EntryAbility"
MODULE="entry"
SHOT="${1:-/tmp/folio_screen.jpeg}"
export PATH="$HOME/sdks/ohos-sdk/sdk/20/toolchains:$PATH"

command -v hdc >/dev/null || { echo "hdc 不在 PATH; 确认 ~/sdks/ohos-sdk/sdk/20/toolchains 存在"; exit 1; }

echo "==> 设备"; hdc list targets
echo "==> 清日志 + 拉起 (确保手机已解锁亮屏)"
hdc shell hilog -r >/dev/null 2>&1
hdc shell aa force-stop "$BUNDLE" >/dev/null 2>&1
START=$(hdc shell aa start -a "$ABILITY" -b "$BUNDLE" -m "$MODULE" 2>&1)
echo "    $START"
case "$START" in
  *locked*) echo "    ⚠ 屏幕锁了, 解锁后重跑 (开发者模式 hdc 不能自动解锁)";;
esac

# 给 Dart 起来一点时间
for _ in 1 2 3 4 5; do hdc shell "echo" >/dev/null 2>&1; done

echo "==> 进程"; hdc shell "pidof $BUNDLE" 2>/dev/null
echo "==> 关键日志 (异常/插件/sqlite)"
hdc shell hilog -x 2>/dev/null | grep "$BUNDLE" \
  | grep -iE "启动失败|MissingPlugin|Exception:|Unhandled|sqlite|drift|getApplicationSupport|fault|abort" \
  | grep -ivE "NavigationChannel|notifyPageChanged" | tail -15

echo "==> 截屏 -> $SHOT"
hdc shell "snapshot_display -f /data/local/tmp/folio_run.jpeg" >/dev/null 2>&1
hdc file recv /data/local/tmp/folio_run.jpeg "$SHOT" 2>&1 | tail -1
echo "    用 Read 工具看 $SHOT 确认界面 (Dart 报错会直接显示在错误页上)。"
