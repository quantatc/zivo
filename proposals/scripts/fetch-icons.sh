#!/usr/bin/env bash
# Downloads brand SVG logos for every entry in integrations.json from Iconify.
# Idempotent — skips files already present. Saves to assets/integrations/<slug>.svg
# where <slug> is the iconify slug with ":" replaced by "--" (filesystem safe).
#
# Run from the proposals/ directory:
#   bash scripts/fetch-icons.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JSON_FILE="$ROOT_DIR/integrations.json"
OUT_DIR="$ROOT_DIR/assets/integrations"

mkdir -p "$OUT_DIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with 'choco install jq' (Windows) or 'brew install jq' (mac)." >&2
  exit 1
fi

slugs=()
while IFS= read -r slug; do
  slug="${slug%$'\r'}"
  [ -n "$slug" ] && slugs+=("$slug")
done < <(jq -r '.[].slug' "$JSON_FILE")

downloaded=0
skipped=0
failed=()

for slug in "${slugs[@]}"; do
  safe="${slug//:/--}"
  target="$OUT_DIR/$safe.svg"
  if [ -f "$target" ]; then
    skipped=$((skipped + 1))
    continue
  fi
  prefix="${slug%%:*}"
  name="${slug#*:}"
  # Tint monochrome simple-icons SVGs to brand subtle slate so the proposal
  # grid renders uniformly on dark surfaces. logos:* icons are full-colour
  # already; the color param is ignored.
  url="https://api.iconify.design/${prefix}/${name}.svg?color=%23cbd5e1"
  if curl -fsSL "$url" -o "$target"; then
    if [ ! -s "$target" ]; then
      rm -f "$target"
      failed+=("$slug")
      echo "  ! $slug (empty response)"
    else
      downloaded=$((downloaded + 1))
      echo "  + $slug"
    fi
  else
    rm -f "$target"
    failed+=("$slug")
    echo "  ! $slug"
  fi
done

echo
echo "Done. $downloaded downloaded, $skipped already cached, ${#failed[@]} failed."
if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed slugs: ${failed[*]}"
  echo "Edit integrations.json (try the slug without '-icon', or vice-versa) and rerun."
fi
