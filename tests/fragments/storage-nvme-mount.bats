#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/storage-nvme-mount.sh
    [ "$status" -eq 0 ]
}

@test "uses STORAGE_FSTYPE variable" {
    grep -q 'STORAGE_FSTYPE' fragments/storage-nvme-mount.sh
}

@test "filters for nvme devices" {
    grep -q 'nvme' fragments/storage-nvme-mount.sh
}

@test "retries up to 5 times" {
    grep -q '1 2 3 4 5' fragments/storage-nvme-mount.sh
}

@test "exports tier=nvme" {
    grep -q 'tier=nvme' fragments/storage-nvme-mount.sh
}
