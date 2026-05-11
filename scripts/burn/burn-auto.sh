#!/usr/bin/env bash
# Auto-select burn: picks HEAD ISO without prompting.
# Still prompts for USB device and BURN confirmation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export POE2_BURN_AUTO=1
exec bash "$REPO_ROOT/scripts/burn/burn.sh"
