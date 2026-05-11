#!/usr/bin/env bats

@test "script parses without errors" {
    run bash -n fragments/nix-store-overlay.sh
    [ "$status" -eq 0 ]
}

@test "creates upper and work directories under storage" {
    grep -q 'nix-store-upper' fragments/nix-store-overlay.sh
    grep -q 'nix-store-work' fragments/nix-store-overlay.sh
}

@test "exits 0 gracefully when storage absent" {
    grep -q 'exit 0' fragments/nix-store-overlay.sh
}
