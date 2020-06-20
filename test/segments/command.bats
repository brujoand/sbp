#!/usr/bin/env bats

load segment_helper

@test "test a good command segment" {
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == 'last: 0m 0s' ]]
}

@test "test a bad command segment" {
  export COMMAND_EXIT_CODE=1
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'highlight' ]]
  [[ "${result[1]}" == 'last: 0m 0s' ]]
}

@test "test a long command segment" {
  export COMMAND_DURATION=99
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == 'last: 1m 39s' ]]
}
