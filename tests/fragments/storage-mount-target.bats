#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/storage-mount-target.sh
    [ "$status" -eq 0 ]
}

@test "uses tier variable for mount point" {
    # shellcheck disable=SC2016
    grep -q 'storage-${tier}' fragments/storage-mount-target.sh
}

@test "reports disk model in output" {
    grep -q 'parent_model' fragments/storage-mount-target.sh
}
