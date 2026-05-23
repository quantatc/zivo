#!/usr/bin/env bash
# Download Inter and JetBrains Mono into proposals/fonts/ so Typst can find
# them via --font-path (no system install needed). Idempotent.
#
# Run from the proposals/ directory:
#   bash scripts/fetch-fonts.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONTS_DIR="$ROOT_DIR/fonts"
TMP_DIR="$(mktemp -d -t zivo-fonts.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$FONTS_DIR"

if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is required." >&2
  exit 1
fi

fetch_pack() {
  local name="$1" url="$2" marker="$3" sub_path="$4"
  if [ -f "$FONTS_DIR/$marker" ]; then
    echo "  = $name already present, skipping."
    return
  fi
  local key
  key="${name// /_}"
  local zip="$TMP_DIR/$key.zip"
  local extract="$TMP_DIR/$key"

  echo "  + Downloading $name..."
  curl -fsSL "$url" -o "$zip"
  mkdir -p "$extract"
  unzip -q "$zip" -d "$extract"

  local cand="$extract/$sub_path"
  if [ ! -d "$cand" ]; then
    cand="$(find "$extract" -type d -name 'ttf' -print -quit || true)"
  fi
  if [ -z "$cand" ] || [ ! -d "$cand" ]; then
    cand="$(find "$extract" -type f -name '*.ttf' -print -quit | xargs -I{} dirname {} | head -n1 || true)"
  fi
  if [ -z "$cand" ] || [ ! -d "$cand" ]; then
    echo "    ! Could not locate TTF directory in $name extract."
    return
  fi
  cp "$cand"/*.ttf "$FONTS_DIR/" 2>/dev/null || true
  echo "    -> copied $name TTFs to fonts/"
}

fetch_pack "Inter" \
  "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip" \
  "Inter-Regular.ttf" \
  "Inter Desktop"

fetch_pack "JetBrains Mono" \
  "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" \
  "JetBrainsMono-Regular.ttf" \
  "fonts/ttf"

echo
echo "Done. Pass '--font-path fonts' to typst, or use scripts/build.sh."
