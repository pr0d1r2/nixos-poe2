#!/usr/bin/env bash
set -Eeuo pipefail

HOST="player@poe2.local"

if ! ssh -o ConnectTimeout=3 "$HOST" true 2>/dev/null; then
    echo "mixer: cannot reach $HOST" >&2
    exit 1
fi

echo "mixer: connecting to $HOST..."
ssh -t "$HOST" pulsemixer
