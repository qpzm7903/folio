#!/usr/bin/env bash
# 把 docs/android_widget/ 下的 native widget 模板复制到 flutter create 生成的
# android/ 目录, 并把 receiver fragment 注入 AndroidManifest.xml。
#
# 必须在 `flutter create --platforms=android,web .` 之后跑, 在 `flutter build apk`
# 之前。Linux / macOS / Windows-with-git-bash 都能跑 (兼容 bash 3.2)。
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d android/app/src/main ]; then
  echo "✗ android/app/src/main not found; run flutter create first" >&2
  exit 1
fi

SRC="docs/android_widget/app/src/main"
DST="android/app/src/main"

echo "↪ copy widget res/ + kotlin/ from $SRC"
mkdir -p "$DST/res/layout" "$DST/res/xml" "$DST/res/values" "$DST/res/drawable"
cp "$SRC/res/layout/"*.xml "$DST/res/layout/"
cp "$SRC/res/xml/"*.xml "$DST/res/xml/"
cp "$SRC/res/values/"*.xml "$DST/res/values/"
cp "$SRC/res/drawable/"*.xml "$DST/res/drawable/"

mkdir -p "$DST/kotlin/app/folio/widget"
cp "$SRC/kotlin/app/folio/widget/"*.kt "$DST/kotlin/app/folio/widget/"

# v0.15.9 Issue #8: 自定义 MainActivity (含 wallpaper MethodChannel handler)
# 覆盖 `flutter create` 默认空 MainActivity。
if [ -f "$SRC/kotlin/app/folio/MainActivity.kt" ]; then
  echo "↪ overwrite MainActivity.kt with custom (wallpaper channel)"
  cp "$SRC/kotlin/app/folio/MainActivity.kt" "$DST/kotlin/app/folio/MainActivity.kt"
fi

# 注入 receiver 到 AndroidManifest.xml 的 </application> 之前
MANIFEST="android/app/src/main/AndroidManifest.xml"
if grep -q "QuoteWidgetProvider" "$MANIFEST"; then
  echo "✓ widget receiver already injected, skip"
else
  echo "↪ inject widget receiver fragment to $MANIFEST"
  FRAGMENT="docs/android_widget/AndroidManifest_widget_fragment.xml"
  python3 - "$MANIFEST" "$FRAGMENT" <<'PY'
import sys, pathlib, re
manifest_path = pathlib.Path(sys.argv[1])
fragment_path = pathlib.Path(sys.argv[2])
manifest = manifest_path.read_text(encoding='utf-8')
fragment_raw = fragment_path.read_text(encoding='utf-8')
# 跳过 fragment 顶部的 <!-- ... --> 注释
fragment = re.sub(r'^\s*<!--.*?-->\s*', '', fragment_raw, count=1, flags=re.S).rstrip() + '\n'

# Flutter create 的默认 AndroidManifest.xml 只声明 xmlns:android,
# 没有 xmlns:tools。fragment 里的 tools:node="remove" 需要 tools 命名空间
# (用于禁用 WorkManager startup, v0.14.1 修 #5)。补上。
if 'xmlns:tools' not in manifest:
    manifest = re.sub(
        r'(<manifest\s)',
        r'\1xmlns:tools="http://schemas.android.com/tools" ',
        manifest,
        count=1,
    )
    print('✓ added xmlns:tools to <manifest>')

# v0.15.9 Issue #8: SET_WALLPAPER 权限 (normal permission, Android 6+ install-time
# 自动授予, 无需 runtime request)。要让 MainActivity 的
# WallpaperManager.setBitmap 不报 SecurityException 必须 declare。
if 'android.permission.SET_WALLPAPER' not in manifest:
    manifest = re.sub(
        r'(<manifest\b[^>]*>)',
        r'\1\n    <uses-permission android:name="android.permission.SET_WALLPAPER" />',
        manifest,
        count=1,
    )
    print('✓ added SET_WALLPAPER uses-permission')

needle = '</application>'
if needle not in manifest:
    raise SystemExit('✗ <application> close tag not found in manifest')
new = manifest.replace(needle, fragment + '    ' + needle, 1)
manifest_path.write_text(new, encoding='utf-8')
print('✓ injected widget receiver + startup-disable before </application>')
PY
fi

echo "✓ Android widget native files in place"
