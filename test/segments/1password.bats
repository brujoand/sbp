#!/usr/bin/env bats

load segment_helper

# shellcheck disable=SC2329
op() {
  [[ -z $OP_SIGNED_OUT ]] || return 1
  printf 'URL:          https://acme.1password.com\n'
  printf 'Email:        a@example.com\n'
  printf 'User ID:      ABC123\n'
  printf 'User Type:    HUMAN\n'
}

setup() {
  export OP_SIGNED_OUT=''
}

@test "test 1password segment is hidden without op" {
  unset -f op
  result="$(PATH=/nonexistent execute_segment)"
  assert_equal "$result" ''
}

@test "test 1password segment shows the account when signed in" {
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'op'
  assert_equal "${result[2]}" 'acme'
}

@test "test 1password segment highlights when signed out" {
  OP_SIGNED_OUT=1
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" 'op'
  assert_equal "${result[2]}" 'signed out'
}

@test "test 1password segment omits an account it cannot parse" {
  op() {
    printf 'unexpected\n'
  }
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'op'
}
