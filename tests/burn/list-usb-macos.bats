#!/usr/bin/env bats

@test "script is valid bash" {
    run bash -n scripts/burn/list-usb-macos.sh
    [ "$status" -eq 0 ]
}

@test "uses diskutil for device enumeration" {
    grep -q 'diskutil' scripts/burn/list-usb-macos.sh
}

@test "outputs pipe-delimited format" {
    grep -q 'printf.*|.*|' scripts/burn/list-usb-macos.sh
}

@test "uses python3 for plist parsing" {
    grep -q 'python3' scripts/burn/list-usb-macos.sh
}
