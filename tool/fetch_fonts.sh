#!/usr/bin/env bash
# 下载本地字体到 assets/fonts/ —— 禁止运行时走 Google Fonts CDN。
# 字体许可: SIL Open Font License 1.1 (OFL)。
#
# 兼容性: 故意不用 `declare -A` 关联数组, 因为 macOS runner 默认
# bash 3.2 不支持; 改用平行数组 + index 对齐, bash 3 / bash 4 / git-bash
# 全都能跑。
set -euo pipefail

cd "$(dirname "$0")/.."
DEST="assets/fonts"
mkdir -p "$DEST"

# index → 文件名
NAMES=(
  "NotoSerifSC-Regular.ttf"
  "NotoSerifSC-Medium.ttf"
  "NotoSerifSC-SemiBold.ttf"
  "NotoSansSC-Regular.ttf"
  "NotoSansSC-Medium.ttf"
  "EBGaramond-Regular.ttf"
  "EBGaramond-Italic.ttf"
)

# index → 下载源 (跟 NAMES 一一对齐, 顺序不能换)
URLS=(
  "https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Regular.otf"
  "https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Medium.otf"
  "https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-SemiBold.otf"
  "https://github.com/notofonts/noto-cjk/raw/main/Sans/SubsetOTF/SC/NotoSansSC-Regular.otf"
  "https://github.com/notofonts/noto-cjk/raw/main/Sans/SubsetOTF/SC/NotoSansSC-Medium.otf"
  "https://github.com/google/fonts/raw/main/ofl/ebgaramond/EBGaramond%5Bwght%5D.ttf"
  "https://github.com/google/fonts/raw/main/ofl/ebgaramond/EBGaramond-Italic%5Bwght%5D.ttf"
)

if [ "${#NAMES[@]}" -ne "${#URLS[@]}" ]; then
  echo "✗ NAMES and URLS array lengths differ; check tool/fetch_fonts.sh" >&2
  exit 1
fi

i=0
while [ $i -lt ${#NAMES[@]} ]; do
  name="${NAMES[$i]}"
  url="${URLS[$i]}"
  out="$DEST/$name"
  if [ -f "$out" ]; then
    echo "✓ already exists: $name"
  else
    echo "↓ fetching $name"
    curl -fsSL -o "$out" "$url"
  fi
  i=$((i + 1))
done

echo "✓ fonts ready in $DEST"
ls -lh "$DEST"
