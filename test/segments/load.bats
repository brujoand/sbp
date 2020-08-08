#!/usr/bin/env bats

load segment_helper

setup() {
  cd "$TMP_DIR"
}

@test "that we can get cpu_cores" {
  result="$(segments::load_get_cpu_count)"

  [[ $result -gt 0 ]]
}

@test "that we can get load_avg" {
  result="$(segments::load_get_load_avg)"

  [[ -n $result ]]
}

@test "test a file based python_env segment" {
  segments::load_get_load_avg() {
    echo 0.25
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "6"
}
