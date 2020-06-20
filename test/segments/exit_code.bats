#!/usr/bin/env bats

load segment_helper

@test "test a good exit_code segment" {
  result="$(execute_segment)"
  [[ -z "$result" ]]
}

@test "test a bad command segment" {
  export COMMAND_EXIT_CODE=1
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'highlight' ]]
  [[ "${result[1]}" == '1' ]]
}
