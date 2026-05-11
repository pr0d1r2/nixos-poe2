#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n fragments/bash-profile.sh
    [ "$status" -eq 0 ]
}

@test "sources bashrc if it exists" {
    grep -q '.bashrc' fragments/bash-profile.sh
}

@test "only starts X on tty1" {
    grep -q 'tty1' fragments/bash-profile.sh
}

@test "checks DISPLAY is empty before starting X" {
    grep -q 'DISPLAY' fragments/bash-profile.sh
}
