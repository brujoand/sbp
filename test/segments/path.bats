#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "test a normal path segment" {
  mapfile -t result <<< "$(execute_segment)"
  dir_slashes="${TMP_DIR//[^\/]}"
  dir_count="${#dir_slashes}"
  [[ "${#result[@]}" -eq $(( dir_count + 1 )) ]]
  [[ "${result[0]}" == 'normal' ]]
}

@test "test a non-split path segment" {
  export SETTINGS_PATH_SPLITTER_DISABLE=1
  export SETTINGS_PATH_COMPRESS_DEPTH=99
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == "$TMP_DIR" ]]
}

