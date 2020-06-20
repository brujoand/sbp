#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "test a normal path segment" {
  result="$(execute_segment)"
  [[ -z "$result" ]]
}

@test "test a read only path segment" {
  mkdir ro
  chmod 0555 ro
  cd ro
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == "" ]]
}

