#!/usr/bin/env bash
# Print the value of a kernel parameter from a GRUB config.
#
# Usage: grub-param.sh <grub.cfg> <key>
#
# Prints the value of the first whitespace-delimited <key>=<value>
# (root yields LABEL=..., prefix included). Exits 1 when the file or
# the key is missing, 2 on bad usage.

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: grub-param.sh <grub.cfg> <key>" >&2
    exit 2
fi

cfg="$1"
key="$2"

if [ ! -f "$cfg" ]; then
    echo "grub-param: $cfg not found" >&2
    exit 1
fi

value="$(grep -oE "(^|[[:space:]])${key}=[^[:space:]]+" "$cfg" |
    head -n1 | sed -E "s/^[[:space:]]*${key}=//" || true)"

if [ -z "$value" ]; then
    exit 1
fi

printf '%s\n' "$value"
