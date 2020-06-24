#!/usr/bin/env bats

load hook_helper

hooks::alert_notify() {
  for argument in "${@}"; do
    [[ -z "$argument" ]] && continue
    printf '%s\n' "$argument"
  done
}

@test "test an okay alert hook" {
  HOOKS_ALERT_THRESHOLD=1
  COMMAND_DURATION=20
  COMMAND_EXIT_CODE=0

  mapfile -t result <<< "$(execute_hook)"
  expected_title="Command Succeded"
  expected_message="Time spent was ${COMMAND_DURATION}s"


  assert_equal "${#result[@]}"  2
  assert_equal "${result[0]}" "$expected_title"
  assert_equal "${result[1]}" "$expected_message"
}

