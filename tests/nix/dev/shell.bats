#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n nix/dev/shell.sh
    [ "$status" -eq 0 ]
}

@test "computes lefthook hash" {
    grep -q 'LEFTHOOK_HASH' nix/dev/shell.sh
}

@test "installs lefthook when hash changes" {
    grep -q 'lefthook install' nix/dev/shell.sh
}

@test "stores hash in .git directory" {
    grep -q '.git/.lefthook-hash' nix/dev/shell.sh
}
