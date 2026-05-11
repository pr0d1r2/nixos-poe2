#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/config/user"
    mkdir -p "$TEST_DIR/scripts/config"
    cp scripts/config/ensure.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/check.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/configure.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/prompt-setting.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/read-existing.sh "$TEST_DIR/scripts/config/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "skips configure when all settings present" {
    echo -n "Europe/Warsaw" >"$TEST_DIR/config/user/timezone"
    echo -n "en_US.UTF-8" >"$TEST_DIR/config/user/locale"
    echo -n "us" >"$TEST_DIR/config/user/keymap"
    echo -n "ext4" >"$TEST_DIR/config/user/fstype"
    run bash "$TEST_DIR/scripts/config/ensure.sh"
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "launching configuration" ]]
}

@test "launches configure when settings missing" {
    run bash -c 'printf "Europe/Warsaw\nen_US.UTF-8\nus\next4\n" | bash "'"$TEST_DIR"'/scripts/config/ensure.sh"'
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/config/user/timezone" ]
}
