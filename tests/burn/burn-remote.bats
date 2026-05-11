#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/burn" "$TEST_DIR/scripts/lib"
    cp scripts/burn/burn-remote.sh "$TEST_DIR/scripts/burn/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 2 with no arguments" {
    run bash "$TEST_DIR/scripts/burn/burn-remote.sh"
    [ "$status" -eq 2 ]
}

@test "exits 2 when POE2_BURN_LOCAL is set" {
    run env POE2_BURN_LOCAL=1 bash "$TEST_DIR/scripts/burn/burn-remote.sh" "$TEST_DIR"
    [ "$status" -eq 2 ]
}

@test "exits 2 when POE2_BURN_FAKE_BACKEND is set" {
    run env POE2_BURN_FAKE_BACKEND=/dev/null bash "$TEST_DIR/scripts/burn/burn-remote.sh" "$TEST_DIR"
    [ "$status" -eq 2 ]
}
