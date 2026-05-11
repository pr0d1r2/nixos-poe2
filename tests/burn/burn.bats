#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/burn" "$TEST_DIR/iso"
    cp scripts/burn/burn.sh "$TEST_DIR/scripts/burn/"
    cp scripts/burn/list_isos.sh "$TEST_DIR/scripts/burn/"
    cp scripts/burn/list_usb.sh "$TEST_DIR/scripts/burn/"

    cat >"$TEST_DIR/scripts/burn/burn-remote.sh" <<'MOCK'
#!/usr/bin/env bash
exit 2
MOCK

    cd "$TEST_DIR" || return
    git init -q
    git commit --allow-empty -m "init" -q
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits 1 when no ISOs exist" {
    run bash "$TEST_DIR/scripts/burn/burn.sh" "$TEST_DIR/iso"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "No ISOs" ]]
}

@test "exits 1 when no USB devices detected" {
    touch "$TEST_DIR/iso/test.iso"
    EMPTY_BACKEND="$TEST_DIR/empty-usb"
    printf '' >"$EMPTY_BACKEND"
    run env POE2_BURN_AUTO=1 POE2_BURN_FAKE_BACKEND="$EMPTY_BACKEND" \
        bash "$TEST_DIR/scripts/burn/burn.sh" "$TEST_DIR/iso"
    [ "$status" -eq 1 ]
}
