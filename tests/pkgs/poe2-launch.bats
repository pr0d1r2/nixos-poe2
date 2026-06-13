#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n pkgs/poe2-launch.sh
    [ "$status" -eq 0 ]
}

@test "defines GAME_ID" {
    grep -q 'GAME_ID=' pkgs/poe2-launch.sh
}

@test "uses /mnt/storage mount point" {
    grep -q '/mnt/storage' pkgs/poe2-launch.sh
}

@test "has fatal function for error display" {
    grep -q 'fatal()' pkgs/poe2-launch.sh
}

@test "waits 30s on fatal for user to read" {
    grep -q 'sleep 30' pkgs/poe2-launch.sh
}

@test "restarts game on exit" {
    grep -q 'while true' pkgs/poe2-launch.sh
}

@test "exports STEAM_COMPAT_DATA_PATH to storage" {
    grep -q 'STEAM_COMPAT_DATA_PATH' pkgs/poe2-launch.sh
}

@test "creates Steam-compat-data directory" {
    grep -q 'Steam-compat-data' pkgs/poe2-launch.sh
}

@test "defines HOME_EXE self-patching client copy" {
    grep -q 'HOME_EXE=' pkgs/poe2-launch.sh
}

@test "resolves launch target via poe2-resolve-exe each loop" {
    grep -q 'poe2-resolve-exe' pkgs/poe2-launch.sh
}

@test "waits on the bootstrap copy during install" {
    grep -q 'BOOT_EXE' pkgs/poe2-launch.sh
}
