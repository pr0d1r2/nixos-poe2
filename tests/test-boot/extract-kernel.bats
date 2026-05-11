#!/usr/bin/env bats

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
