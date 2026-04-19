#!/usr/bin/env sh
set -eu

FORK_DIR="${OPEN_WEBUI_FORK_PATH:-../zivo-openwebui}"
UPSTREAM_URL="${OPEN_WEBUI_UPSTREAM_URL:-https://github.com/open-webui/open-webui.git}"
UPSTREAM_REF="${OPEN_WEBUI_UPSTREAM_REF:-v0.8.12}"
BRANCH="${OPEN_WEBUI_BRANCH:-zivo/v0.8.12}"
FORK_REMOTE="${OPEN_WEBUI_FORK_REMOTE:-}"

if [ -d "$FORK_DIR/.git" ]; then
  echo "Using existing Open WebUI fork at $FORK_DIR"
else
  if [ -n "$FORK_REMOTE" ]; then
    git clone "$FORK_REMOTE" "$FORK_DIR"
  else
    git clone "$UPSTREAM_URL" "$FORK_DIR"
  fi
fi

cd "$FORK_DIR"

if [ -n "$FORK_REMOTE" ]; then
  if ! git remote get-url upstream >/dev/null 2>&1; then
    git remote add upstream "$UPSTREAM_URL"
  fi
fi

if git remote get-url upstream >/dev/null 2>&1; then
  BASE_REMOTE=upstream
else
  BASE_REMOTE=origin
fi

git fetch "$BASE_REMOTE" --tags

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git switch "$BRANCH"
else
  git switch -c "$BRANCH" "$UPSTREAM_REF"
fi

cat <<EOF
Open WebUI fork is ready:
  path:   $FORK_DIR
  branch: $BRANCH
  base:   $UPSTREAM_REF

Next:
  1. Make Zivo source changes in $FORK_DIR.
  2. Commit small themed changes.
  3. Build with ./scripts/build-openwebui-fork.sh from the zivo repo.
EOF
