#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n scripts/test-boot/create-drives.sh
    [ "$status" -eq 0 ]
}

@test "exits with error when no arguments" {
    run bash scripts/test-boot/create-drives.sh
    [ "$status" -ne 0 ]
}

@test "skips when drives already exist" {
    TEST_DIR="$(mktemp -d)"
    touch "$TEST_DIR/nvme-test.qcow2" "$TEST_DIR/sata-test.qcow2"
    run bash scripts/test-boot/create-drives.sh "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already exist" ]]
    rm -rf "$TEST_DIR"
}
