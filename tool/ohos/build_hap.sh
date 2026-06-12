#!/usr/bin/env bash
# L20: 本地构建鸿蒙 hap (不进 CI)。
#
# 前置 (一次性, 见 docs/wiki/ohos/01-环境搭建.md):
#   ~/sdks/flutter-ohos        鸿蒙化 Flutter fork (tag 3.35.8-ohos-1.0.1)
#   ~/sdks/ohos-sdk/sdk        OpenHarmony SDK, 布局 <api>/{ets,js,native,toolchains,...}
#   ~/sdks/oh-command-line-tools  ohpm
#
# 用法: bash tool/ohos/build_hap.sh [debug|release]   (默认 debug)
set -euo pipefail

MODE="${1:-debug}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

export PATH="$HOME/sdks/flutter-ohos/bin:$HOME/sdks/oh-command-line-tools/ohpm/bin:$PATH"
export OHOS_SDK_HOME="${OHOS_SDK_HOME:-$HOME/sdks/ohos-sdk/sdk}"
export PUB_HOSTED_URL="${PUB_HOSTED_URL:-https://pub.flutter-io.cn}"
export FLUTTER_STORAGE_BASE_URL="${FLUTTER_STORAGE_BASE_URL:-https://storage.flutter-io.cn}"

cleanup() {
  # 还原 ohos 构建对主线工作区的污染:
  # 1. 根 pubspec_overrides.yaml 是 ohos 专用 (已 gitignore, 防呆再删一次)
  # 2. pubspec.lock 以官方 stable 解析为准, fork (Dart 3.9) 会降级重写
  rm -f "$REPO_ROOT/pubspec_overrides.yaml"
  git -C "$REPO_ROOT" checkout -q pubspec.lock 2>/dev/null || true
}
trap cleanup EXIT

cp tool/ohos/pubspec_overrides.ohos.yaml pubspec_overrides.yaml

flutter pub get
flutter build hap "--$MODE"

echo
echo "hap 产物:"
find ohos -name "*.hap" -newer tool/ohos/build_hap.sh 2>/dev/null || true
