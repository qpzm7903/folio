#!/usr/bin/env bash
# 下载本地字体到 assets/fonts/ —— 禁止运行时走 Google Fonts CDN
# 字体许可: SIL Open Font License 1.1 (OFL)
set -euo pipefail

cd "$(dirname "$0")/.."
DEST="assets/fonts"
mkdir -p "$DEST"

# 这里使用 Google Fonts 直链的 static .ttf 文件（仅作为字体源仓库，不是运行时 CDN）。
# 字体一旦下载，运行时全部走 assets，不再请求网络。
declare -A FONTS=(
  ["NotoSerifSC-Regular.ttf"]="https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Regular.otf"
  ["NotoSerifSC-Medium.ttf"]="https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Medium.otf"
  ["NotoSerifSC-SemiBold.ttf"]="https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-SemiBold.otf"
  ["NotoSansSC-Regular.ttf"]="https://github.com/notofonts/noto-cjk/raw/main/Sans/SubsetOTF/SC/NotoSansSC-Regular.otf"
  ["NotoSansSC-Medium.ttf"]="https://github.com/notofonts/noto-cjk/raw/main/Sans/SubsetOTF/SC/NotoSansSC-Medium.otf"
  ["EBGaramond-Regular.ttf"]="https://github.com/google/fonts/raw/main/ofl/ebgaramond/EBGaramond%5Bwght%5D.ttf"
  ["EBGaramond-Italic.ttf"]="https://github.com/google/fonts/raw/main/ofl/ebgaramond/EBGaramond-Italic%5Bwght%5D.ttf"
)

for name in "${!FONTS[@]}"; do
  url="${FONTS[$name]}"
  out="$DEST/$name"
  if [[ -f "$out" ]]; then
    echo "✓ already exists: $name"
    continue
  fi
  echo "↓ fetching $name"
  curl -fsSL -o "$out" "$url"
done

echo "✓ fonts ready in $DEST"
ls -lh "$DEST"
