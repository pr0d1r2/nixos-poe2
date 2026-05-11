#!/usr/bin/env bash
# Boot the nixos-poe2 ISO in QEMU locally on Linux x86_64 with KVM
# and stream serial output to stdout. Designed to be spawned by
# expect (smoke.exp).
#
# Usage: bash smoke-local.sh [iso-path]
#
# Steps:
#   1. Locate or build the ISO
#   2. Create qcow2 test drives
#   3. Extract kernel + initrd for direct kernel boot
#   4. exec nix-shell -p qemu --run "...qemu..."
#
# The final exec replaces this shell so QEMU's serial output flows
# directly to the caller (expect) with no extra process layers.

set -Eeuo pipefail

# shellcheck disable=SC2154
trap 'rc=$?; echo "smoke-local: FAILED at scripts/test-boot/smoke-local.sh:${LINENO} (exit $rc): ${BASH_COMMAND}" >&2' ERR

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK_DIR="/tmp/poe2-qemu-test"

ISO="${1:-}"
if [ -z "$ISO" ]; then
    # shellcheck disable=SC2012
    ISO="$(ls -t "$REPO_ROOT/iso/"*.iso 2>/dev/null | head -n1 || true)"
    if [ -z "$ISO" ]; then
        echo "smoke-local: no ISO found in $REPO_ROOT/iso/. Run 'just build' first." >&2
        exit 1
    fi
fi

echo "smoke-local: ISO = $(basename "$ISO")" >&2
echo "smoke-local: work dir = $WORK_DIR" >&2

echo "smoke-local: creating virtual drives..." >&2
bash "$REPO_ROOT/scripts/test-boot/create-drives.sh" "$WORK_DIR" >&2

echo "smoke-local: extracting kernel + initrd..." >&2
bash "$REPO_ROOT/scripts/test-boot/extract-kernel.sh" "$ISO" "$WORK_DIR/boot" >&2

# Generate the QEMU launch script (needs qemu on PATH for command -v)
nix shell --extra-experimental-features 'nix-command flakes' nixpkgs#qemu -c \
    bash "$REPO_ROOT/scripts/test-boot/qemu-cmd.sh" \
    "$ISO" "$WORK_DIR" "$WORK_DIR/boot"

echo >&2
echo "smoke-local: booting $(basename "$ISO") in QEMU locally (Ctrl-C to exit)" >&2
echo >&2

exec bash "$WORK_DIR/run-qemu.sh"
