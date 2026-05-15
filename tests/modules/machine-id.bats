#!/usr/bin/env bats

@test "module file exists" {
    [ -f modules/machine-id.nix ]
}

@test "sets machine-id in environment.etc" {
    grep -q 'environment.etc."machine-id"' modules/machine-id.nix
}

@test "contains deterministic hash from nixos-poe2 seed" {
    grep -q 'a15d0224aec0dee8a812d0f34370c7d2' modules/machine-id.nix
}

@test "sets read-only mode" {
    grep -q '0444' modules/machine-id.nix
}
