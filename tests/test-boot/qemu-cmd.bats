#!/usr/bin/env bats

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
