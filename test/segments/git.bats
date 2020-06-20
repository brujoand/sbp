#!/usr/bin/env bats

load segment_helper

setup() {
  export SETTINGS_GIT_MAX_LENGTH=99
  export SETTINGS_GIT_ICON=''

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
  [[ "${#result[@]}" -eq 2 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == 'master' ]]
}

@test "test untracked git segment" {
  touch this and that
  mapfile -t result <<< "$(execute_segment)"
  [[ "${#result[@]}" -eq 3 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == '?3' ]]
  [[ "${result[2]}" == 'master' ]]
}

@test "test commited git segment" {
  touch this and that
  git add . &>/dev/null

  mapfile -t result <<< "$(execute_segment)"
  echo "${result[@]}"
  [[ "${#result[@]}" -eq 3 ]]
  [[ "${result[0]}" == 'normal' ]]
  [[ "${result[1]}" == '+3' ]]
  [[ "${result[2]}" == 'master' ]]
}
