#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/burn"
    cp scripts/burn/burn-check.sh "$TEST_DIR/scripts/burn/"
    cd "$TEST_DIR" || return
    git init -q
    git commit --allow-empty -m "init" -q
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 when no burn marker exists" {
    run bash "$TEST_DIR/scripts/burn/burn-check.sh"
    [ "$status" -eq 1 ]
}

@test "exits 0 when burn marker exists for current SHA" {
    SHORT_SHA="$(git rev-parse --short=7 HEAD)"
    date -Iseconds >"$TEST_DIR/.burn-done-$SHORT_SHA"
    run bash "$TEST_DIR/scripts/burn/burn-check.sh"
    [ "$status" -eq 0 ]
}

@test "exits 1 when burn marker exists for different SHA" {
    echo "old" >"$TEST_DIR/.burn-done-bbbbbbb"
    run bash "$TEST_DIR/scripts/burn/burn-check.sh"
    [ "$status" -eq 1 ]
}
