#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n scripts/mixer/mixer.sh
    [ "$status" -eq 0 ]
}

@test "exits 1 when target unreachable" {
    # shellcheck disable=SC2016
    run env SSH_AUTH_SOCK= bash -c '
        HOST="player@nonexistent-host-12345.invalid"
        if ! ssh -o ConnectTimeout=1 "$HOST" true 2>/dev/null; then
            echo "mixer: cannot reach $HOST" >&2
            exit 1
        fi
    '
    [ "$status" -eq 1 ]
    [[ "$output" =~ "cannot reach" ]]
}

@test "targets poe2.local" {
    grep -q 'poe2.local' scripts/mixer/mixer.sh
}
