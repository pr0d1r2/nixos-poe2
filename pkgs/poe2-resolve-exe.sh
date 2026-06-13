#!/usr/bin/env bash
# poe2-resolve-exe: print the path to the live, self-patching PathOfExile.exe.
#
# PoE 2 self-deploys and self-patches the client into its working directory --
# the player HOME, where umu/Proton chdirs -- not into the installer's
# "Program Files" tree. That working-dir copy receives every patch in place;
# the Program Files copy is a frozen bootstrap the installer drops once.
#
# Launching the frozen bootstrap runs an old binary while the patcher updates
# the HOME copy, so the login server rejects the stale version and demands a
# patch on every boot ("Please restart Path of Exile" loop). Prefer the HOME
# copy; fall back to the bootstrap only during the first-run/installer window
# before HOME is populated.
#
# Args:
#   $1 - HOME copy path  (self-patching target, launched once it exists)
#   $2 - bootstrap path  (installer Program Files copy, first-run fallback)
# Output: the resolved path on stdout, exit 0. Exit 1 if neither exists.
set -euo pipefail

home_exe="$1"
boot_exe="$2"

[ -f "$home_exe" ] && {
    printf '%s\n' "$home_exe"
    exit 0
}
[ -f "$boot_exe" ] && {
    printf '%s\n' "$boot_exe"
    exit 0
}
exit 1
