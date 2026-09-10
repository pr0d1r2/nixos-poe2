#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/test-boot/grub-cmdline.sh"
    TEST_DIR="$(mktemp -d)"
    # systemd-initrd ISO (NixOS 26.05+): root=fstab, media found by label.
    # Params mirror the real 26.05 boot.kernelParams.
    SYSTEMD_CFG="$TEST_DIR/systemd.cfg"
    cat >"$SYSTEMD_CFG" <<'EOF'
set timeout=10
menuentry 'NixOS 26.05 Installer ' --class installer {
  # Fallback to UEFI console for boot, efifb sometimes has difficulties.
  # linux /boot/old init=/nix/store/commented-out/init
  terminal_output console
  linux /boot/bzImage ${isoboot} init=/nix/store/aaaa-nixos-system-poe2-26.05/init root=fstab loglevel=4 lsm=landlock,yama,bpf
  initrd /boot/initrd
}
menuentry 'NixOS 26.05 Installer (copytoram)' --class copytoram {
  linux /boot/bzImage ${isoboot} init=/nix/store/aaaa-nixos-system-poe2-26.05/init root=fstab loglevel=4 lsm=landlock,yama,bpf copytoram
  initrd /boot/initrd
}
menuentry 'Memtest86+' --class debug {
  linux ($root)/boot/memtest.bin
}
EOF
    # scripted-initrd ISO (NixOS 25.11 and earlier): root= by label.
    SCRIPTED_CFG="$TEST_DIR/scripted.cfg"
    cat >"$SCRIPTED_CFG" <<'EOF'
menuentry 'NixOS 25.11 Installer ' --class installer {
	linux /boot/bzImage \${isoboot} init=/nix/store/bbbb-nixos-system-poe2-25.11/init boot.shell_on_fail root=LABEL=nixos-minimal-25.11-x86_64
	initrd /boot/initrd
}
EOF
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script exists and is valid bash" {
    run bash -n "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "exits 2 with usage when no arguments are given" {
    run bash "$SCRIPT"
    [ "$status" -eq 2 ]
    [[ "$output" =~ Usage ]]
}

@test "exits 2 with usage on extra arguments" {
    run bash "$SCRIPT" "$SYSTEMD_CFG" extra
    [ "$status" -eq 2 ]
}

@test "exits 1 when grub.cfg does not exist" {
    run bash "$SCRIPT" "$TEST_DIR/missing.cfg"
    [ "$status" -eq 1 ]
}

@test "prints params of the first linux entry without image or GRUB vars" {
    run bash "$SCRIPT" "$SYSTEMD_CFG"
    [ "$status" -eq 0 ]
    [ "$output" = "init=/nix/store/aaaa-nixos-system-poe2-26.05/init root=fstab loglevel=4 lsm=landlock,yama,bpf" ]
}

@test "passes root=fstab through and adds no root=LABEL (systemd initrd)" {
    run bash "$SCRIPT" "$SYSTEMD_CFG"
    [[ "$output" =~ " root=fstab " ]]
    [[ ! "$output" =~ root=LABEL ]]
}

@test "keeps root= and boot.shell_on_fail when the ISO has them (scripted initrd)" {
    run bash "$SCRIPT" "$SCRIPTED_CFG"
    [ "$status" -eq 0 ]
    [ "$output" = "init=/nix/store/bbbb-nixos-system-poe2-25.11/init boot.shell_on_fail root=LABEL=nixos-minimal-25.11-x86_64" ]
}

@test "drops a backslash-escaped GRUB variable too" {
    run bash "$SCRIPT" "$SCRIPTED_CFG"
    [[ ! "$output" =~ isoboot ]]
}

@test "ignores comment lines that mention linux" {
    run bash "$SCRIPT" "$SYSTEMD_CFG"
    [[ ! "$output" =~ commented-out ]]
}

@test "exits 1 and prints nothing when there is no linux entry" {
    printf 'set timeout=10\ninitrd /boot/initrd\n' >"$TEST_DIR/none.cfg"
    run bash "$SCRIPT" "$TEST_DIR/none.cfg"
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}
