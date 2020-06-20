#!/usr/bin/env bats

load segment_helper

@test "test a normal timestamp" {
  SETTINGS_TIMESTAMP_FORMAT='%H:%M:%S'
  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"

  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" =~ ^[0-2][0-9]:[0-6][0-9]:[0-6][0-9]$ ]]
}

