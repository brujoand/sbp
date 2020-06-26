#! /usr/bin/env bash
source "${SBP_PATH}/src/debug.bash"
source "${SBP_PATH}/test/asserts.bash"

SRC_NAME="$(basename "$BATS_TEST_FILENAME" .bats)"
TMP_DIR=$(mktemp -d) && trap 'rm -rf "$TMP_DIR"' EXIT;

source_src() {
  src_source="${SBP_PATH}/src/${SRC_NAME}.bash"

  if [[ ! -f "$src_source" ]]; then
    debug::log_error "Could not find $src_source"
    exit 1
  fi
  source "$src_source"
}

execute_src() {
  "srcs::${SRC_NAME}"
}

source_src

