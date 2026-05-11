#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/iso"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 when directory does not exist" {
    run bash scripts/burn/list_isos.sh "$TEST_DIR/nonexistent"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "does not exist" ]]
}

@test "exits 1 when no ISOs in directory" {
    run bash scripts/burn/list_isos.sh "$TEST_DIR/iso"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "No ISOs" ]]
}

@test "lists single ISO" {
    touch "$TEST_DIR/iso/test.iso"
    run bash scripts/burn/list_isos.sh "$TEST_DIR/iso"
    [ "$status" -eq 0 ]
    [ "$output" = "test.iso" ]
}

@test "lists multiple ISOs newest first" {
    touch "$TEST_DIR/iso/old.iso"
    sleep 1
    touch "$TEST_DIR/iso/new.iso"
    run bash scripts/burn/list_isos.sh "$TEST_DIR/iso"
    [ "$status" -eq 0 ]
    first_line="$(echo "$output" | head -n1)"
    [ "$first_line" = "new.iso" ]
}
