source "${SBP_PATH}/src/debug.bash"
source "${SBP_PATH}/test/asserts.bash"

export COMMAND_EXIT_CODE=0
export COMMAND_DURATION=0
SEGMENT_NAME="$(basename "$BATS_TEST_FILENAME" .bats)"
TMP_DIR=$(mktemp -d) && trap 'rm -rf "$TMP_DIR"' EXIT;

source_segment() {
  segment_source="${SBP_PATH}/src/segments/${SEGMENT_NAME}.bash"

  if [[ ! -f "$segment_source" ]]; then
    debug::log_error "Could not find $segment_source"
    return 1
  fi
  source "$segment_source"
}

execute_segment() {
  "segments::${SEGMENT_NAME}"
}

print_themed_segment () {
  for argument in "${@}"; do
    [[ -z "$argument" ]] && continue
    printf '%s\n' "$argument"
  done
}

export -f print_themed_segment

source_segment

