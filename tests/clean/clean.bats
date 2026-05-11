#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/clean/clean.sh"
    SHORT_SHA="abc1234"

    # Fake repo root with markers and ISO
    mkdir -p "$TEST_DIR/iso"
    mkdir -p "$TEST_DIR/scripts/lib"
    mkdir -p "$TEST_DIR/scripts/build"
    touch "$TEST_DIR/.smoke-passed-$SHORT_SHA"
    touch "$TEST_DIR/.burn-done-$SHORT_SHA"
    touch "$TEST_DIR/iso/nixos-poe2-25.11-${SHORT_SHA}-x86_64-linux.iso"

    # Stub git to return fixed SHA
    mkdir -p "$TEST_DIR/bin"
    printf '#!/usr/bin/env bash\necho "%s"\n' "$SHORT_SHA" >"$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/git"

    # Stub find-builder.sh
    printf '#!/usr/bin/env bash\necho "root@fake-builder.local"\n' >"$TEST_DIR/scripts/lib/find-builder.sh"

    # Stub iso_store_dir.sh
    printf '#!/usr/bin/env bash\necho "/mnt/storage-fast/poe2-iso"\n' >"$TEST_DIR/scripts/build/iso_store_dir.sh"

    # Stub ssh - track calls
    SSH_LOG="$TEST_DIR/ssh-calls.log"
    printf '#!/usr/bin/env bash\necho "$*" >>"%s"\n' "$SSH_LOG" >"$TEST_DIR/bin/ssh"
    chmod +x "$TEST_DIR/bin/ssh"

    export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "removes local smoke marker" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.smoke-passed-$SHORT_SHA" ]
}

@test "removes local burn marker" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.burn-done-$SHORT_SHA" ]
}

@test "removes local ISO for HEAD" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -z "$(ls "$TEST_DIR/iso/"*"$SHORT_SHA"*.iso 2>/dev/null)" ]
}

@test "removes remote ISO on builder" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    grep -q "rm -f.*$SHORT_SHA" "$TEST_DIR/ssh-calls.log"
}

@test "succeeds when no markers exist" {
    rm -f "$TEST_DIR/.smoke-passed-$SHORT_SHA"
    rm -f "$TEST_DIR/.burn-done-$SHORT_SHA"
    rm -f "$TEST_DIR/iso/"*"$SHORT_SHA"*.iso

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "reports what was cleaned" {
    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"smoke"* ]]
    [[ "$output" == *"burn"* ]]
    [[ "$output" == *"iso"* ]]
}
