#!/usr/bin/env bash
# Bind-mount player home from NVMe storage so large downloads
# (GE-Proton, Steam Runtime, game assets) don't fill tmpfs.
STORAGE_HOME="/mnt/storage/poe2/home" # nolocalpath

install -d -o player -g player -m 0755 "$STORAGE_HOME" # nolocalpath
install -d -o player -g player -m 0755 /home/player    # nolocalpath
mount --bind "$STORAGE_HOME" /home/player              # nolocalpath

install -o player -g player -m 0644 /etc/skel/.bash_profile /home/player/.bash_profile # nolocalpath
install -o player -g player -m 0755 /etc/skel/.xinitrc /home/player/.xinitrc           # nolocalpath
