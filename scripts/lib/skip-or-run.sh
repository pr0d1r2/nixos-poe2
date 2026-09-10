#!/usr/bin/env bash
# Skip work already done, otherwise run it step by step.
#
# Usage: skip-or-run.sh <check-script> <step-script> [step-script ...]
#   check-script  run with bash; exit 0 means done, so every step is skipped
#   step-script   run in order with bash; the first failure stops the
#                 chain and its exit code is returned

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: skip-or-run.sh <check-script> <step-script> [step-script ...]" >&2
    exit 2
fi

check="$1"
shift

if bash "$check"; then
    exit 0
fi

for step in "$@"; do
    bash "$step"
done
