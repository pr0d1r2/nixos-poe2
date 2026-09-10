#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../scripts/lib/skip-or-run.sh"
    TEST_DIR="$(mktemp -d)"
    LOG="$TEST_DIR/log"
    printf 'echo check >>"%s"; exit 0\n' "$LOG" >"$TEST_DIR/check-done.sh"
    printf 'echo check >>"%s"; exit 1\n' "$LOG" >"$TEST_DIR/check-pending.sh"
    printf 'echo one >>"%s"\n' "$LOG" >"$TEST_DIR/step-one.sh"
    printf 'echo two >>"%s"\n' "$LOG" >"$TEST_DIR/step-two.sh"
    printf 'echo fail >>"%s"; exit 7\n' "$LOG" >"$TEST_DIR/step-fail.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script exists and is valid bash" {
    run bash -n "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "exits 2 with usage when no step is given" {
    run bash "$SCRIPT" "$TEST_DIR/check-pending.sh"
    [ "$status" -eq 2 ]
    [[ "$output" =~ Usage ]]
}

@test "exits 2 with usage when no arguments are given" {
    run bash "$SCRIPT"
    [ "$status" -eq 2 ]
}

@test "skips steps when check passes" {
    run bash "$SCRIPT" "$TEST_DIR/check-done.sh" "$TEST_DIR/step-one.sh"
    [ "$status" -eq 0 ]
    [ "$(cat "$LOG")" = "check" ]
}

@test "runs single step when check fails" {
    run bash "$SCRIPT" "$TEST_DIR/check-pending.sh" "$TEST_DIR/step-one.sh"
    [ "$status" -eq 0 ]
    [ "$(cat "$LOG")" = "$(printf 'check\none')" ]
}

@test "runs steps in order when check fails" {
    run bash "$SCRIPT" "$TEST_DIR/check-pending.sh" \
        "$TEST_DIR/step-one.sh" "$TEST_DIR/step-two.sh"
    [ "$status" -eq 0 ]
    [ "$(cat "$LOG")" = "$(printf 'check\none\ntwo')" ]
}

@test "stops at first failing step and returns its exit code" {
    run bash "$SCRIPT" "$TEST_DIR/check-pending.sh" \
        "$TEST_DIR/step-fail.sh" "$TEST_DIR/step-two.sh"
    [ "$status" -eq 7 ]
    [ "$(cat "$LOG")" = "$(printf 'check\nfail')" ]
}

@test "passes no arguments to steps" {
    printf 'echo "args=$#" >>"%s"\n' "$LOG" >"$TEST_DIR/step-args.sh"
    run bash "$SCRIPT" "$TEST_DIR/check-pending.sh" "$TEST_DIR/step-args.sh"
    [ "$status" -eq 0 ]
    [ "$(tail -n1 "$LOG")" = "args=0" ]
}
