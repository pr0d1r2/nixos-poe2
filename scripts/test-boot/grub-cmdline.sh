#!/usr/bin/env bash
# Print the kernel command line of the first `linux` entry in a GRUB config.
#
# Usage: grub-cmdline.sh <grub.cfg>
#
# Drops the kernel image path and GRUB variables such as ${isoboot}
# (also the backslash-escaped form), so the result can be handed to
# QEMU -append for direct kernel boot exactly as the ISO boots itself.
# Exits 1 when the file or a linux entry is missing, 2 on bad usage.

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: grub-cmdline.sh <grub.cfg>" >&2
    exit 2
fi

cfg="$1"

if [ ! -f "$cfg" ]; then
    echo "grub-cmdline: $cfg not found" >&2
    exit 1
fi

awk '
    $1 == "linux" {
        out = ""
        for (i = 3; i <= NF; i++) {
            if ($i ~ /^\\?\$\{[^}]*\}$/) continue
            out = out (out == "" ? "" : " ") $i
        }
        print out
        found = 1
        exit
    }
    END { exit found ? 0 : 1 }
' "$cfg"
