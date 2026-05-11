#!/usr/bin/env bash
# Try to burn from nix-builder.local instead of this host.
# Exit codes: 0=success, 1=remote failed, 2=not attempted (fall through)

set -Eeuo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: burn-remote.sh <repo_root>" >&2
    exit 2
fi

REPO_ROOT="$1"

[ -n "${POE2_BURN_LOCAL:-}" ] && exit 2
[ -n "${POE2_BURN_FAKE_BACKEND:-}" ] && exit 2

builder="$(bash "$REPO_ROOT/scripts/lib/find-builder.sh" 2>/dev/null || true)"
if [ -z "$builder" ]; then
    echo "burn: no builder reachable, falling back to local burn"
    exit 2
fi

echo "burn: using remote builder $builder"
remote_work="/tmp/poe2-burn"
# shellcheck disable=SC2029
ssh "$builder" "mkdir -p '$remote_work/scripts/burn'"

rsync -rltDz --no-owner --no-group \
    "$REPO_ROOT/scripts/burn/" "$builder:$remote_work/scripts/burn/"

store_dir="$(ssh "$builder" sh <"$REPO_ROOT/scripts/build/iso_store_dir.sh")"

short_sha=""
if git diff --quiet --exit-code 2>/dev/null &&
    git diff --cached --quiet --exit-code 2>/dev/null; then
    short_sha="$(git rev-parse --short=7 HEAD)"
    # shellcheck disable=SC2029
    if ssh "$builder" "ls '$store_dir'/*${short_sha}*.iso >/dev/null 2>&1"; then
        echo "burn: found ISO for HEAD ($short_sha) in $builder:$store_dir"
    else
        echo "burn: no ISO for HEAD ($short_sha) in $builder:$store_dir -- building first"
        POE2_BURN_BUILD=1 just build
        if ! ssh "$builder" "ls '$store_dir'/*${short_sha}*.iso >/dev/null 2>&1"; then
            echo "burn: build finished but still no ISO for $short_sha in $builder:$store_dir" >&2
            exit 1
        fi
    fi
else
    echo "burn: dirty tree -- cannot verify HEAD ISO exists; proceeding with whatever's in the store" >&2
fi

# shellcheck disable=SC2029
if ssh -t "$builder" "cd '$remote_work' && POE2_HEAD_SHA='$short_sha' POE2_BURN_AUTO='${POE2_BURN_AUTO:-0}' POE2_BURN_CONFIRMED='${POE2_BURN_CONFIRMED:-0}' bash scripts/burn/burn.sh '$store_dir'"; then
    exit 0
else
    exit 1
fi
