#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "test a variable based python_env segment" {
  VIRTUAL_ENV='3.5'
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$VIRTUAL_ENV"
}

@test "test a file based python_env segment" {
  version='3.5'
  echo "$version" > .python-version
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "$version"
}
