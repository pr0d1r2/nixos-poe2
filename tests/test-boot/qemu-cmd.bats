#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/bin" "$TEST_DIR/work" "$TEST_DIR/boot"
    printf '#!/bin/sh\nexit 0\n' >"$TEST_DIR/bin/qemu-system-x86_64"
    chmod +x "$TEST_DIR/bin/qemu-system-x86_64"
    ISO_CMDLINE="init=/nix/store/aaaa-nixos-system/init root=fstab loglevel=4 lsm=landlock,yama,bpf"
    echo "$ISO_CMDLINE" >"$TEST_DIR/boot/cmdline"
    RUN="$TEST_DIR/work/run-qemu.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

direct_boot() {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work" "$TEST_DIR/boot"
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

@test "direct boot replays the ISO command line first" {
    direct_boot
    [ "$status" -eq 0 ]
    grep -qF -- "-append \"$ISO_CMDLINE console=" "$RUN"
}

@test "direct boot adds the serial console" {
    direct_boot
    [ "$status" -eq 0 ]
    grep -q 'console=ttyS0,115200n8' "$RUN"
}

@test "direct boot adds no root= of its own" {
    direct_boot
    [ "$status" -eq 0 ]
    [ "$(grep -o 'root=' "$RUN" | wc -l | tr -d ' ')" = "1" ]
}

@test "direct boot hardcodes no ISO volume label" {
    direct_boot
    [ "$status" -eq 0 ]
    run ! grep -q 'nixos-minimal' "$RUN"
}

@test "direct boot fails without cmdline" {
    rm "$TEST_DIR/boot/cmdline"
    direct_boot
    [ "$status" -eq 1 ]
    [[ "$output" =~ "cmdline" ]]
}

@test "cdrom boot passes no kernel command line" {
    PATH="$TEST_DIR/bin:$PATH" run bash scripts/test-boot/qemu-cmd.sh \
        /iso/poe2.iso "$TEST_DIR/work"
    [ "$status" -eq 0 ]
    run ! grep -q -- '-append' "$RUN"
}
