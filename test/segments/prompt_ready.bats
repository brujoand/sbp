#!/usr/bin/env bats

load segment_helper

@test "test a normal prompt_ready segment" {
  export SETTINGS_PROMPT_READY_VI_MODE
  export SETTINGS_PROMPT_READY_ICON='x'
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$SETTINGS_PROMPT_READY_ICON"
}

