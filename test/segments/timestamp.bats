#!/usr/bin/env bats

load segment_helper

@test "test a normal timestamp" {
  SEGMENTS_TIMESTAMP_FORMAT='%H:%M:%S'
  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
}

