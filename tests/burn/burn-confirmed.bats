#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR/scripts/burn"
    cp scripts/burn/burn-confirmed.sh "$TEST_DIR/scripts/burn/"
    cat >"$TEST_DIR/scripts/burn/burn.sh" <<'MOCK'
#!/usr/bin/env bash
echo "POE2_BURN_AUTO=$POE2_BURN_AUTO"
echo "POE2_BURN_CONFIRMED=$POE2_BURN_CONFIRMED"
MOCK
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "sets POE2_BURN_AUTO=1" {
    run bash "$TEST_DIR/scripts/burn/burn-confirmed.sh"
    [[ "$output" =~ "POE2_BURN_AUTO=1" ]]
}

@test "sets POE2_BURN_CONFIRMED=1" {
    run bash "$TEST_DIR/scripts/burn/burn-confirmed.sh"
    [[ "$output" =~ "POE2_BURN_CONFIRMED=1" ]]
}
