#!/usr/bin/env bats

@test "module file exists" {
    [ -f modules/mumble.nix ]
}

@test "includes mumble package" {
    grep -q 'mumble' modules/mumble.nix
}

@test "includes wmctrl package" {
    grep -q 'wmctrl' modules/mumble.nix
}

@test "delivers openbox rc.xml config" {
    grep -q 'openbox-rc.xml' modules/mumble.nix
}

@test "openbox config file exists" {
    [ -f fragments/openbox-rc.xml ]
}

@test "openbox config contains Super+M keybind" {
    grep -q 'W-m' fragments/openbox-rc.xml
}

@test "keybind invokes wmctrl for Mumble" {
    grep -q 'wmctrl.*Mumble' fragments/openbox-rc.xml
}

@test "openbox config preserves Alt+Tab" {
    grep -q 'A-Tab' fragments/openbox-rc.xml
}

@test "openbox config preserves Alt+F4" {
    grep -q 'A-F4' fragments/openbox-rc.xml
}

@test "module registered in flake.nix" {
    grep -q 'modules/mumble.nix' flake.nix
}

@test "xinitrc launches mumble in background" {
    grep -q 'mumble.*&' modules/base.nix
}
