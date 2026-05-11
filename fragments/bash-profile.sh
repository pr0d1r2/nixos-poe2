#!/usr/bin/env bash
# shellcheck source=/dev/null
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx -- vt1 >~/.xinit.log 2>&1
fi
