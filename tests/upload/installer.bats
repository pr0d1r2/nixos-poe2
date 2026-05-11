#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/upload" "$TEST_DIR/pkgs/installer"
    cp scripts/upload/installer.sh "$TEST_DIR/scripts/upload/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 when installer exe missing" {
    run bash "$TEST_DIR/scripts/upload/installer.sh"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "missing" ]]
}

@test "prints download URL when exe missing" {
    run bash "$TEST_DIR/scripts/upload/installer.sh"
    [[ "$output" =~ pathofexile2.com/download ]]
}
