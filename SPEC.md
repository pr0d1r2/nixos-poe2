# SPEC — nixos-poe2

## §G — Goal

Bootable NixOS USB pendrive. Turns any Ryzen/RTX or AMD GPU host into PoE 2 console appliance. TTY autologin → minimal X → game. No desktop, no Steam, no display manager. Stick is stateless — game data lives on host's largest ext4 partition.

## §C — Constraints

- C1: NixOS flake, minimal installer ISO base (`installation-cd-minimal.nix`), pinned to `nixos-25.11`
- C2: GPU: NVIDIA proprietary + AMD amdgpu/Mesa in single ISO, auto-detected at boot
- C3: AMD Ryzen CPU (Zen 2 target, microcode updates on)
- C4: no DE, no DM, no browser, no file manager — single-purpose gaming appliance
- C5: storage tiers: NVMe > SATA, largest ext4 wins per tier, symlinked to `/mnt/storage`
- C5a: no USB storage — pendrive is stateless, never game storage
- C6: Wine/Proton via umu-launcher + proton-ge-bin — no Steam client
- C6a: Proton-GE version determined by nixpkgs pin — override via `proton-ge-bin.override` if PoE 2 compat regresses
- C7: GGG installer `.exe` baked into ISO at build time (not committed to repo)
- C8: stateless pendrive — all mutable state on host ext4 partition
- C9: `linuxPackages_latest` for NVIDIA + Wine compat
- C10: 32-bit graphics libs enabled (Wine requires)
- C11: PipeWire for audio (no PulseAudio daemon)
- C12: build on macOS via `nix-builder.local` (NixOS ISO requires native x86_64-linux)
- C13: builder needs significant resources — NVIDIA driver compilation + full ISO closure
- C14: shell scripts: no functions (except logging helpers in allowlist), extract to separate scripts, prepend `bash` on invocation
- C15: nix modules: no embedded shell, extract to `fragments/` scripts
- C16: TDD — every implementation file covered 1-to-1 with bats unit test
- C17: justfile lowercase, default lists all, alpha order, extract shell to scripts
- C18: portable dev tooling — macOS (dev) + Linux (build/run)
- C19: no credentials or personal data in repo or ISO
- C20: internet required — PoE 2 is online-only, first boot downloads ~100 GB game data
- C21: player password configurable at build time via `config/user/password` — empty by default (autologin appliance)
- C22: locale/keyboard/timezone configurable at build time via `config/user/` files, sensible defaults (`just config`)
- C23: minimum 32 GB RAM — no swap, PoE 2 is memory-heavy, boot refuses on <32 GB
- C24: no sleep/suspend/DPMS — gaming box must never power-manage mid-session
- C25: NTP time sync enabled — game auth requires accurate clock
- C26: mangohud available for FPS/GPU overlay diagnostics, winetricks for Wine tuning
- C27: NVIDIA modesetting enabled — required for Vulkan/DRM on proprietary driver
- C28: flake.lock committed — reproducible builds across machines
- C29: ISO size budget ~3 GB (dual GPU + NVIDIA driver) — monitor for closure bloat
- C30: single-purpose appliance — CPU mitigations off, performance governor, no watchdog
- C31: ext4 game partition mounted `noatime` — reduce write I/O during gameplay
- C32: Proton/Wine perf env vars: DXVK_ASYNC, fsync, large address aware
- C33: kernel/sysctl tuned for gaming: transparent hugepages, swappiness=1, TCP BBR
- C34: stable machine-id across boots — deterministic from seed `nixos-poe2`, baked into ISO
- C35: Proton compat data at `/mnt/storage/poe2/Steam-compat-data` — login tokens persist across reboots
- C36: Mumble voice chat — client only, ~30MB RAM, no Electron

### Build time estimates

| scenario | time | reason |
|---|---|---|
| cold builder, no cache | 45-90 min | NVIDIA driver compile + full closure |
| warm cache, code change only | 5-15 min | only changed derivations rebuild |
| no code change (SHA match) | 0 min | build.sh skips, ISO already exists |
| remote build from macOS | +2-5 min | rsync + SSH overhead |

## §I — Interfaces

- I.boot: NixOS minimal ISO, UEFI + BIOS hybrid boot
- I.boot-escape: hold Shift during TTY autologin → skip startx, stay at shell (boot loop protection)
- I.build: `just build` → `scripts/build/build.sh` → versioned ISO with SHA in filename
- I.burn: `just burn` → `scripts/burn/burn.sh` → interactive USB+ISO picker, remote burn via nix-builder.local
- I.version: ISO naming `nixos-poe2-<REL>-<DATE>-<TIME>-<SHA7>-x86_64-linux.iso`
- I.tty: `player` user autologin on tty1, tty2+ = diagnostic shell
- I.x11: startx from `.bash_profile` → openbox + xset → `poe2-launch`
- I.launch: `poe2-launch` script — consumes `/mnt/storage`, prefix init, installer/game
- I.storage: `/mnt/storage/poe2/{prefix,installer,logs,shader-cache,Steam-compat-data}` on host ext4
- I.storage-tiers: systemd oneshots mount NVMe → `/mnt/storage-nvme`, SATA → `/mnt/storage-sata`; `storage-link` symlinks `/mnt/storage` → fastest
- I.installer-bake: `pkgs/installer/PathOfExile2Installer.exe` → Nix store → ISO
- I.sudo: narrow allowlist — mkdir, chown only, NOPASSWD for `player`
- I.diag: `Ctrl+Alt+F2` → shell; per-launch logs at `/mnt/storage/poe2/logs/`; mangohud overlay for FPS/GPU stats
- I.changelog: `CHANGELOG.md` — grouped by theme, operator-facing, release = ISO burn
- I.reset: `poe2-reset` from tty2 — confirms, wipes prefix (keeps game files), optionally wipes shader cache, reboots
- I.qemu: `just test-boot` → QEMU smoke test on builder — boots ISO, validates TTY autologin, storage detection with virtual ext4 disks, systemd services, network
- I.mumble: Mumble client auto-launched in background, `Super+M` toggles window, config persisted to `/mnt/storage/poe2/mumble/`
- I.devshell: `nix develop` — provides just, bats, shellcheck, pv for dev/build work
- I.password: `config/user/password` → `initialHashedPassword` baked into ISO (empty = passwordless autologin)
- I.locale: `config/user/keymap` (default: `us`), `config/user/timezone` (default: `Europe/Warsaw`), `config/user/locale` (default: `en_US.UTF-8`) — set via `just config`

## §V — Invariants

- V1: ISO boots to game with zero user interaction (after initial install)
- V2: USB disks never used as game storage — excluded from all tier detection
- V3: storage tier preference NVMe > SATA, largest ext4 per tier, deterministic
- V4: build fails with clear error if `pkgs/installer/PathOfExile2Installer.exe` missing
- V5: Wine prefix init is idempotent — re-running creates prefix only if `system.reg` absent
- V6: installer copied from ISO to host partition only if game exe not already present
- V7: fatal errors display console-friendly message (what happened + what to do in plain language) for 30s before X exits to TTY
- V8: X session lifecycle clean — game exit → X exit → TTY return
- V9: shader cache persists across reboots (on host partition)
- V10: no secrets, no SSH keys, no remote access — console-only appliance
- V11: `.exe` files excluded from git via `.gitignore`
- V12: sudo allowlist minimal — only mkdir/chown, no blanket NOPASSWD
- V13: Proton-GE bundled in ISO; fallback to umu fetch if not found
- V14: directory tree creation idempotent — mkdir -p, chown on every boot
- V15: ISO filename embeds git SHA — dirty tree builds refused
- V16: burn refuses if ISO larger than target USB device
- V17: nix modules independent — no cross-module dependencies, extract common parts
- V18: shell fragments have no functions — logging helpers (`info`, `warn`, `fatal`) exempted via `.shell-functions-allowlist`
- V19: every shell script has 1-to-1 bats test file at reflective path
- V20: NixOS user uid/gid unique and numerically equal per user
- V21: storage-link failure → launch script shows console-friendly fatal ("No game drive found. This pendrive needs a formatted disk...")
- V22: firewall enabled, outbound-only — no inbound ports, game traffic is outbound
- V23: network required at runtime — fatal with helpful message if no connectivity when game needs it
- V24: player password configurable via `config/user/password` — empty default suits autologin appliance
- V25: both NVIDIA and AMD GPUs supported in single ISO — X tries nvidia first, falls back to amdgpu
- V26: launch script checks ≥120 GB free on storage partition before first install — fatal with console-friendly message if insufficient
- V27: NTP enabled (systemd-timesyncd) — accurate clock for game auth
- V28: boot loop protection — `.bash_profile` checks for Shift key held, skips startx if pressed
- V29: no sleep/suspend/hibernate — DPMS off, systemd sleep targets masked
- V30: locale/keymap/timezone read from `config/user/` files at build time, sensible defaults if absent
- V31: boot refuses with console-friendly fatal if host has <32 GB RAM
- V32: NVIDIA modesetting enabled — required for Vulkan compositor and DRM
- V33: flake.lock committed and tracked — reproducible builds
- V34: CPU governor locked to `performance` — no dynamic scaling on gaming-only box
- V35: kernel mitigations off (`mitigations=off`) — single-user appliance, no multi-tenant risk
- V36: ext4 game partition mounted with `noatime` — no access-time writes during gameplay
- V37: DXVK async shader compilation enabled — reduces stutter on first encounter
- V38: TCP BBR congestion control — faster game download on first boot
- V39: machine-id stable across boots — `a15d0224aec0dee8a812d0f34370c7d2` derived from `echo -n "nixos-poe2" | md5sum`
- V40: `STEAM_COMPAT_DATA_PATH` points to `/mnt/storage/poe2/Steam-compat-data` — umu-launcher writes Proton state there
- V41: Proton compat data dir created by systemd before game launch — player-owned, on fastest storage tier
- V42: Mumble client launches in background alongside game — does not block game startup or restart loop
- V43: Mumble config (`~/.config/Mumble/`) persisted to `/mnt/storage/poe2/mumble/` — server bookmarks + client cert survive reboot
- V44: `Super+M` keybind toggles Mumble window focus — game remains primary window

## §T — Tasks

| id  | st | description                                                    | cites        |
|-----|----|----------------------------------------------------------------|--------------|
| T1  | x  | flake.nix: ISO builder + installer bake-in + eval-time check   | C1,C7,V4     |
| T2  | x  | modules/hardware.nix: NVIDIA + Ryzen + kernel + graphics       | C2,C3,C9,C10 |
| T3  | x  | modules/users.nix + base.nix + audio.nix: player user, TTY autologin, X stack, PipeWire | C4,C11,I.tty,I.x11 |
| T4  | x  | modules/poe2.nix: umu-launcher, proton-ge, sudo allowlist      | C6,I.sudo,V12 |
| T5  | x  | pkgs/poe2-launch.sh: consume /mnt/storage, prefix, install, launch | V1,V4-V9,V13,V14,I.launch |
| T5a | x  | modules/storage/{nvme,sata,link}.nix + fragments/storage-*.sh  | C5,C5a,V2,V3,I.storage-tiers |
| T6  | x  | .gitignore: exe exclusion, nix outputs, editor noise           | V11          |
| T7  | x  | pkgs/installer/README.md: how to obtain GGG installer          | C7           |
| T8  | x  | scripts/build/*: versioned ISO build, local+remote, SHA skip   | C12,I.build,I.version,V15 |
| T8a | x  | scripts/burn/*: interactive USB+ISO picker, remote burn, pv    | I.burn,V16   |
| T8b | _  | justfile: build, burn, reset recipes wiring scripts            | C17,I.build,I.burn,I.reset |
| T9  | x  | CLAUDE.md + agent/set/*: project docs + conventions for AI agents | C12          |
| T10 | _  | tests/unit/*: bats 1-to-1 coverage for all shell scripts       | C16,V19      |
| T11 | x  | flake devShells: macOS + Linux with just, bats, shellcheck, pv + nix/dev/shell.sh | C18,I.devshell |
| T12 | x  | CHANGELOG.md: initial release notes                            | I.changelog  |
| T13 | x  | README.md: architecture + dev architecture diagrams            | C18          |
| T14 | _  | hardware.nix: dual GPU (NVIDIA+AMD), auto-detect via videoDrivers order | C2,V25,V32 |
| T15 | _  | pkgs/poe2-reset.sh: interactive prefix wipe + optional cache wipe + reboot | I.reset |
| T16 | _  | users.nix: player password via config/user/password file             | C21,V24,I.password |
| T17 | x  | poe2-launch.sh: console-friendly error messages for non-tech users | V7,V21,V23,V26,V31 |
| T18 | x  | .shell-functions-allowlist: exempt poe2-launch.sh logging helpers | C14,V18 |
| T19 | x  | poe2.nix: firewall invariant — enabled, outbound-only          | V22          |
| T20 | _  | poe2-launch.sh: disk space check ≥120 GB before first install  | V26          |
| T21 | x  | base.nix: NTP via systemd-timesyncd                            | C25,V27      |
| T22 | _  | base.nix: boot loop escape — Shift key skips startx            | V28,I.boot-escape |
| T23 | x  | gaming.nix: mask sleep/suspend/hibernate targets               | C24,V29      |
| T24 | x  | base.nix: locale/keymap/timezone via config/user/ files        | C22,V30,I.locale |
| T25 | _  | poe2-launch.sh: RAM check ≥32 GB, console-friendly fatal      | C23,V31      |
| T26 | x  | docs: document mangohud overlay, winetricks, Proton-GE override | C6a,C26 |
| T27 | x  | .envrc: use flake + watch_file entries for fragments           | C18          |
| T28 | x  | .markdownlint.jsonc: markdown linting configuration            | C18          |
| T29 | x  | .yamllint.yml: YAML linting configuration                      | C18          |
| T30 | x  | users.nix: assign explicit uid/gid to player user              | V20          |
| T39 | x  | lefthook.yml: all 33 nix-lefthook-* hooks as remotes + flake inputs | C16,C17,C14,C15,C19 |
| T40 | x  | scripts/test-boot/*: QEMU smoke test — boot ISO, virtual ext4 disks, validate services | I.qemu |
|     |    | **— post-release: performance hardening —**                    |              |
| T31 | _  | hardware.nix: `mitigations=off nowatchdog` kernel params       | C30,V35      |
| T32 | _  | hardware.nix: CPU governor `performance` via cpufreq           | C30,V34      |
| T33 | _  | storage/*.nix: mount ext4 with `noatime`                       | C31,V36      |
| T34 | _  | poe2.nix: Proton/Wine perf env vars (DXVK_ASYNC, fsync, large address) | C32,V37 |
| T35 | _  | hardware.nix: sysctl gaming tuning (swappiness=1, THP=always, BBR) | C33,V38  |
| T36 | _  | hardware.nix: I/O scheduler `none` for NVMe devices            | C33          |
| T37 | _  | hardware.nix: disable kernel printk console spam               | C30          |
| T38 | _  | evaluate linuxPackages_xanmod/zen as gaming kernel alternative | C9,C30       |
|     |    | **— post-release: integration testing —**                      |              |
| T41 | _  | QEMU + VFIO: GPU passthrough smoke test (requires second GPU on builder) | I.qemu |
| T42 | _  | QEMU + VFIO: NVMe passthrough for real storage tier testing    | I.qemu       |
|     |    | **— pre-release: open-source prep —**                          |              |
| T43 | x  | Squash repo to single commit for public release (backup pre-squash branch) | C19 |
| T44 | _  | Git LFS for demo MP4 asset (doc/demo/*.mp4) — after GitHub repo created | C29 |
| T45 | x  | GitHub Actions CI green: add git to CI devShell, verify all hooks pass | C16,C17 |
|     |    | **— login persistence —**                                      |              |
| T46 | x  | modules/machine-id.nix: stable machine-id baked into ISO       | C34,V39      |
| T47 | x  | modules/storage/proton.nix: systemd service creating Steam-compat-data dir | C35,V41 |
| T48 | x  | pkgs/poe2-launch.sh: export STEAM_COMPAT_DATA_PATH             | C35,V40      |
| T49 | x  | tests: bats coverage for machine-id, proton storage, launch env | C16,V19      |
|     |    | **— voice chat —**                                             |              |
| T50 | x  | modules/mumble.nix: mumble package + storage persistence       | C36,V43,I.mumble |
| T51 | x  | modules/base.nix: background-launch Mumble from .xinitrc       | V42,I.mumble |
| T52 | x  | modules/mumble.nix: Openbox keybind Super+M toggle Mumble      | V44,I.mumble |
| T53 | x  | tests: bats coverage for mumble module + launch integration     | C16,V19      |

## §B — Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2025-05-09 | poe2-launch.sh uses shell functions (info/warn/fatal) | T18: add .shell-functions-allowlist for logging helpers |
| B2 | 2025-05-09 | player has hardcoded initialPassword="poe2" | changed to empty password (autologin appliance); T16: optional config/user/password |
| B3 | 2025-05-09 | hardware.nix NVIDIA-only — AMD GPU hosts can't boot | T14: dual GPU support in single ISO |
| B4 | 2025-05-09 | no disk space check — install can fail after hours of download | T20: check ≥120 GB free before install |
| B5 | 2025-05-09 | no NTP — game auth may fail with clock drift | **fixed** T21: systemd-timesyncd in base.nix |
| B6 | 2025-05-09 | no boot loop protection — crash→reboot→crash cycle | T22: Shift key escape hatch in .bash_profile |
| B7 | 2025-05-09 | locale/keymap/timezone hardcoded to pl/Warsaw | **fixed** T24: config/user/ files via just config |
| B8 | 2025-05-09 | no RAM floor check — low RAM hosts crash unpredictably | T25: check ≥32 GB, console-friendly fatal |
| B9 | 2025-05-09 | flake.lock not committed | **fixed** flake.lock committed and tracked |
| B10 | 2025-05-09 | player user has no explicit uid/gid — dynamic allocation violates V20 | **fixed** T30: uid=1000/gid=1000 in users.nix |
