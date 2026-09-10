#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/build/nixos-release.sh"
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/bin"
    ARGS="$TEST_DIR/args"
    OUT="26.05"
    RC=0
}

teardown() {
    rm -rf "$TEST_DIR"
}

stub_nix() {
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$@" >"%s"\nprintf "%%s" "%s"\nexit %s\n' \
        "$ARGS" "$OUT" "$RC" >"$TEST_DIR/bin/nix"
    chmod +x "$TEST_DIR/bin/nix"
}

@test "script exists and is valid bash" {
    run bash -n "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "prints the release nix reports" {
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "26.05" ]
}

@test "asks for lib.trivial.release of the nixpkgs the repo pins" {
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    grep -qx 'eval' "$ARGS"
    grep -qx -- '--raw' "$ARGS"
    grep -qx -- '--inputs-from' "$ARGS"
    grep -qx "$TEST_DIR" "$ARGS"
    grep -qx 'nixpkgs#lib.trivial.release' "$ARGS"
}

@test "defaults to the repo the script lives in" {
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -qx "$REPO_ROOT" "$ARGS"
}

@test "fails when nix eval fails" {
    RC=1
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -ne 0 ]
}

@test "rejects output that is not a YY.MM release" {
    OUT="garbage"
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "not a NixOS release" ]]
}

@test "rejects empty output" {
    OUT=""
    stub_nix
    PATH="$TEST_DIR/bin:$PATH" run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
}
