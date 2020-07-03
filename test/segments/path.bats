#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "test a normal path segment" {
  mapfile -t result <<< "$(execute_segment)"
  dir_slashes="${TMP_DIR//[^\/]}"
  dir_count="${#dir_slashes}"
  assert_equal "${#result[@]}" $(( dir_count + 1 ))
  assert_equal "${result[0]}" 'normal'
}

@test "test a non-split path segment" {
  export SEGMENTS_PATH_SPLITTER_DISABLE=1
  export SEGMENTS_MAX_LENGTH=99
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$TMP_DIR"
}

