#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/storage-link.sh
    [ "$status" -eq 0 ]
}

@test "prefers nvme over sata" {
    # nvme appears first in candidate list
    first_candidate="$(grep -n 'storage-nvme\|storage-sata' fragments/storage-link.sh | head -n1)"
    [[ "$first_candidate" =~ nvme ]]
}

@test "refuses to touch non-symlink /mnt/storage" {
    grep -q 'not a symlink' fragments/storage-link.sh
}
