#!/usr/bin/env bats

load segment_helper

setup() {
  export SEGMENTS_MAX_LENGTH=99
  export SEGMENTS_GIT_ICON=''

  cd "$TMP_DIR"
  git init &>/dev/null
  git config user.name sbp
  git config user.email sbp@sbp.sbp
  touch readme
  git add readme
  git commit -am "inital commit" &>/dev/null
}

@test "test a clean master" {
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'master'
}

@test "test untracked git segment" {
  touch this and that
  mapfile -t result <<< "$(execute_segment)"
  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '?3'
  assert_equal "${result[2]}" 'master'
}

@test "test commited git segment" {
  touch this and that
  git add . &>/dev/null

  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"
  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '+3'
  assert_equal "${result[2]}" 'master'
}

@test "test we can use an icon with git segment" {
  export SEGMENTS_GIT_ICON='@'
  touch this and that
  git add . &>/dev/null

  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"
  assert_equal "${#result[@]}" 4
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '+3'
  assert_equal "${result[2]}" "$SEGMENTS_GIT_ICON"
  assert_equal "${result[3]}" 'master'
}
