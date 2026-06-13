#!/usr/bin/env bats
#
# Unit coverage for pkgs/poe2-resolve-exe.sh -- resolves which PathOfExile.exe
# the launch loop should run: the self-patching HOME copy when present, else
# the installer's frozen Program Files bootstrap.

setup() {
    TMP="$(mktemp -d)"
    HOME_EXE="$TMP/live/PathOfExile.exe"
    BOOT_EXE="$TMP/bootstrap/PathOfExile.exe"
    mkdir -p "$TMP/live" "$TMP/bootstrap"
}

teardown() {
    rm -rf "$TMP"
}

resolve() {
    bash pkgs/poe2-resolve-exe.sh "$HOME_EXE" "$BOOT_EXE"
}

@test "script is valid bash" {
    run bash -n pkgs/poe2-resolve-exe.sh
    [ "$status" -eq 0 ]
}

@test "prefers HOME copy when both exist" {
    : >"$HOME_EXE"
    : >"$BOOT_EXE"
    run resolve
    [ "$status" -eq 0 ]
    [ "$output" = "$HOME_EXE" ]
}

@test "uses HOME copy when only HOME exists" {
    : >"$HOME_EXE"
    run resolve
    [ "$status" -eq 0 ]
    [ "$output" = "$HOME_EXE" ]
}

@test "falls back to bootstrap when only bootstrap exists" {
    : >"$BOOT_EXE"
    run resolve
    [ "$status" -eq 0 ]
    [ "$output" = "$BOOT_EXE" ]
}

@test "exits non-zero when neither exists" {
    run resolve
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}
