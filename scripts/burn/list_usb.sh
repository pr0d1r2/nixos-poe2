#!/usr/bin/env bash
# Cross-platform USB enumerator.
# Output: <device>|<size>|<model>

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -n "${POE2_BURN_FAKE_BACKEND:-}" ]; then
    devices="$(cat "$POE2_BURN_FAKE_BACKEND")"
elif [ "$(uname -s)" = "Linux" ]; then
    devices="$(bash "$HERE/list-usb-linux.sh")"
elif [ "$(uname -s)" = "Darwin" ]; then
    devices="$(bash "$HERE/list-usb-macos.sh")"
else
    echo "list_usb: unsupported host $(uname -s)" >&2
    exit 1
fi

if [ -z "${devices//[[:space:]]/}" ]; then
    echo "list_usb: No USB block devices detected. Plug one in and retry." >&2
    exit 1
fi

printf '%s\n' "$devices"
