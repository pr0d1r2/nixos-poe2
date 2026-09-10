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

@test "skips when kernel, initrd and root-param are newer than the ISO" {
    echo "LABEL=x" >"$BOOT/root-param"
    run bash scripts/test-boot/extract-kernel.sh "$ISO" "$BOOT"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already extracted" ]]
}

@test "re-extracts when root-param is missing" {
    run bash scripts/test-boot/extract-kernel.sh "$ISO" "$BOOT"
    [[ ! "$output" =~ "already extracted" ]]
}

@test "reads init= and root= from grub.cfg through grub-param.sh" {
    grep -qE 'grub-param\.sh.*GRUB_CFG"? init' scripts/test-boot/extract-kernel.sh
    grep -qE 'grub-param\.sh.*GRUB_CFG"? root' scripts/test-boot/extract-kernel.sh
}

@test "writes root-param into the boot dir" {
    grep -q 'BOOT_DIR/root-param' scripts/test-boot/extract-kernel.sh
}
