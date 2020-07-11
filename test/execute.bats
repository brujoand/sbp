#!/usr/bin/env bats

load src_helper

setup() {
  export SBP_CONFIG="${TMP_DIR}/local_config"
  mkdir -p ${SBP_CONFIG}/{hooks,segments,peekabo}
}

configure::get_feature_file() {
  local -n get_feature_file_result=$1
  local feature_type=$2
  local feature_name=$3

  get_feature_file_result="${SBP_CONFIG}/${feature_type}s/${feature_name}.bash"
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
