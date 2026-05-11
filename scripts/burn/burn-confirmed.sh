#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export POE2_BURN_AUTO=1
export POE2_BURN_CONFIRMED=1
exec bash "$REPO_ROOT/scripts/burn/burn.sh"
