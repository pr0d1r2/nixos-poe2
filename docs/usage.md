# Usage

## Boot flow

1. NixOS minimal ISO boots, autologs `player` into a TTY.
2. `.bash_profile` execs `startx`, which runs `~/.xinitrc`.
3. `.xinitrc` starts `openbox` (just to make installer sub-dialogs movable),
   disables screensaver/DPMS, and execs the launcher.
4. The launcher:
   - Excludes the live USB and any USB-transport disk.
   - Picks the **largest partition** (matching configured filesystem type) on the remaining disks.
   - Mounts it at `/mnt/storage`.
   - Creates `/mnt/storage/poe2/{prefix,installer,logs,shader-cache}`.
   - If `PathOfExile.exe` is in the prefix → launches it via
     `gamemoderun umu-run`.
   - Else copies the **baked-in** installer from
     `/run/current-system/sw/share/poe2-installer/` to the host
     partition, runs it, then launches the game.
5. When the game exits or crashes, the launcher restarts it after 5 s.
   The installer also retries until the game files exist.

No browser. No file picker. No Steam. The closure is roughly half the size
of a full Plasma image.

## Installing the game

The ISO contains no proprietary software. On first boot, the launcher
waits for you to upload the GGG installer:

```sh
# From your dev machine, with the node booted:
just upload
```

This SCPs `pkgs/installer/PathOfExile2Installer.exe` to the live node.
The launcher detects it and runs the installer automatically.

To get the installer:

1. Open <https://pathofexile2.com/download> in a browser.
2. Log into your GGG account.
3. Click **Standalone Client** → **PC**, save the `.exe`.
4. Place it at `pkgs/installer/PathOfExile2Installer.exe`.

The `.exe` is gitignored and never embedded in the ISO.
See `pkgs/installer/README.md` for more.

## Preparing the host

The launcher needs a partition matching the configured filesystem type
(default: ext4). If you don't have one, create one:

```sh
# DESTRUCTIVE — wipes data on the chosen partition.
sudo mkfs.ext4 -L games /dev/nvme0n1pX
```

It's fine to share the partition with other Linux data; the launcher only
writes inside `poe2/` and never touches the rest.

## Diagnostics

- `Ctrl+Alt+F2` from the boot session → fresh TTY with a shell.
- Per-launch logs on the host partition under `/mnt/storage/poe2/logs/`.
- The pre-mount log lives at `~/.xinit.log` on the live system.
- **MangoHud** is installed for FPS/GPU/CPU overlay. Launch with
  `MANGOHUD=1 gamemoderun umu-run ...` from tty2 for performance debugging.
- **winetricks** is available for Wine prefix tuning from tty2.

## Boot loop protection

If the game crashes repeatedly, hold **Shift** during TTY autologin to
skip X and stay at the shell. From there you can inspect logs, reset the
prefix, or investigate.

## Reset / recovery

If the prefix breaks (rare, usually after a botched GGG patch):

```sh
# From tty2:
rm -rf /mnt/storage/poe2/prefix
reboot
```

Next boot will re-run the cached installer (no 100 GB re-download — the
installer just rebuilds the prefix and re-verifies the existing game files).

## Why ext4 by default

- Mountable by the minimal ISO without extra kernel modules.
- No NTFS quirks (xattrs, reserve files) that bite Wine prefixes.
- Stable across reboots and host swaps.

To use btrfs or xfs, run `just reconfig` and set the storage filesystem
preference, then rebuild the ISO.

## Storage layout

```
/mnt/storage/poe2/
├── installer/PathOfExile2Installer.exe   # copied on first boot from the ISO
├── prefix/                                # Wine prefix
│   └── drive_c/Program Files (x86)/Grinding Gear Games/Path of Exile 2/
│       └── PathOfExile.exe
├── shader-cache/                          # NVIDIA disk shader cache
└── logs/                                  # one log file per launch
```

## Hardware notes

- **GPU**: both NVIDIA proprietary and AMD (amdgpu/Mesa) drivers ship in a
  single ISO. X tries NVIDIA first, falls back to amdgpu automatically.
  NVIDIA modesetting is enabled for Vulkan/DRM support.
- **Multi-monitor**: X defaults to clone mode — all connected displays
  mirror the same output. No xrandr configuration needed. PoE 2 renders
  on one display; the game does not support multi-monitor spanning.
- **Minimum RAM**: 32 GB. The launcher refuses to start on hosts with less.
- `linuxPackages_latest` is used so recent NVIDIA + recent Wine work.
- AMD CPU microcode updates are on (covers Ryzen 3700X).
- 32-bit graphics libs are enabled (Wine needs them).
- No sleep, suspend, or DPMS — the box never power-manages mid-game.

## Audio

PipeWire creates a **combined sink** that mirrors audio to every connected
output simultaneously — HDMI monitors, analog jack, USB DAC. No manual
switching required: plug in any output and it joins the mix automatically.

- Zero-config: works out of the box, no `pactl` or `wpctl` needed.
- Negligible overhead: PCM buffer copy at 48 kHz stereo, <0.1% CPU.
- If only one output exists, the combined sink passes through transparently.
- Latency compensation is off (gaming priority over multi-room sync).

To check what's playing where: `wpctl status` from tty2.
