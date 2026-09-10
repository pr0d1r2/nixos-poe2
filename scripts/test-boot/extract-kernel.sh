#!/usr/bin/env bash
# Extract kernel + initrd from a NixOS ISO for direct kernel boot.
# Usage: bash extract-kernel.sh <iso-path> <boot-dir>
#
# Mounts the ISO read-only, copies bzImage + initrd to boot-dir and
# stores the ISO's own kernel command line as boot-dir/cmdline.
# Skips extraction if files already exist and ISO has not changed.

set -Eeuo pipefail

ISO="${1:?Usage: extract-kernel.sh <iso-path> <boot-dir>}"
BOOT_DIR="${2:?Usage: extract-kernel.sh <iso-path> <boot-dir>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$BOOT_DIR"

if [ -f "$BOOT_DIR/bzImage" ] && [ -f "$BOOT_DIR/initrd" ] &&
    [ -f "$BOOT_DIR/cmdline" ] &&
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

# The ISO's own boot menu is the source of truth for the kernel command
# line: init=, root= (a volume label on scripted initrds, fstab on
# systemd initrds) and every boot.kernelParams entry.
GRUB_CFG="$(find "$MNT" -name 'grub.cfg' -print -quit 2>/dev/null || true)"
if [ -z "$GRUB_CFG" ]; then
    echo "extract-kernel: no grub.cfg in ISO -- cannot read the kernel command line" >&2
    exit 1
fi
# Resolve before writing, so a failed lookup never leaves an empty
# cmdline that would satisfy the skip check above.
CMDLINE="$(bash "$SCRIPT_DIR/grub-cmdline.sh" "$GRUB_CFG")"
echo "$CMDLINE" >"$BOOT_DIR/cmdline"
echo "extract-kernel: kernel + initrd extracted to $BOOT_DIR (cmdline: $CMDLINE)" >&2
