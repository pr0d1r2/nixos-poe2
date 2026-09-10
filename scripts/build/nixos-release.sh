#!/usr/bin/env bash
# Print the NixOS release (e.g. 26.05) of the nixpkgs this flake pins.
#
# Usage: nixos-release.sh [repo-root]
#   repo-root  flake whose nixpkgs input is read (default: this repo)

set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

release="$(nix eval --raw --extra-experimental-features 'nix-command flakes' \
    --inputs-from "$REPO_ROOT" 'nixpkgs#lib.trivial.release')"

if ! [[ "$release" =~ ^[0-9]{2}\.[0-9]{2}$ ]]; then
    echo "nixos-release: '$release' is not a NixOS release (want YY.MM)" >&2
    exit 1
fi

printf '%s\n' "$release"
