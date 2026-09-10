#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    ISO="$TEST_DIR/poe2.iso"
    BOOT="$TEST_DIR/boot"
    mkdir -p "$BOOT"
    touch -t 202001010000 "$ISO"
    touch "$BOOT/bzImage" "$BOOT/initrd"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script is valid bash" {
    run bash -n scripts/test-boot/extract-kernel.sh
    [ "$status" -eq 0 ]
}

@test "exits with error when no arguments" {
    run bash scripts/test-boot/extract-kernel.sh
    [ "$status" -ne 0 ]
}

@test "exits with error when only one argument" {
    run bash scripts/test-boot/extract-kernel.sh /nonexistent.iso
    [ "$status" -ne 0 ]
}

@test "skips when kernel, initrd and cmdline are newer than the ISO" {
    echo "init=/nix/store/x/init root=fstab" >"$BOOT/cmdline"
    run bash scripts/test-boot/extract-kernel.sh "$ISO" "$BOOT"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already extracted" ]]
}

@test "re-extracts when cmdline is missing" {
    echo "LABEL=x" >"$BOOT/root-param"
    run bash scripts/test-boot/extract-kernel.sh "$ISO" "$BOOT"
    [[ ! "$output" =~ "already extracted" ]]
}

@test "reads the kernel command line from grub.cfg through grub-cmdline.sh" {
    grep -qE 'grub-cmdline\.sh.*GRUB_CFG' scripts/test-boot/extract-kernel.sh
}

@test "writes cmdline into the boot dir" {
    grep -q 'BOOT_DIR/cmdline' scripts/test-boot/extract-kernel.sh
}

@test "no longer derives root-param or init-path" {
    run ! grep -qE 'root-param|init-path|grub-param' scripts/test-boot/extract-kernel.sh
}
