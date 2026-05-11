#!/usr/bin/env bats

@test "script exists and is valid bash" {
    run bash -n scripts/lib/find-builder.sh
    [ "$status" -eq 0 ]
}

@test "contains builder candidates" {
    grep -q 'nix-builder.local' scripts/lib/find-builder.sh
    grep -q 'poe2.local' scripts/lib/find-builder.sh
}

@test "exits 1 when no builders reachable" {
    # shellcheck disable=SC2016
    run env SSH_AUTH_SOCK= bash -c '
        CANDIDATES=("root@nonexistent-host-12345.invalid")
        hn="localdev"
        for builder in "${CANDIDATES[@]}"; do
            host="${builder#*@}"
            host_short="${host%%.*}"
            case "$hn" in
                "$host_short" | "$host_short".*) continue ;;
            esac
            if ssh -o BatchMode=yes -o ConnectTimeout=1 "$builder" true 2>/dev/null; then
                echo "$builder"
                exit 0
            fi
        done
        exit 1
    '
    [ "$status" -eq 1 ]
}
