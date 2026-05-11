#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/config"
    cp scripts/config/configure.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/prompt-setting.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/read-existing.sh "$TEST_DIR/scripts/config/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "creates config directory" {
    printf "Europe/Warsaw\nen_US.UTF-8\nus\next4\n" | bash "$TEST_DIR/scripts/config/configure.sh"
    [ -d "$TEST_DIR/config/user" ]
}

@test "saves all four settings" {
    printf "Europe/Warsaw\nen_US.UTF-8\nus\next4\n" | bash "$TEST_DIR/scripts/config/configure.sh"
    [ "$(cat "$TEST_DIR/config/user/timezone")" = "Europe/Warsaw" ]
    [ "$(cat "$TEST_DIR/config/user/locale")" = "en_US.UTF-8" ]
    [ "$(cat "$TEST_DIR/config/user/keymap")" = "us" ]
    [ "$(cat "$TEST_DIR/config/user/fstype")" = "ext4" ]
}

@test "uses defaults when input is empty" {
    printf "\n\n\n\n" | bash "$TEST_DIR/scripts/config/configure.sh"
    [ "$(cat "$TEST_DIR/config/user/timezone")" = "Europe/Warsaw" ]
    [ "$(cat "$TEST_DIR/config/user/locale")" = "en_US.UTF-8" ]
    [ "$(cat "$TEST_DIR/config/user/keymap")" = "us" ]
    [ "$(cat "$TEST_DIR/config/user/fstype")" = "ext4" ]
}
