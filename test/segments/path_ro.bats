#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "test a normal path segment" {
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test a read only path segment" {
  mkdir ro
  chmod 0555 ro
  cd ro
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" ""
}

