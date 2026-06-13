# Changelog

## Unreleased

### Boot and gaming

- Bootable NixOS USB pendrive: TTY autologin, minimal X session, straight to
  game launcher
- Game launcher with installer loop (retries until game files exist) and game
  restart loop (auto-relaunches on exit/crash)
- Patch loop fixed: launcher now follows PoE 2's self-patched client copy in
  the working dir instead of the installer's frozen Program Files copy, so
  game patches apply on restart with no manual intervention (was an infinite
  "Please restart Path of Exile" loop on every game update)
- GGG installer baked into ISO from `pkgs/installer/` via gitignore-aware
  build pipeline
- Wine prefix and game data on host's internal NVMe/SATA ext4 partition
- GE-Proton via umu-launcher, gamemode enabled
- NVIDIA shader disk cache on storage partition

### Storage

- Tiered storage detection: NVMe preferred over SATA, largest ext4 auto-mounted
- `/mnt/storage` symlink to fastest available tier
- Player home bind-mounted from NVMe to avoid filling tmpfs
- Nix store overlay upper/work on NVMe for post-boot package installs
- Storage ownership set at mount time (no sudo in game launcher)

### Audio

- PipeWire with ALSA and PulseAudio compatibility
- Combined sink: mirrors audio to all connected outputs simultaneously
  (HDMI, analog, USB) with zero config
- 32-bit audio library support for Wine

### Networking and remote access

- SSH with ED25519 key-only auth, permanent host keys baked into ISO
- Avahi mDNS: discoverable as `poe2.local`
- Builder discovery: tries `nix-builder.local` then `poe2.local`

### Hardware

- NVIDIA proprietary + AMD amdgpu drivers in single ISO
- NVIDIA modesetting for Vulkan/DRM
- AMD CPU microcode updates
- 32-bit graphics libraries for Wine
- Sleep, suspend, hibernate, DPMS all disabled

### Build and deploy

- SHA-versioned ISO builds (local + remote via `nix-builder.local`)
- Interactive USB burn with disk picker
- Remote burn support
- QEMU smoke test with direct kernel boot
- Expect-based integration test suite

### Developer experience

- Nix flake with devShell for macOS and Linux
- 33 lefthook git hooks for code quality
- Just recipes for build, burn, smoke workflows
- Lefthook install caching for fast shell reload
