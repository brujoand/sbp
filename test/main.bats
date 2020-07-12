#!/usr/bin/env bats

source "${SBP_PATH}/test/asserts.bash"

SRC_NAME="$(basename "$BATS_TEST_FILENAME" .bats)"
TMP_DIR=$(mktemp -d) && trap 'rm -rf "$TMP_DIR"' EXIT;

setup() {
  export SBP_CONFIG="${TMP_DIR}/local_config"
  mkdir -p ${SBP_CONFIG}/{hooks,segments,peekabo,tmp}
  cp "${SBP_PATH}/config/"*.conf "${SBP_CONFIG}"
  export SBP_TMP="${SBP_CONFIG}/tmp"
  export COLUMNS=144
}

@test "test that we can create a perfect prompt" {
  local command_status=0
  local command_duration=0
  PS1=$(bash "${SBP_PATH}/src/main.bash" "$command_status" "$command_duration")
  # This needs some more thought
  [[ -n "$PS1" ]]

}
