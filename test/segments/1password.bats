#!/usr/bin/env bats

load segment_helper

# shellcheck disable=SC2329
op() {
  [[ -z $OP_SIGNED_OUT ]]
}

setup() {
  export OP_SIGNED_OUT=''
}

@test "test 1password segment is hidden without op" {
  unset -f op
  result="$(PATH=/nonexistent execute_segment)"
  assert_equal "$result" ''
}

@test "test 1password segment shows the key when signed in" {
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '⚿'
}

@test "test 1password segment highlights the key when signed out" {
  OP_SIGNED_OUT=1
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" '⚿'
}
