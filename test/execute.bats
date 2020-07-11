#!/usr/bin/env bats

load src_helper

setup() {
  export SBP_CONFIG="${TMP_DIR}/local_config"
  mkdir -p ${SBP_CONFIG}/{hooks,segments,peekabo}
}

# Helpers that override SBP functions
configure::get_feature_file() {
  local -n get_feature_file_result=$1
  local feature_type=$2
  local feature_name=$3

  get_feature_file_result="${SBP_CONFIG}/${feature_type}s/${feature_name}.bash"
}

segments::test_segment() {
  printf '%s\n%s\n%s\n%s\n%s' "$PRIMARY_COLOR" "$SECONDARY_COLOR" "$SPLITTER_COLOR" "$SEGMENTS_MAX_LENGTH" "$SEGMENT_POSITION"
}

@test "test that we can execute prompt hooks" {
  pipe_name="${SBP_CONFIG}/pipe"
  mkfifo "$pipe_name"

  export SBP_HOOKS=('alert')
  echo "hooks::alert() { echo 'success' > "$pipe_name"; }" > "${SBP_CONFIG}/hooks/alert.bash"
  execute::execute_prompt_hooks
  read result <$pipe_name
  assert_equal "$result" 'success'
}

@test "test that we pass the correct environment variables to segments" {
  # Segment configuration variables
  SEGMENTS_TEST_SEGMENT_COLOR_PRIMARY=0
  SEGMENTS_TEST_SEGMENT_COLOR_SECONDARY=1
  SEGMENTS_TEST_SEGMENT_COLOR_SPLITTER=2
  SEGMENTS_TEST_SEGMENT_MAX_LENGTH=3

  echo "true" > "${SBP_CONFIG}/segments/test_segment.bash"
  mapfile -t result <<< "$(execute::execute_prompt_segment 'test_segment' 'left')"
  assert_equal "${result[0]}" '0'
  assert_equal "${result[1]}" '1'
  assert_equal "${result[2]}" '2'
  assert_equal "${result[3]}" '3'
  assert_equal "${result[4]}" 'left'
}
