#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/build" "$TEST_DIR/scripts/lib" "$TEST_DIR/iso"
    cp scripts/build/build.sh "$TEST_DIR/scripts/build/"
    cp scripts/build/version.sh "$TEST_DIR/scripts/build/"
    cp scripts/build/iso_store_dir.sh "$TEST_DIR/scripts/build/"
    cd "$TEST_DIR" || return
    git init -q
    git commit --allow-empty -m "init" -q
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 on dirty tree" {
    echo "dirty" >untracked-file
    git add untracked-file
    run bash "$TEST_DIR/scripts/build/build.sh"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "dirty tree" ]]
}

@test "skips build when ISO exists for current SHA" {
    SHORT_SHA="$(git rev-parse --short=7 HEAD)"
    touch "$TEST_DIR/iso/nixos-poe2-25.11-20260511-1430-${SHORT_SHA}-x86_64-linux.iso"
    run bash "$TEST_DIR/scripts/build/build.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already exists" ]]
}
