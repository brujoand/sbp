#!/usr/bin/env bats

load segment_helper

@test "test a normal prompt_ready segment" {
  export SETTINGS_PROMPT_READY_VI_MODE
  export SETTINGS_PROMPT_READY_ICON='x'
  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"

  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == "$SETTINGS_PROMPT_READY_ICON" ]]
}

