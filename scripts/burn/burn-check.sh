#!/usr/bin/env bash
# Exit 0 if burn already done for current git SHA, 1 if not.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short=7 HEAD)"
MARKER="$REPO_ROOT/.burn-done-$SHORT_SHA"

if [ -f "$MARKER" ]; then
    echo "burn: already done for $SHORT_SHA ($(cat "$MARKER"))" >&2
    exit 0
fi

exit 1
