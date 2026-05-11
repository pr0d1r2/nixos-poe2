#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/gc/gc.sh"

    # Stub find-builder.sh
    FAKE_LIB="$TEST_DIR/scripts/lib"
    mkdir -p "$FAKE_LIB"
    printf '#!/usr/bin/env bash\necho "root@fake-builder.local"\n' >"$FAKE_LIB/find-builder.sh"

    # Stub ssh
    mkdir -p "$TEST_DIR/bin"
    printf '#!/usr/bin/env bash\necho "0 store paths deleted, 0.00 MiB freed"\n' >"$TEST_DIR/bin/ssh"
    chmod +x "$TEST_DIR/bin/ssh"

    export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "discovers builder via find-builder.sh" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"root@fake-builder.local"* ]]
}

@test "runs nix-collect-garbage on builder" {
    printf '#!/usr/bin/env bash\necho "CALLED: $*"\necho "42 store paths deleted, 1234.56 MiB freed"\n' >"$TEST_DIR/bin/ssh"
    chmod +x "$TEST_DIR/bin/ssh"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix-collect-garbage"* ]]
}

@test "reports freed space from gc output" {
    printf '#!/usr/bin/env bash\necho "42 store paths deleted, 1234.56 MiB freed"\n' >"$TEST_DIR/bin/ssh"
    chmod +x "$TEST_DIR/bin/ssh"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"1234.56 MiB freed"* ]]
}

@test "fails when no builder found" {
    printf '#!/usr/bin/env bash\necho "no builder" >&2\nexit 1\n' >"$FAKE_LIB/find-builder.sh"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
}
