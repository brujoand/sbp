#!/usr/bin/env bats

load segment_helper

@test "test a good command segment" {
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'last: 0m 0s'
}

@test "test a bad command segment" {
  export COMMAND_EXIT_CODE=1
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" 'last: 0m 0s'
}

@test "test a long command segment" {
  export COMMAND_DURATION=99
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'last: 1m 39s'
}
