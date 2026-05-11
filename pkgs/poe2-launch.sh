#!/usr/bin/env bash
# poe2-launch: prepare a Wine prefix, run the GGG installer (first time)
#              or launch the game (subsequent boots).
#
# Storage is mounted by systemd (storage-nvme-mount / storage-sata-mount)
# and linked at /mnt/storage by storage-link. This script consumes it.
#
# Runs inside an X session started by ~/.xinitrc. Stdout/stderr go to
# ~/.xinit.log on the live USB; persistent logs land on the host's
# storage partition once storage is available.
#
# Bail-out behaviour: any fatal error prints a message, waits 30 s so the
# user can read it, then exits -- at which point the X session ends and
# control returns to the TTY where the user can investigate.

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
GAME_ID="umu-poe2"
GAME_DIR_NAME="poe2"
MOUNT="/mnt/storage"
ROOT="$MOUNT/$GAME_DIR_NAME"
PREFIX="$ROOT/prefix"
INSTALLER_DIR="$ROOT/installer"
INSTALLER_EXE="$INSTALLER_DIR/PathOfExile2Installer.exe"
GAME_EXE_REL="drive_c/Program Files (x86)/Grinding Gear Games/Path of Exile 2/PathOfExile.exe"
GAME_EXE="$PREFIX/$GAME_EXE_REL"

LOG_TMP="/tmp/poe2-launch-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_TMP") 2>&1

echo "=== poe2-launch starting at $(date -Iseconds) ==="
echo "host: $(uname -a)"

info() { printf '\n[INFO]  %s\n' "$*"; }
warn() { printf '\n[WARN]  %s\n' "$*" >&2; }

fatal() {
    printf '\n[FATAL] %s\n' "$*" >&2
    printf '\nLog: %s\n' "$LOG_TMP" >&2
    printf '\nClosing in 30 s -- switch to tty2 (Ctrl+Alt+F2) for a shell.\n' >&2
    sleep 30
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Verify storage is mounted (systemd handles detection + mount).
# ---------------------------------------------------------------------------
if [[ ! -L "$MOUNT" ]] || [[ ! -d "$MOUNT" ]]; then
    fatal "No storage available at $MOUNT.

The storage-link service did not find any mounted tier.
Ensure the host has a storage partition on an NVMe or SATA disk.
The expected filesystem type is configured via 'just config' (default: ext4).

From tty2 (Ctrl+Alt+F2):
    sudo mkfs.ext4 -L storage /dev/<your-partition>
Then reboot."
fi

real_mount=$(readlink -f "$MOUNT")
info "Storage: $MOUNT -> $real_mount"

# ---------------------------------------------------------------------------
# 2. Prepare directory tree (idempotent).
# ---------------------------------------------------------------------------
mkdir -p "$ROOT" "$INSTALLER_DIR" "$PREFIX" "$ROOT/logs" "$ROOT/shader-cache"

PERSIST_LOG="$ROOT/logs/poe2-launch-$(date +%Y%m%d-%H%M%S).log"
cp "$LOG_TMP" "$PERSIST_LOG"
exec > >(tee -a "$PERSIST_LOG") 2>&1
info "Logging to $PERSIST_LOG"

# ---------------------------------------------------------------------------
# 3. umu / Proton environment.
# ---------------------------------------------------------------------------
export WINEPREFIX="$PREFIX"
export GAMEID="$GAME_ID"

ge_dir=$(find /run/current-system/sw/share/steam/compatibilitytools.d \
    -maxdepth 1 -type d -name 'GE-Proton*' 2>/dev/null | sort -V | tail -n1 || true)
if [[ -n $ge_dir ]]; then
    export PROTONPATH="$ge_dir"
    info "Proton: $PROTONPATH"
else
    export PROTONPATH="GE-Proton"
    warn "Bundled GE-Proton not found; umu will try to fetch one."
fi

export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$ROOT/shader-cache"
export PROTON_ENABLE_NVAPI=1

# ---------------------------------------------------------------------------
# 4. First-run prefix init.
# ---------------------------------------------------------------------------
if [[ ! -f "$PREFIX/system.reg" ]]; then
    info "Initializing Wine prefix (first run, ~30 s)..."
    umu-run "" || true
fi

# ---------------------------------------------------------------------------
# 5. Wait for installer if game not installed yet.
# ---------------------------------------------------------------------------
HOSTNAME="$(hostname).local"
while [[ ! -f "$GAME_EXE" ]]; do
    while [[ ! -f "$INSTALLER_EXE" ]]; do
        info "Waiting for installer at $INSTALLER_EXE

Upload it from your dev machine:

    just upload

Or manually:

    scp PathOfExile2Installer.exe player@${HOSTNAME}:${INSTALLER_EXE}

Checking every 10 s..."
        sleep 10
    done

    info "Running GGG installer.

You will see the standard PoE 2 setup dialog. Accept the default install
path -- it lives inside the Wine prefix and the launcher knows where to
find the game. The actual ~100 GB game download starts after install."

    umu-run "$INSTALLER_EXE" || warn "Installer exited non-zero."

    if [[ ! -f "$GAME_EXE" ]]; then
        warn "Game exe not found after installer. Retrying in 5 s..."
        sleep 5
    fi
done

# ---------------------------------------------------------------------------
# 6. Launch the game (restart on exit/crash).
# ---------------------------------------------------------------------------
while true; do
    info "Launching Path of Exile 2..."
    gamemoderun umu-run "$GAME_EXE" || warn "Game exited non-zero."
    info "Game exited. Restarting in 5 s... (Ctrl+Alt+F2 for shell)"
    sleep 5
done
