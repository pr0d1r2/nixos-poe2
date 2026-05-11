#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

LOCAL_EXE="$REPO_ROOT/pkgs/installer/PathOfExile2Installer.exe"
REMOTE_DIR="/mnt/storage/poe2/installer"
REMOTE_FILE="$REMOTE_DIR/PathOfExile2Installer.exe"

if [[ ! -f "$LOCAL_EXE" ]]; then
    echo "upload: missing $LOCAL_EXE" >&2
    echo >&2
    echo "Download from https://pathofexile2.com/download" >&2
    echo "and place it at: pkgs/installer/PathOfExile2Installer.exe" >&2
    exit 1
fi

TARGET="poe2.local"
if ! ssh -o ConnectTimeout=3 "player@$TARGET" true 2>/dev/null; then
    echo "upload: cannot reach player@$TARGET" >&2
    exit 1
fi

echo "upload: ensuring $REMOTE_DIR exists on $TARGET"
# shellcheck disable=SC2029
ssh "player@$TARGET" "mkdir -p '$REMOTE_DIR'"

echo "upload: copying installer to player@$TARGET:$REMOTE_FILE"
scp "$LOCAL_EXE" "player@$TARGET:$REMOTE_FILE"

echo "upload: done -- launcher will detect it automatically"
