#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

@test "module file exists" {
    [ -f modules/kernel.nix ]
}

@test "kernel module is wired into the ISO" {
    grep -q './modules/kernel.nix' flake.nix
}

@test "hardware.nix no longer selects the kernel" {
    run ! grep -q 'kernelPackages =' modules/hardware.nix
}

@test "stays on the default LTS series, not linuxPackages_latest" {
    grep -q 'pkgs.linuxPackages' modules/kernel.nix
    run ! grep -q 'pkgs.linuxPackages_latest' modules/kernel.nix
}

@test "pins 6.18.62 source for CVE-2026-99281" {
    grep -q 'CVE-2026-99281' modules/kernel.nix
    grep -q '"6.18.62"' modules/kernel.nix
    grep -q '0lfnsycp12j4j2sldjjf0s1dmdfcrhrm7h56sdjwamdky7npl2j9' modules/kernel.nix
}

@test "pin is guarded on the first fixed release" {
    grep -q 'versionOlder' modules/kernel.nix
    grep -q '"6.18.61"' modules/kernel.nix
}

@test "pinned kernel rebuilds out-of-tree modules via linuxPackagesFor" {
    grep -q 'linuxPackagesFor' modules/kernel.nix
}
