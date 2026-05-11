#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/burn"
    cp scripts/burn/burn-auto.sh "$TEST_DIR/scripts/burn/"
    # Create a mock burn.sh that just prints env vars
    cat >"$TEST_DIR/scripts/burn/burn.sh" <<'MOCK'
#!/usr/bin/env bash
echo "POE2_BURN_AUTO=$POE2_BURN_AUTO"
MOCK
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "sets POE2_BURN_AUTO=1" {
    run bash "$TEST_DIR/scripts/burn/burn-auto.sh"
    [ "$status" -eq 0 ]
    [ "$output" = "POE2_BURN_AUTO=1" ]
}
