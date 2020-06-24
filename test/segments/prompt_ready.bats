#!/usr/bin/env bats

load segment_helper

@test "test a normal prompt_ready segment" {
  export SEGMENTS_PROMPT_READY_VI_MODE
  export SEGMENTS_PROMPT_READY_ICON='x'
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'prompt_ready'
  assert_equal "${result[1]}" "$SEGMENTS_PROMPT_READY_ICON"
}

