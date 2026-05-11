# nixos-poe2

Bootable NixOS USB — boots straight to Path of Exile 2. No desktop, no Steam.

## Quick reference

- **Spec:** `SPEC.md` (CAVEKIT format)
- **Build:** `just build` or `bash scripts/build/build.sh`
- **Burn:** `just burn` or `bash scripts/burn/burn.sh`
- **Builder:** `nix-builder.local` (remote x86_64-linux)

## Project structure

```
flake.nix                    # ISO builder + installer bake-in
modules/
  audio.nix                  # PipeWire + combined sink (all outputs)
  base.nix                   # Networking, locale, X server, packages
  gaming.nix                 # Gamemode, seed-home, sleep masks, PAM fix
  hardware.nix               # NVIDIA RTX 3090 + Ryzen 3700X
  poe2.nix                   # umu-launcher, proton-ge
  users.nix                  # Player + nixos users, getty autologin
  storage/
    nvme.nix                 # Mount largest NVMe ext4
    sata.nix                 # Mount largest SATA ext4
    link.nix                 # Symlink /mnt/storage → fastest tier
fragments/
  storage-nvme-mount.sh      # NVMe detection script
  storage-sata-mount.sh      # SATA detection script
  storage-mount-target.sh    # Shared mount + log tail
  storage-link.sh            # Tier preference resolver
pkgs/
  poe2-launch.sh             # Game launcher (consumes /mnt/storage)
  installer/                 # Drop PathOfExile2Installer.exe here
scripts/
  build/                     # SHA-versioned ISO build (local + remote)
  burn/                      # Interactive USB+ISO picker + remote burn
```

## Conventions

@agent/set/concepts/hardware.md
@agent/set/concepts/user.md
@agent/set/skills/architecture.md
@agent/set/skills/architecture/development.md
@agent/set/skills/dotfile.md
@agent/set/skills/dx.md
@agent/set/skills/git.md
@agent/set/skills/implementation.md
@agent/set/skills/just.md
@agent/set/skills/just/modularity.md
@agent/set/skills/just/modules.md
@agent/set/skills/justfile.md
@agent/set/skills/nix/flake.md
@agent/set/skills/nix/modularity.md
@agent/set/skills/nixos/security/wrappers.md
@agent/set/skills/nixos/users.md
@agent/set/skills/nixos/users/modularity.md
@agent/set/skills/parallel.md
@agent/set/skills/performance.md
@agent/set/skills/product.md
@agent/set/skills/product/plan.md
@agent/set/skills/portability.md
@agent/set/skills/rtk.md
@agent/set/skills/security.md
@agent/set/skills/security/credentials.md
@agent/set/skills/security/personal.md
@agent/set/skills/sh.md
@agent/set/skills/sh/modularity.md
@agent/set/skills/sh/noexec.md
@agent/set/skills/tdd.md
@agent/set/skills/test/coverage.md
@agent/set/skills/test/unit.md
@agent/set/skills/test/unit/sh.md
@agent/set/skills/ux.md
