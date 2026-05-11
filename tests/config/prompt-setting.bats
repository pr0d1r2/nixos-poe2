#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/config"
    cp scripts/config/prompt-setting.sh "$TEST_DIR/scripts/config/"
    cp scripts/config/read-existing.sh "$TEST_DIR/scripts/config/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "saves user input to file" {
    echo "America/New_York" | bash "$TEST_DIR/scripts/config/prompt-setting.sh" \
        "$TEST_DIR/timezone" "Timezone" "Europe/Warsaw"
    [ "$(cat "$TEST_DIR/timezone")" = "America/New_York" ]
}

@test "uses default when input is empty" {
    echo "" | bash "$TEST_DIR/scripts/config/prompt-setting.sh" \
        "$TEST_DIR/timezone" "Timezone" "Europe/Warsaw"
    [ "$(cat "$TEST_DIR/timezone")" = "Europe/Warsaw" ]
}

@test "uses existing value when input is empty" {
    echo -n "Asia/Tokyo" >"$TEST_DIR/timezone"
    echo "" | bash "$TEST_DIR/scripts/config/prompt-setting.sh" \
        "$TEST_DIR/timezone" "Timezone" "Europe/Warsaw"
    [ "$(cat "$TEST_DIR/timezone")" = "Asia/Tokyo" ]
}

@test "overwrites existing value with new input" {
    echo -n "Asia/Tokyo" >"$TEST_DIR/timezone"
    echo "Europe/Berlin" | bash "$TEST_DIR/scripts/config/prompt-setting.sh" \
        "$TEST_DIR/timezone" "Timezone" "Europe/Warsaw"
    [ "$(cat "$TEST_DIR/timezone")" = "Europe/Berlin" ]
}

@test "exits 1 when no input no default no existing" {
    run bash -c 'echo "" | bash "'"$TEST_DIR"'/scripts/config/prompt-setting.sh" "'"$TEST_DIR"'/timezone" "Timezone" ""'
    [ "$status" -eq 1 ]
}
