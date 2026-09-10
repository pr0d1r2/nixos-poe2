#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/test-boot/grub-param.sh"
    TEST_DIR="$(mktemp -d)"
    CFG="$TEST_DIR/grub.cfg"
    cat >"$CFG" <<'EOF'
set timeout=10
menuentry 'NixOS 26.05 Installer ' --class installer {
  # Fallback to UEFI console for boot, efifb sometimes has difficulties.
  terminal_output console
  linux /boot/bzImage ${isoboot} init=/nix/store/aaaa-nixos-system-nixos-26.05/init xroot=decoy root=LABEL=nixos-minimal-26.05-x86_64 boot.shell_on_fail
  initrd /boot/initrd
}
menuentry 'NixOS 26.05 Installer (nomodeset)' --class nomodeset {
  linux /boot/bzImage ${isoboot} init=/nix/store/bbbb-other/init root=LABEL=second nomodeset
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

@test "exits 2 with usage when key is missing" {
    run bash "$SCRIPT" "$CFG"
    [ "$status" -eq 2 ]
}

@test "exits 1 when grub.cfg does not exist" {
    run bash "$SCRIPT" "$TEST_DIR/missing.cfg" init
    [ "$status" -eq 1 ]
}

@test "prints init path from the first entry" {
    run bash "$SCRIPT" "$CFG" init
    [ "$status" -eq 0 ]
    [ "$output" = "/nix/store/aaaa-nixos-system-nixos-26.05/init" ]
}

@test "prints root value with its LABEL= prefix" {
    run bash "$SCRIPT" "$CFG" root
    [ "$status" -eq 0 ]
    [ "$output" = "LABEL=nixos-minimal-26.05-x86_64" ]
}

@test "does not match a key that is a suffix of another parameter" {
    run bash "$SCRIPT" "$CFG" root
    [ "$output" != "decoy" ]
}

@test "does not treat the initrd line as an init parameter" {
    printf 'initrd /boot/initrd\n' >"$TEST_DIR/only-initrd.cfg"
    run bash "$SCRIPT" "$TEST_DIR/only-initrd.cfg" init
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}

@test "exits 1 and prints nothing when key is absent" {
    run bash "$SCRIPT" "$CFG" nosuch
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}
