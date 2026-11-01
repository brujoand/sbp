#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR"
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_STATE_HOME
}

@test "test that sourcing sbp keeps an existing EXIT trap" {
  run bash --norc -ic 'trap "echo user trap \$?" EXIT; source "$SBP_PATH/sbp.bash"; (exit 3); exit 3'

  [[ $output == *"user trap 3"* ]]
}

@test "test that sourcing sbp removes its setup helper" {
  run bash --norc -ic 'source "$SBP_PATH/sbp.bash"; declare -F _sbp_clean_tmp_on_exit || echo "helper removed"'

  [[ $output == *"helper removed"* ]]
}

@test "test that the temp folder is removed on exit" {
  run bash --norc -ic 'source "$SBP_PATH/sbp.bash"; echo "tmp=$SBP_TMP"'

  [[ $output =~ tmp=([^[:space:]]+) ]]
  [[ ! -e ${BASH_REMATCH[1]} ]]
}

@test "test that a reload keeps the temp folder and the trap" {
  run bash --norc -ic 'source "$SBP_PATH/sbp.bash"; first=$SBP_TMP; sbp reload; [[ $first == "$SBP_TMP" ]] && echo "same=$SBP_TMP"; trap -p EXIT'

  [[ $output =~ same=([^[:space:]]+) ]]
  [[ ! -e ${BASH_REMATCH[1]} ]]
  [[ $output == *"trap -- 'command rm -rf"* ]]
}
