#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/storage-proton.sh
    [ "$status" -eq 0 ]
}

@test "creates Steam-compat-data directory" {
    grep -q 'Steam-compat-data' fragments/storage-proton.sh
}

@test "sets player ownership" {
    grep -q 'player' fragments/storage-proton.sh
}

@test "uses install -d for atomic directory creation" {
    grep -q 'install -d' fragments/storage-proton.sh
}
