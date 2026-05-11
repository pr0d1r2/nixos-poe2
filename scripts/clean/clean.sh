#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short=7 HEAD)"

# Local markers
for marker in ".smoke-passed-$SHORT_SHA" ".burn-done-$SHORT_SHA"; do
    if [ -f "$REPO_ROOT/$marker" ]; then
        rm -f "$REPO_ROOT/$marker"
        echo "clean: removed $marker"
    fi
done

# Local ISO
for iso in "$REPO_ROOT/iso/"*"${SHORT_SHA}"*.iso; do
    [ -f "$iso" ] || continue
    rm -f "$iso"
    echo "clean: removed local iso $(basename "$iso")"
done

# Remote ISO on builder
BUILDER="$(bash "$REPO_ROOT/scripts/lib/find-builder.sh")"
STORE_DIR="$(ssh "$BUILDER" sh <"$REPO_ROOT/scripts/build/iso_store_dir.sh")"
# shellcheck disable=SC2029
ssh "$BUILDER" "rm -f '$STORE_DIR/'*'${SHORT_SHA}'*.iso"
echo "clean: removed remote iso for $SHORT_SHA on $BUILDER"
