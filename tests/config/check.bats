#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    export REPO_ROOT_OVERRIDE="$TEST_DIR"
    mkdir -p "$TEST_DIR/config/user"
    mkdir -p "$TEST_DIR/scripts/config"
    cp scripts/config/check.sh "$TEST_DIR/scripts/config/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 when all config missing" {
    run bash "$TEST_DIR/scripts/config/check.sh"
    [ "$status" -eq 1 ]
}

@test "exits 1 when timezone missing" {
    echo -n "en_US.UTF-8" >"$TEST_DIR/config/user/locale"
    echo -n "us" >"$TEST_DIR/config/user/keymap"
    run bash "$TEST_DIR/scripts/config/check.sh"
    [ "$status" -eq 1 ]
}

@test "exits 0 when all config present" {
    echo -n "Europe/Warsaw" >"$TEST_DIR/config/user/timezone"
    echo -n "en_US.UTF-8" >"$TEST_DIR/config/user/locale"
    echo -n "us" >"$TEST_DIR/config/user/keymap"
    echo -n "ext4" >"$TEST_DIR/config/user/fstype"
    run bash "$TEST_DIR/scripts/config/check.sh"
    [ "$status" -eq 0 ]
}
