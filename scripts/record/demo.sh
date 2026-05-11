#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for tool in asciinema agg ffmpeg jq just; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "record-demo: '$tool' not found. Enter dev shell first." >&2
        exit 1
    fi
done

CAST_DIR="$REPO_ROOT/doc/demo"
mkdir -p "$CAST_DIR"

CAST="$CAST_DIR/burn-confirmed.cast"
LOG="$CAST_DIR/burn-confirmed.log"
GIF="$CAST_DIR/burn-confirmed.gif"
MP4="$CAST_DIR/burn-confirmed.mp4"

inner_exit=0

if [[ ! -f "$CAST" ]]; then
    exit_file="$(mktemp)"
    trap 'rm -f "$exit_file"' EXIT
    inner="just burn-confirmed; echo \$? > ${exit_file}"
    tmp_cast="$CAST.tmp"
    echo "record-demo: recording just burn-confirmed..."
    asciinema rec --overwrite --cols 100 --rows 30 --command "$inner" "$tmp_cast"
    if [[ -s "$exit_file" ]]; then
        inner_exit="$(tr -d '[:space:]' <"$exit_file")"
    fi
    if [[ "${inner_exit:-0}" -ne 0 ]]; then
        rm -f "$tmp_cast"
        echo "record-demo: recording failed (exit $inner_exit), no cache written." >&2
        exit "$inner_exit"
    fi
    mv "$tmp_cast" "$CAST"
else
    echo "record-demo: cast cached at $CAST"
fi

if [[ ! -f "$LOG" ]]; then
    tmp_log="$LOG.tmp"
    echo "record-demo: extracting log..."
    jq -r --slurp 'map(select(type == "array" and .[1] == "o") | .[2]) | join("")' \
        <"$CAST" >"$tmp_log"
    mv "$tmp_log" "$LOG"
else
    echo "record-demo: log cached at $LOG"
fi

if [[ ! -f "$GIF" ]]; then
    tmp_gif="$GIF.tmp"
    echo "record-demo: generating GIF..."
    agg --speed 3 "$CAST" "$tmp_gif"
    mv "$tmp_gif" "$GIF"
else
    echo "record-demo: gif cached at $GIF"
fi

if [[ ! -f "$MP4" ]]; then
    tmp_mp4="${MP4%.mp4}.tmp.mp4"
    echo "record-demo: converting to MP4..."
    ffmpeg -y -i "$GIF" -movflags faststart -pix_fmt yuv420p \
        -vf "scale=800:-2" -crf 30 -preset veryslow "$tmp_mp4"
    mv "$tmp_mp4" "$MP4"
else
    echo "record-demo: mp4 cached at $MP4"
fi

echo "record-demo: cast at $CAST"
echo "record-demo: log at $LOG"
echo "record-demo: gif at $GIF"
echo "record-demo: mp4 at $MP4"
