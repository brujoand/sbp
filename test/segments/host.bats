#!/usr/bin/env bats

load segment_helper

@test "test that we recognize a normal user" {
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == "$USER" ]]
}

@test "test that we recognize an ssh session" {
  export SSH_CLIENT=yes
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == "${USER}@${HOSTNAME}" ]]
}

@test "test that we recognize the root user" {
  export user_id=0
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'highlight' ]]
  [[ "${result[1]}" == "$USER" ]]
}
