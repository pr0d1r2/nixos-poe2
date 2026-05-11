#!/usr/bin/env bash
# Interactive USB burner.
# Picks a USB device and an ISO, triple-confirms, dd's the image.
# No trailing ext4 -- pendrive is stateless.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

ISO_DIR="${1:-iso}"

# --- try remote burn first ---------------------------------------------------
remote_rc=0
bash "$REPO_ROOT/scripts/burn/burn-remote.sh" "$REPO_ROOT" || remote_rc=$?
case "$remote_rc" in
    0) exit 0 ;;
    1) exit 1 ;;
    2) : ;;
esac

# --- pick ISO ----------------------------------------------------------------
mapfile -t isos < <(bash "$REPO_ROOT/scripts/burn/list_isos.sh" "$ISO_DIR")

HEAD_SHA="${POE2_HEAD_SHA:-}"
if [ -z "$HEAD_SHA" ] &&
    git -C "$REPO_ROOT" diff --quiet --exit-code 2>/dev/null &&
    git -C "$REPO_ROOT" diff --cached --quiet --exit-code 2>/dev/null; then
    HEAD_SHA="$(git -C "$REPO_ROOT" rev-parse --short=7 HEAD 2>/dev/null || true)"
fi

head_idx=-1
if [ -n "$HEAD_SHA" ]; then
    for i in "${!isos[@]}"; do
        case "${isos[$i]}" in
            *"$HEAD_SHA"*)
                head_idx=$i
                break
                ;;
        esac
    done
fi

if [ "${POE2_BURN_AUTO:-0}" = "1" ] && [ "$head_idx" -ge 0 ]; then
    ISO_PATH="$ISO_DIR/${isos[$head_idx]}"
    echo "burn: auto-selected $(basename "$ISO_PATH") (HEAD $HEAD_SHA)" >&2
else
    echo "Available ISOs in $ISO_DIR:"
    for i in "${!isos[@]}"; do
        iso_size="$(du -h "$ISO_DIR/${isos[$i]}" 2>/dev/null | cut -f1)"
        if [ "$i" -eq "$head_idx" ]; then
            printf '  \033[1;32m*[%d] %s  (%s)  <- HEAD (%s)\033[0m\n' \
                "$((i + 1))" "${isos[$i]}" "$iso_size" "$HEAD_SHA"
        else
            printf '   [%d] %s  (%s)\n' "$((i + 1))" "${isos[$i]}" "$iso_size"
        fi
    done
    if [ "$head_idx" -ge 0 ]; then
        default_choice=$((head_idx + 1))
        read -r -p "Select ISO [1-${#isos[@]}] (default: $default_choice, HEAD): " iso_choice
        iso_choice="${iso_choice:-$default_choice}"
    else
        read -r -p "Select ISO [1-${#isos[@]}]: " iso_choice
    fi
    if ! [[ "$iso_choice" =~ ^[0-9]+$ ]] || [ "$iso_choice" -lt 1 ] || [ "$iso_choice" -gt "${#isos[@]}" ]; then
        echo "burn: invalid ISO selection." >&2
        exit 1
    fi
    ISO_PATH="$ISO_DIR/${isos[$((iso_choice - 1))]}"
fi

# --- pick USB ----------------------------------------------------------------
mapfile -t usb_lines < <(bash "$REPO_ROOT/scripts/burn/list_usb.sh")

if [ "${#usb_lines[@]}" -eq 0 ]; then
    echo "burn: no USB devices detected. Connect a stick and retry." >&2
    exit 1
elif [ "${#usb_lines[@]}" -eq 1 ]; then
    IFS='|' read -r DEV _ MODEL <<<"${usb_lines[0]}"
    echo
    echo "burn: auto-selected only USB device: $DEV ($MODEL)"
else
    echo
    echo "Detected USB devices:"
    for i in "${!usb_lines[@]}"; do
        IFS='|' read -r dev size model <<<"${usb_lines[$i]}"
        printf '  [%d] %s  %s  %s\n' "$((i + 1))" "$dev" "$size" "$model"
    done
    read -r -p "Select USB device [1-${#usb_lines[@]}]: " usb_choice
    if ! [[ "$usb_choice" =~ ^[0-9]+$ ]] || [ "$usb_choice" -lt 1 ] || [ "$usb_choice" -gt "${#usb_lines[@]}" ]; then
        echo "burn: invalid USB selection." >&2
        exit 1
    fi
    IFS='|' read -r DEV _ MODEL <<<"${usb_lines[$((usb_choice - 1))]}"
fi

# --- size sanity check -------------------------------------------------------
iso_bytes="$(wc -c <"$ISO_PATH" | tr -d '[:space:]')"
dev_bytes=""
if [ -z "${POE2_BURN_FAKE_BACKEND:-}" ]; then
    case "$(uname -s)" in
        Linux)
            dev_bytes="$(lsblk -bn -d -o SIZE "$DEV" 2>/dev/null || true)"
            ;;
        Darwin)
            dev_bytes="$(diskutil info -plist "${DEV#/dev/}" 2>/dev/null |
                python3 -c 'import plistlib,sys; print(plistlib.loads(sys.stdin.buffer.read()).get("TotalSize",0))')"
            ;;
    esac
fi
if [ -n "$dev_bytes" ] && [ "$iso_bytes" -gt "$dev_bytes" ]; then
    iso_h="$(du -h "$ISO_PATH" 2>/dev/null | cut -f1)"
    dev_h="$(awk -v b="$dev_bytes" 'BEGIN{printf "%.1fG", b/1024/1024/1024}')"
    echo "burn: ISO ($iso_h) does not fit on $DEV ($dev_h). Pick a larger stick." >&2
    exit 1
fi

# --- confirm + write ---------------------------------------------------------
if [ "${POE2_BURN_CONFIRMED:-0}" = "1" ]; then
    echo "burn: CONFIRMED mode -- writing $DEV ($MODEL) with $(basename "$ISO_PATH")" >&2
else
    cat <<EOF

About to OVERWRITE the following USB device with the chosen ISO:

    device : $DEV  ($MODEL)
    iso    : $ISO_PATH  ($(du -h "$ISO_PATH" 2>/dev/null | cut -f1))

This is destructive and irreversible.

EOF
    read -r -p "Type 'BURN' to proceed: " confirm
    if [ "$confirm" != "BURN" ]; then
        echo "burn: aborted." >&2
        exit 1
    fi
fi

case "$(uname -s)" in
    Linux)
        SUDO=""
        [ "$EUID" -ne 0 ] && SUDO="sudo"
        if command -v pv >/dev/null 2>&1; then
            # shellcheck disable=SC2086
            $SUDO sh -c "pv -tpab -s '$iso_bytes' '$ISO_PATH' | dd of='$DEV' bs=4M iflag=fullblock oflag=direct conv=fsync"
        else
            nix shell --extra-experimental-features 'nix-command flakes' nixpkgs#pv -c \
                $SUDO sh -c "pv -tpab -s '$iso_bytes' '$ISO_PATH' | dd of='$DEV' bs=4M iflag=fullblock oflag=direct conv=fsync"
        fi
        # shellcheck disable=SC2086
        $SUDO sync
        ;;
    Darwin)
        RAW_DEV="${DEV//\/dev\//\/dev\/r}"
        sudo diskutil unmountDisk "$DEV"
        sudo sh -c "pv -tpab -s '$iso_bytes' '$ISO_PATH' | dd of='$RAW_DEV' bs=1M"
        sync
        ;;
    *)
        echo "burn: unsupported host $(uname -s)" >&2
        exit 1
        ;;
esac

echo
echo "burn: done. Eject the device and boot it on the target machine."
