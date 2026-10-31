#!/usr/bin/env bats

load segment_helper

setup() {
  export SEGMENTS_LOAD_THRESHOLD=50
  export SEGMENTS_LOAD_THRESHOLD_HIGH=80
  cd "$TMP_DIR" || exit 1
}

@test "that we can get cpu_cores" {
  result="$(segments::load_get_cpu_count)"

  [[ $result -gt 0 ]]
}

@test "that we can get load_avg" {
  result="$(segments::load_get_load_avg)"

  [[ -n $result ]]
}

@test "test below threshold" {
  segments::load_get_load_avg() {
    echo 19.9
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test equal to threshold" {
  segments::load_get_load_avg() {
    echo 20.0
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '50'
}

@test "test above threshold" {
  segments::load_get_load_avg() {
    echo 20.4
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '51'
}

@test "test below high threshold" {
  segments::load_get_load_avg() {
    echo 31.9
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '79'
}

@test "test equal to high threshold" {
  segments::load_get_load_avg() {
    echo 32.0
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" '80'
}

@test "test above high threshold" {
  segments::load_get_load_avg() {
    echo 32.4
  }

  segments::load_get_cpu_count() {
    echo 4
  }

  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'highlight'
  assert_equal "${result[1]}" '81'
}
