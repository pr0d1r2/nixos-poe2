#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
BUILDER="$(bash "$REPO_ROOT/scripts/lib/find-builder.sh")"

echo "gc: running nix-collect-garbage on $BUILDER..."
ssh "$BUILDER" "nix-collect-garbage -d 2>&1"
