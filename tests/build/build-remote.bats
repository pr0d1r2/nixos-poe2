#!/usr/bin/env bats

@test "exits 2 with wrong number of arguments" {
    run bash scripts/build/build-remote.sh
    [ "$status" -eq 2 ]
}

@test "exits 2 with too few arguments" {
    run bash scripts/build/build-remote.sh /tmp 25.11
    [ "$status" -eq 2 ]
}

@test "prints usage on wrong argument count" {
    run bash scripts/build/build-remote.sh
    [[ "$output" =~ "Usage" ]]
}
