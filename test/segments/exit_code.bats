#!/usr/bin/env bats

load segment_helper

@test "test a good exit_code segment" {
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test a bad command segment" {
  export COMMAND_EXIT_CODE=1
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" '1'
}
