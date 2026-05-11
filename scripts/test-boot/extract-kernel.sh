#!/usr/bin/env bash
# Extract kernel + initrd from a NixOS ISO for direct kernel boot.
# Usage: bash extract-kernel.sh <iso-path> <boot-dir>
#
# Mounts the ISO read-only, copies bzImage + initrd to boot-dir.
# Skips extraction if files already exist and ISO has not changed.

set -Eeuo pipefail

ISO="${1:?Usage: extract-kernel.sh <iso-path> <boot-dir>}"
BOOT_DIR="${2:?Usage: extract-kernel.sh <iso-path> <boot-dir>}"

mkdir -p "$BOOT_DIR"

if [ -f "$BOOT_DIR/bzImage" ] && [ -f "$BOOT_DIR/initrd" ] &&
    [ ! "$ISO" -nt "$BOOT_DIR/bzImage" ]; then
    echo "extract-kernel: kernel + initrd already extracted" >&2
    exit 0
fi

echo "extract-kernel: extracting kernel + initrd from ISO..." >&2
MNT="$(mktemp -d)"
trap 'umount "$MNT" 2>/dev/null; rmdir "$MNT" 2>/dev/null' EXIT

mount -o loop,ro "$ISO" "$MNT"
KERNEL="$(find "$MNT/boot" -name 'bzImage' -print -quit)"
INITRD="$(find "$MNT/boot" -name 'initrd' -print -quit)"

if [ -z "$KERNEL" ] || [ -z "$INITRD" ]; then
    echo "extract-kernel: could not find kernel/initrd in ISO" >&2
    exit 1
fi

cp "$KERNEL" "$BOOT_DIR/bzImage"
cp "$INITRD" "$BOOT_DIR/initrd"

GRUB_CFG="$(find "$MNT" -name 'grub.cfg' -print -quit 2>/dev/null || true)"
if [ -n "$GRUB_CFG" ]; then
    INIT_PATH="$(grep -m1 'init=' "$GRUB_CFG" |
        sed -n 's/.*init=\([^ ]*\).*/\1/p')"
    if [ -n "$INIT_PATH" ]; then
        echo "$INIT_PATH" >"$BOOT_DIR/init-path"
    fi
fi
echo "extract-kernel: kernel + initrd extracted to $BOOT_DIR" >&2
