[private]
default:
    @just --list --list-prefix "    just "

# Build ISO (skips if SHA already built).
build: config _build-or-skip

# Burn HEAD ISO to USB (skips if SHA already burned).
burn: smoke _burn-auto-and-mark

# Full chain: config, build, smoke, burn -- no prompts.
burn-confirmed: smoke _burn-confirmed-and-mark

# Configure user preferences (skips if complete).
config:
    bash scripts/config/ensure.sh

# Run nix garbage collection on builder node.
gc:
    bash scripts/gc/gc.sh

# Manage audio mixing levels on live node via SSH.
mixer:
    bash scripts/mixer/mixer.sh

# Force rebuild ISO for current SHA.
rebuild: config
    bash scripts/build/build.sh

# Burn any ISO to USB (interactive ISO picker).
reburn:
    bash scripts/burn/burn.sh

# Reconfigure all user preferences.
reconfig:
    bash scripts/config/configure.sh

# Record demo GIF of just burn-confirmed.
record-demo: gc
    bash scripts/record/demo.sh

# Force re-run smoke test for current SHA.
resmoke: build
    bash scripts/test-boot/test-boot.sh && bash scripts/test-boot/smoke-mark.sh

# QEMU smoke test (skips if SHA already passed).
smoke: build _smoke-or-skip

# Upload GGG installer to booted node.
upload:
    bash scripts/upload/installer.sh

[private]
_build-or-skip:
    bash scripts/build/build-check.sh || bash scripts/build/build.sh

[private]
_burn-auto-and-mark:
    bash scripts/burn/burn-check.sh || (bash scripts/burn/burn-auto.sh && bash scripts/burn/burn-mark.sh)

[private]
_burn-confirmed-and-mark:
    bash scripts/burn/burn-check.sh || (bash scripts/burn/burn-confirmed.sh && bash scripts/burn/burn-mark.sh)

[private]
_smoke-or-skip:
    bash scripts/test-boot/smoke-check.sh || (bash scripts/test-boot/test-boot.sh && bash scripts/test-boot/smoke-mark.sh)
