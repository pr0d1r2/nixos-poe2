Development and testing hardware for the nixos-poe2 project.

## Development host

MacBook Air M4, 16 GB RAM (aarch64-darwin). Runs the dev shell, editor, and Claude Code. Builds are delegated to the builder via `just build` / `just burn`.

## Builder

Ryzen 3700X (8 cores / 16 threads), 32 GB RAM (x86_64-linux). Serves as `nix-builder.local`. Builds ISOs natively and handles remote USB burns.

## Target gaming host

Ryzen 7 3700X, 32 GB RAM, RTX 3090 (x86_64-linux). Boots the pendrive, runs PoE 2. Internal NVMe or SATA disk with ext4 partition for game storage.

## USB pendrive

Kingston DataTraveler Kyson 128 GB (USB 3.2 Gen 1). Stateless — no persistent data on pendrive, all game data on host's internal disk.

## Network

All nodes connected via 1 Gbit/s Ethernet. Internet 1 Gbit/s (needed for ~100 GB game download on first boot).
