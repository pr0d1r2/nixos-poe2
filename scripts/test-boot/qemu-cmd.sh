#!/usr/bin/env bash
# Write a self-contained QEMU launch script (run-qemu.sh) that can
# be executed directly without nix-shell (uses full nix store path).
#
# Usage: qemu-cmd.sh <iso-path> <work-dir> [boot-dir]
#   iso-path    path to the ISO on the machine that will run QEMU
#   work-dir    directory for run-qemu.sh + qcow2 test drives
#   boot-dir    if set, use direct kernel boot from extracted files
#
# Writes <work-dir>/run-qemu.sh and prints its path.

set -Eeuo pipefail

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: qemu-cmd.sh <iso-path> <work-dir> [boot-dir]" >&2
    exit 2
fi

iso="$1"
work_dir="$2"
boot_dir="${3:-}"

MEMORY="${POE2_QEMU_MEM:-4G}"
CPUS="${POE2_QEMU_CPUS:-4}"
QEMU_BIN="$(command -v qemu-system-x86_64)"
RUN_SCRIPT="$work_dir/run-qemu.sh"

BOOT_ARGS=""
INIT_PATH=""
if [ -n "$boot_dir" ]; then
    BOOT_ARGS="-kernel $boot_dir/bzImage -initrd $boot_dir/initrd"
    if [ -f "$boot_dir/init-path" ]; then
        INIT_PATH="$(cat "$boot_dir/init-path")"
    fi
fi

DRIVE_ARGS=""
if [ -f "$work_dir/nvme-test.qcow2" ]; then
    DRIVE_ARGS="$DRIVE_ARGS -drive file=$work_dir/nvme-test.qcow2,if=none,id=nvme0,format=qcow2"
    DRIVE_ARGS="$DRIVE_ARGS -device nvme,serial=poe2nvme0,drive=nvme0"
fi
if [ -f "$work_dir/sata-test.qcow2" ]; then
    DRIVE_ARGS="$DRIVE_ARGS -device ahci,id=ahci0"
    DRIVE_ARGS="$DRIVE_ARGS -drive file=$work_dir/sata-test.qcow2,if=none,id=sata0,format=qcow2"
    DRIVE_ARGS="$DRIVE_ARGS -device ide-hd,drive=sata0,bus=ahci0.0"
fi

# Write the script with a heredoc for -append to preserve spaces
# without multi-layer quoting issues.
cat >"$RUN_SCRIPT" <<QEOF
#!/usr/bin/env bash
$QEMU_BIN \\
    -enable-kvm -cpu host \\
    -m $MEMORY -smp $CPUS \\
    -display none -serial stdio -monitor none -no-reboot \\
    -cdrom $iso \\
    $BOOT_ARGS \\
    -append "init=$INIT_PATH boot.shell_on_fail root=LABEL=nixos-minimal-25.11-x86_64 console=tty0 console=ttyS0,115200n8 loglevel=4" \\
    $DRIVE_ARGS \\
    -audiodev none,id=noaudio -device intel-hda -device hda-output,audiodev=noaudio \\
    -net nic,model=virtio-net-pci -net user
QEOF
chmod +x "$RUN_SCRIPT"

echo "$RUN_SCRIPT"
