#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/storage-sata-mount.sh
    [ "$status" -eq 0 ]
}

@test "uses STORAGE_FSTYPE variable" {
    grep -q 'STORAGE_FSTYPE' fragments/storage-sata-mount.sh
}

@test "excludes USB transport disks" {
    grep -q 'usb' fragments/storage-sata-mount.sh
}

@test "exports tier=sata" {
    grep -q 'tier=sata' fragments/storage-sata-mount.sh
}
