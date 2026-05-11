#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n scripts/burn/list-usb-linux.sh
    [ "$status" -eq 0 ]
}

@test "filters for usb transport" {
    grep -q 'usb' scripts/burn/list-usb-linux.sh
}

@test "outputs pipe-delimited format" {
    grep -q 'printf.*|.*|' scripts/burn/list-usb-linux.sh
}

@test "excludes busy disks" {
    grep -q 'busy' scripts/burn/list-usb-linux.sh
}
