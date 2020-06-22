#!/usr/bin/env bats

load segment_helper

@test "test that we recognize a normal user" {
  unset SSH_CLIENT
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$USER"
}

@test "test that we recognize an ssh session" {
  export SSH_CLIENT=yes
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "${USER}@${HOSTNAME}"
}

@test "test that we recognize the root user" {
  unset SSH_CLIENT
  export user_id=0
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" "$USER"
}
