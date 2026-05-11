#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n scripts/record/demo.sh
    [ "$status" -eq 0 ]
}

@test "checks for required tools" {
    grep -q 'asciinema' scripts/record/demo.sh
    grep -q 'agg' scripts/record/demo.sh
    grep -q 'ffmpeg' scripts/record/demo.sh
    grep -q 'jq' scripts/record/demo.sh
}

@test "exits 1 when tool missing" {
    run env PATH=/usr/bin:/bin bash scripts/record/demo.sh
    [ "$status" -eq 1 ]
    [[ "$output" =~ "not found" ]]
}
