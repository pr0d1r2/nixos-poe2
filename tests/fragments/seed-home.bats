#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n fragments/seed-home.sh
    [ "$status" -eq 0 ]
}

@test "creates storage home directory" {
    grep -q 'STORAGE_HOME' fragments/seed-home.sh
}

@test "copies bash_profile and xinitrc from skel" {
    grep -q '.bash_profile' fragments/seed-home.sh
    grep -q '.xinitrc' fragments/seed-home.sh
}
