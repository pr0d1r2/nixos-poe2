#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "prints file contents when file exists" {
    echo -n "Europe/Warsaw" >"$TEST_DIR/timezone"
    run bash scripts/config/read-existing.sh "$TEST_DIR/timezone"
    [ "$status" -eq 0 ]
    [ "$output" = "Europe/Warsaw" ]
}

@test "prints empty when file does not exist" {
    run bash scripts/config/read-existing.sh "$TEST_DIR/nonexistent"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "preserves whitespace in file contents" {
    echo -n "  spaced  " >"$TEST_DIR/spaced"
    run bash scripts/config/read-existing.sh "$TEST_DIR/spaced"
    [ "$status" -eq 0 ]
    [ "$output" = "  spaced  " ]
}
