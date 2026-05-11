# shellcheck shell=bash
set -u

target=""
for candidate in /mnt/storage-nvme /mnt/storage-sata; do
    if mountpoint -q "$candidate"; then
        target="$candidate"
        break
    fi
done

if [ -e /mnt/storage ] && [ ! -L /mnt/storage ]; then
    echo "storage-link: /mnt/storage exists and is not a symlink; refusing to touch" >&2
    exit 0
fi

if [ -z "$target" ]; then
    rm -f /mnt/storage
    echo "storage-link: no storage tier mounted; /mnt/storage left absent" >&2
    exit 0
fi

ln -sfn "$target" /mnt/storage
echo "storage-link: /mnt/storage -> $target" >&2
