#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "uses fake backend when POE2_BURN_FAKE_BACKEND set" {
    printf '/dev/sda|128G|Kingston\n' >"$TEST_DIR/fake-usb"
    run env POE2_BURN_FAKE_BACKEND="$TEST_DIR/fake-usb" bash scripts/burn/list_usb.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "/dev/sda" ]]
    [[ "$output" =~ "Kingston" ]]
}

@test "exits 1 when fake backend is empty" {
    printf '' >"$TEST_DIR/fake-usb"
    run env POE2_BURN_FAKE_BACKEND="$TEST_DIR/fake-usb" bash scripts/burn/list_usb.sh
    [ "$status" -eq 1 ]
    [[ "$output" =~ "No USB" ]]
}

@test "outputs device|size|model format" {
    printf '/dev/sdb|64G|SanDisk Ultra\n' >"$TEST_DIR/fake-usb"
    run env POE2_BURN_FAKE_BACKEND="$TEST_DIR/fake-usb" bash scripts/burn/list_usb.sh
    [ "$status" -eq 0 ]
    IFS='|' read -r dev size model <<<"$output"
    [ "$dev" = "/dev/sdb" ]
    [ "$size" = "64G" ]
    [ "$model" = "SanDisk Ultra" ]
}
