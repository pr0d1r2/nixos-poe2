#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/bin" "$TEST_DIR/work" "$TEST_DIR/boot"
    printf '#!/bin/sh\nexit 0\n' >"$TEST_DIR/bin/qemu-system-x86_64"
    chmod +x "$TEST_DIR/bin/qemu-system-x86_64"
    echo "/nix/store/aaaa-nixos-system/init" >"$TEST_DIR/boot/init-path"
    echo "LABEL=custom-volume-label" >"$TEST_DIR/boot/root-param"
    RUN="$TEST_DIR/work/run-qemu.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script is valid bash" {
    run bash -n scripts/test-boot/qemu-cmd.sh
    [ "$status" -eq 0 ]
}

@test "exits 2 with no arguments" {
    run bash scripts/test-boot/qemu-cmd.sh
    [ "$status" -eq 2 ]
}

@test "exits 2 with one argument" {
    run bash scripts/test-boot/qemu-cmd.sh /path/to.iso
    [ "$status" -eq 2 ]
}

@test "prints usage on wrong argument count" {
    run bash scripts/test-boot/qemu-cmd.sh
    [[ "$output" =~ "Usage" ]]
}

@test "direct boot takes root= from boot-dir root-param" {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work" "$TEST_DIR/boot"
    [ "$status" -eq 0 ]
    grep -q 'root=LABEL=custom-volume-label ' "$RUN"
}

@test "direct boot takes init= from boot-dir init-path" {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work" "$TEST_DIR/boot"
    [ "$status" -eq 0 ]
    grep -q 'init=/nix/store/aaaa-nixos-system/init ' "$RUN"
}

@test "direct boot hardcodes no ISO volume label" {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work" "$TEST_DIR/boot"
    [ "$status" -eq 0 ]
    run ! grep -q 'nixos-minimal' "$RUN"
}

@test "direct boot fails without root-param" {
    rm "$TEST_DIR/boot/root-param"
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work" "$TEST_DIR/boot"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "root-param" ]]
}

@test "cdrom boot passes no kernel command line" {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work"
    [ "$status" -eq 0 ]
    run ! grep -q -- '-append' "$RUN"
}
