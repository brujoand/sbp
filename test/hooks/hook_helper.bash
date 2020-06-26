source "${SBP_PATH}/src/debug.bash"
source "${SBP_PATH}/test/asserts.bash"

export COMMAND_EXIT_CODE=0
export COMMAND_DURATION=0
HOOK_NAME="$(basename "$BATS_TEST_FILENAME" .bats)"
TMP_DIR=$(mktemp -d) && trap 'rm -rf "$TMP_DIR"' EXIT;

source_hook() {
  hook_source="${SBP_PATH}/src/hooks/${HOOK_NAME}.bash"

  if [[ ! -f "$hook_source" ]]; then
    debug::log_error "Could not find $hook_source"
    exit 1
  fi
  source "$hook_source"
}

execute_hook() {
  "hooks::${HOOK_NAME}"
}

source_hook

