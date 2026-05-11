#!/usr/bin/env bash
set -euo pipefail

echo "nixos-poe2 dev shell"

export LEFTHOOK_TDD_PATHS=":(glob)scripts/**/*.sh :(glob)fragments/*.sh :(glob)pkgs/*.sh :(glob)nix/dev/*.sh"
export LEFTHOOK_TDD_EXCLUDE="scripts/lefthook/*"

LEFTHOOK_HASH=$(md5 -q lefthook.yml 2>/dev/null || md5sum lefthook.yml | cut -d' ' -f1)
LEFTHOOK_HASH_FILE=".git/.lefthook-hash"
if [ ! -f "$LEFTHOOK_HASH_FILE" ] || [ "$(cat "$LEFTHOOK_HASH_FILE")" != "$LEFTHOOK_HASH" ]; then
    lefthook install
    echo "$LEFTHOOK_HASH" >"$LEFTHOOK_HASH_FILE"
fi
