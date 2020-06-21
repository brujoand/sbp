#!/usr/bin/env bats

load segment_helper

@test "test that we recognize an AWS profile" {
  export AWS_DEFAULT_PROFILE='my_account'
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$AWS_DEFAULT_PROFILE"
}

@test "test that we do nothing without an AWS profile" {
  unset AWS_DEFAULT_PROFILE
  result="$(execute_segment)"
  assert_equal "$result" ''
}

