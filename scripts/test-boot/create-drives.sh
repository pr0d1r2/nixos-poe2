#!/usr/bin/env bash
# Create virtual ext4 disks for QEMU smoke testing.
# Usage: bash scripts/test-boot/create-drives.sh <work-dir>
#
# Creates qcow2 images (large raw sparse files stall QEMU NVMe emulation):
#   <work-dir>/nvme-test.qcow2  (115 GB, ext4 via raw-to-qcow2 convert)
#   <work-dir>/sata-test.qcow2  (128 GB, ext4 via raw-to-qcow2 convert)
#
# NVMe smaller than SATA on purpose: tests that storage-link picks
# NVMe by speed tier, not by size.

set -Eeuo pipefail

WORK_DIR="${1:?Usage: create-drives.sh <work-dir>}"
mkdir -p "$WORK_DIR"

NVME_IMG="$WORK_DIR/nvme-test.qcow2"
SATA_IMG="$WORK_DIR/sata-test.qcow2"

if [ -f "$NVME_IMG" ] && [ -f "$SATA_IMG" ]; then
    echo "create-drives: drives already exist in $WORK_DIR -- skipping"
    exit 0
fi

echo "create-drives: creating NVMe test drive (115G qcow2 + ext4)..."
truncate -s 115G "$WORK_DIR/nvme-tmp.raw"
mkfs.ext4 -F -L nvme-game "$WORK_DIR/nvme-tmp.raw"
qemu-img convert -f raw -O qcow2 "$WORK_DIR/nvme-tmp.raw" "$NVME_IMG"
rm -f "$WORK_DIR/nvme-tmp.raw"

echo "create-drives: creating SATA test drive (128G qcow2 + ext4)..."
truncate -s 128G "$WORK_DIR/sata-tmp.raw"
mkfs.ext4 -F -L sata-game "$WORK_DIR/sata-tmp.raw"
qemu-img convert -f raw -O qcow2 "$WORK_DIR/sata-tmp.raw" "$SATA_IMG"
rm -f "$WORK_DIR/sata-tmp.raw"

echo "create-drives: done"
