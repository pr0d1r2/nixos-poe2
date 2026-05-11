# shellcheck shell=bash
# Move nix store overlay upper/work to fastest available storage.
# Runs after storage-link creates /mnt/storage. Bind-mounts NVMe-backed
# directories over the tmpfs upper/work so new store paths land on NVMe.
set -euo pipefail

STORAGE="/mnt/storage"
UPPER="$STORAGE/nix-store-upper"
WORK="$STORAGE/nix-store-work"

if [ ! -d "$STORAGE" ]; then
    echo "nix-store-overlay: no storage available, keeping tmpfs overlay" >&2
    exit 0
fi

mkdir -p "$UPPER" "$WORK"

cp -a /nix/.rw-store/store/. "$UPPER/" 2>/dev/null || true

mount --bind "$UPPER" /nix/.rw-store/store
mount --bind "$WORK" /nix/.rw-store/work

echo "nix-store-overlay: upper/work bind-mounted from $STORAGE" >&2
