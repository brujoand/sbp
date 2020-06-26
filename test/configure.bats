#!/usr/bin/env bats

load src_helper

setup() {
  SBP_CONFIG="${TMP_DIR}/local_config"
  mkdir -p ${SBP_CONFIG}/{hooks,layouts,segments,colors}
  SBP_PATH="${TMP_DIR}/default_source"
  mkdir -p ${SBP_PATH}/src/{hooks,layouts,segments,colors}
}

# List feature files in all various combinations

@test "test that configure can list hook files" {
  touch "${SBP_CONFIG}/hooks/alert.bash"
  mapfile -t result <<< "$(configure::list_feature_files 'hooks')"
  assert_equal "${#result[@]}" 1
  assert_equal "${result[0]}" "${SBP_CONFIG}/hooks/alert.bash"
}

@test "test that configure can list segment files" {
  touch ${SBP_PATH}/src/segments/{1..12}.bash
  mapfile -t result <<< "$(configure::list_feature_files 'segments')"
  assert_equal "${#result[@]}" 12
}

@test "test that configure can list layout files" {
  touch ${SBP_PATH}/src/layouts/{1..4}.bash
  touch ${SBP_CONFIG}/layouts/{1..4}.bash
  mapfile -t result <<< "$(configure::list_feature_files 'layouts')"
  assert_equal "${#result[@]}" 8
}

@test "test that configure can list color files" {
  touch ${SBP_PATH}/src/colors/{1..4}.bash
  touch ${SBP_CONFIG}/colors/{1..4}.bash
  mapfile -t result <<< "$(configure::list_feature_files 'colors')"
  assert_equal "${#result[@]}" 8
}

# List feature names depends very much on listing files, so just test that it works for one

@test "test that we can list feature names" {
  touch ${SBP_CONFIG}/colors/sbp.bash
  mapfile -t result <<< "$(configure::list_feature_names 'colors')"
  assert_equal "${#result[@]}" 1
  assert_equal "${result[0]}" 'sbp'
}

@test "test that we can set the correct colors" {
  local local_config="${SBP_CONFIG}/colors/local.bash"
  local global_config="${SBP_PATH}/src/colors/global.bash"
  touch "$global_config"
  touch "$local_config"
  source(){ echo "$@"; }
  result="$(configure::set_colors 'local')"
  assert_equal "$result" "$local_config"
  result="$(configure::set_colors 'global')"
  assert_equal "$result" "$global_config"
}

@test "test that we can set the correct layouts" {
  local local_config="${SBP_CONFIG}/layouts/local.bash"
  local global_config="${SBP_PATH}/src/layouts/global.bash"
  touch "$global_config"
  touch "$local_config"
  source(){ echo "$@"; }
  result="$(configure::set_layout 'local')"
  assert_equal "$result" "$local_config"
  result="$(configure::set_layout 'global')"
  assert_equal "$result" "$global_config"
}

