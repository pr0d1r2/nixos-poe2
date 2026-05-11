#!/usr/bin/env bash
# Boot the nixos-poe2 ISO in QEMU on nix-builder.local and stream
# serial output back to the caller's stdout. Designed to be spawned
# by expect (smoke.exp) on macOS -- serial stdio flows back through
# the SSH TTY naturally.
#
# Usage: bash smoke-remote.sh [iso-path]
#
# Steps:
#   1. Locate or build the ISO
#   2. Upload ISO to builder if needed
#   3. Create qcow2 test drives on builder
#   4. Extract kernel + initrd on builder (for direct kernel boot)
#   5. exec ssh -t builder "nix-shell -p qemu --run '...qemu...'"
#
# The final exec replaces this shell with SSH so QEMU's serial
# output flows directly to the caller (expect). No extra process
# layers to buffer or swallow output.

set -Eeuo pipefail

# shellcheck disable=SC2154
trap 'rc=$?; echo "smoke-remote: FAILED at scripts/test-boot/smoke-remote.sh:${LINENO} (exit $rc): ${BASH_COMMAND}" >&2' ERR

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILDER="$(bash "$REPO_ROOT/scripts/lib/find-builder.sh")"
WORK_DIR="/tmp/poe2-qemu-test"

SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short=7 HEAD)"
STORE_DIR="$(ssh "$BUILDER" sh <"$REPO_ROOT/scripts/build/iso_store_dir.sh")"

ISO="${1:-}"
if [ -z "$ISO" ]; then
    # shellcheck disable=SC2012
    ISO="$(ls -t "$REPO_ROOT/iso/"*"${SHORT_SHA}"*.iso 2>/dev/null | head -n1 || true)"
fi

if [ -z "$ISO" ] || [ ! -f "$ISO" ]; then
    echo "smoke-remote: no ISO for SHA $SHORT_SHA -- building..."
    bash "$REPO_ROOT/scripts/build/build.sh"
    # shellcheck disable=SC2012
    ISO="$(ls -t "$REPO_ROOT/iso/"*"${SHORT_SHA}"*.iso 2>/dev/null | head -n1 || true)"
    if [ -z "$ISO" ] || [ ! -f "$ISO" ]; then
        echo "smoke-remote: build did not produce an ISO." >&2
        exit 1
    fi
fi

ISO_NAME="$(basename "$ISO")"
REMOTE_ISO="$STORE_DIR/$ISO_NAME"

# Upload ISO to builder if not already staged
# shellcheck disable=SC2029
if ssh "$BUILDER" "[ -f '$REMOTE_ISO' ]"; then
    echo "smoke-remote: reusing $BUILDER:$REMOTE_ISO (already staged)" >&2
else
    echo "smoke-remote: uploading $ISO_NAME to builder..." >&2
    rsync -z --progress "$ISO" "$BUILDER:$REMOTE_ISO" >&2
fi

echo "smoke-remote: ISO = $ISO_NAME (on builder)" >&2

# Sync scripts to builder so we can run them directly (avoids
# stdin conflicts with nix-shell when piping via bash -s).
echo "smoke-remote: syncing scripts to builder..." >&2
# shellcheck disable=SC2029
ssh "$BUILDER" "mkdir -p '$WORK_DIR/scripts'" >&2
rsync -rlptDz --delete \
    "$REPO_ROOT/scripts/test-boot/" "$BUILDER:$WORK_DIR/scripts/" >&2

# Create qcow2 test drives + generate run-qemu.sh on builder.
# Both create-drives.sh (qemu-img) and qemu-cmd.sh (command -v)
# need qemu on PATH, so run inside nix-shell.
echo "smoke-remote: creating drives + generating QEMU script on builder..." >&2
# shellcheck disable=SC2029
ssh "$BUILDER" "nix shell --extra-experimental-features 'nix-command flakes' nixpkgs#qemu -c \
    bash -c \"bash '$WORK_DIR/scripts/create-drives.sh' '$WORK_DIR' && \
    bash '$WORK_DIR/scripts/extract-kernel.sh' '$REMOTE_ISO' '$WORK_DIR/boot' && \
    bash '$WORK_DIR/scripts/qemu-cmd.sh' '$REMOTE_ISO' '$WORK_DIR' '$WORK_DIR/boot'\"" >&2

echo >&2
echo "smoke-remote: booting $ISO_NAME in QEMU on $BUILDER (Ctrl-C to exit)" >&2
echo >&2

# exec ssh -t to run the pre-written QEMU script on the builder.
# The run-qemu.sh script has the full nix store path to the qemu
# binary baked in, so no nix-shell needed at runtime.
#
# -t: allocate a TTY so QEMU's serial-stdio output flows back
# through SSH interactively. Without -t, SSH buffers output and
# expect receives zero bytes.
#
# exec replaces this shell with SSH so there's no extra process
# layer between expect and QEMU's serial output.
exec ssh -t "$BUILDER" "bash '$WORK_DIR/run-qemu.sh'"
