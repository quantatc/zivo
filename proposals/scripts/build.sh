#!/usr/bin/env bash
# Compile the Zivo proposal for a specific prospect.
#
# Usage:
#   bash scripts/build.sh                                 # generic version
#   bash scripts/build.sh "Acme Corp"                     # named prospect
#   bash scripts/build.sh "Acme Corp" "logistics"         # + industry override
#
# Env overrides:
#   PREPARED_BY  Author line              (default: "Antony Chibamu - Founder, Zivo")
#   EMAIL        Contact email             (default: hello@zivoworkspace.ai)
#   VERSION      Version tag               (default: v1.0)
#   OUTFILE      Output path               (default: out/zivo-proposal-<slug>.pdf)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v typst >/dev/null 2>&1; then
  echo "ERROR: typst is not on PATH." >&2
  echo "Install with: winget install Typst.Typst   (Windows)" >&2
  echo "         or:  brew install typst           (macOS)"   >&2
  echo "         or:  https://github.com/typst/typst/releases/latest" >&2
  exit 1
fi

PROSPECT="${1:-generic}"
INDUSTRY="${2:-operations}"
PREPARED_BY="${PREPARED_BY:-Antony Chibamu - Founder, Zivo}"
EMAIL="${EMAIL:-hello@zivoworkspace.ai}"
VERSION="${VERSION:-v1.0}"

slug=$(echo "$PROSPECT" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
[ -z "$slug" ] && slug="generic"

OUTFILE="${OUTFILE:-out/zivo-proposal-$slug.pdf}"
mkdir -p "$(dirname "$OUTFILE")"

# Make sure integration icons have been fetched
icon_count=$(find assets/integrations -maxdepth 1 -name '*.svg' 2>/dev/null | wc -l)
if [ "$icon_count" -lt 40 ]; then
  echo "Integration icons missing - running fetch-icons.sh first..."
  bash "$ROOT_DIR/scripts/fetch-icons.sh"
fi

# Make sure brand fonts have been fetched
font_count=$(find fonts -maxdepth 1 -name '*.ttf' 2>/dev/null | wc -l)
if [ "$font_count" -lt 4 ]; then
  echo "Brand fonts missing - running fetch-fonts.sh first..."
  bash "$ROOT_DIR/scripts/fetch-fonts.sh"
fi

today=$(date +"%B %d, %Y")

echo "Compiling proposal for '$PROSPECT' -> $OUTFILE"

typst compile \
  --font-path fonts \
  --input "prospect=$PROSPECT" \
  --input "industry=$INDUSTRY" \
  --input "prepared_by=$PREPARED_BY" \
  --input "email=$EMAIL" \
  --input "version=$VERSION" \
  --input "date=$today" \
  zivo-proposal.typ \
  "$OUTFILE"

echo "Done. Open $OUTFILE"
