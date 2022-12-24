#!/usr/bin/env bats

load segment_helper

@test "test that we recognize a Conda profile" {
  export CONDA_DEFAULT_ENV='my_env'
  mapfile -t result <<<"$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$CONDA_DEFAULT_ENV"
}

@test "test that we do nothing without a Conda profile" {
  unset CONDA_DEFAULT_ENV
  local result
  result="$(execute_segment)"
  assert_equal "$result" ''
}
