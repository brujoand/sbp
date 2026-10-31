#!/usr/bin/env bats

load segment_helper

execute::execute_nohup_function() {
  "$@"
}

_sbp_get_current_time() {
  printf -v "$1" '%s' 1000
}

# shellcheck disable=SC2329
op() {
  echo called >>"${TMP_DIR}/op_calls"
  [[ -z $OP_SIGNED_OUT ]] || return 1
  printf '{"url":"https://acme.1password.com","email":"a@example.com"}\n'
}

setup() {
  export SBP_TMP="$TMP_DIR"
  export SEGMENTS_1PASSWORD_REFRESH_RATE=60
  export OP_SIGNED_OUT=''
  command rm -f "${TMP_DIR}/1password" "${TMP_DIR}/1password.checked" "${TMP_DIR}/op_calls"
}

@test "test 1password segment is hidden without op" {
  unset -f op
  result="$(PATH=/nonexistent execute_segment)"
  assert_equal "$result" ''
  [[ ! -f "${TMP_DIR}/1password.checked" ]]
}

@test "test 1password segment prints nothing until the first refresh is done" {
  result="$(execute_segment)"
  assert_equal "$result" ''
  [[ -f "${TMP_DIR}/1password" ]]
}

@test "test 1password segment shows the account when signed in" {
  execute_segment
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'op'
  assert_equal "${result[2]}" 'acme'
}

@test "test 1password segment highlights when signed out" {
  OP_SIGNED_OUT=1
  execute_segment
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" 'op'
  assert_equal "${result[2]}" 'signed out'
}

@test "test 1password segment omits an account it cannot parse" {
  op() {
    printf '{}\n'
  }
  execute_segment
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'op'
}

@test "test 1password segment does not call op within the refresh rate" {
  printf '%s\n' 950 >"${TMP_DIR}/1password.checked"
  execute_segment
  [[ ! -f "${TMP_DIR}/op_calls" ]]
}

@test "test 1password segment calls op when the refresh rate has passed" {
  printf '%s\n' 940 >"${TMP_DIR}/1password.checked"
  execute_segment
  [[ -f "${TMP_DIR}/op_calls" ]]
  read -r checked <"${TMP_DIR}/1password.checked"
  assert_equal "$checked" 1000
}
