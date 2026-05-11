#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

run_with_paths() {
    sed \
        -e "s|/mnt/storage-fast|${TEST_DIR}/FAST|g" \
        -e "s|/mnt/storage|${TEST_DIR}/STOR|g" \
        -e "s|/tmp/poe2-iso|${TEST_DIR}/tmp/poe2-iso|g" \
        -e "s|${TEST_DIR}/FAST|${TEST_DIR}/mnt/storage-fast|g" \
        -e "s|${TEST_DIR}/STOR|${TEST_DIR}/mnt/storage|g" \
        scripts/build/iso_store_dir.sh | sh
}

@test "prefers /mnt/storage-fast when it exists" {
    mkdir -p "$TEST_DIR/mnt/storage-fast"
    mkdir -p "$TEST_DIR/mnt/storage"
    run run_with_paths
    [ "$status" -eq 0 ]
    [[ "$output" =~ storage-fast/poe2-iso ]]
}

@test "falls back to /mnt/storage when no storage-fast" {
    mkdir -p "$TEST_DIR/mnt/storage"
    run run_with_paths
    [ "$status" -eq 0 ]
    [[ "$output" =~ storage/poe2-iso ]]
    [[ ! "$output" =~ storage-fast ]]
}

@test "falls back to /tmp when no storage" {
    run run_with_paths
    [ "$status" -eq 0 ]
    [[ "$output" =~ tmp/poe2-iso ]]
}

@test "creates poe2-iso directory" {
    mkdir -p "$TEST_DIR/mnt/storage"
    run_with_paths
    [ -d "$TEST_DIR/mnt/storage/poe2-iso" ]
}
