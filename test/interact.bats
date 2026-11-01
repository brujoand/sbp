#!/usr/bin/env bats

load src_helper

setup() {
  export XDG_CONFIG_HOME="${TMP_DIR}/config"
  export EDITOR=echo
  source "${SBP_PATH}/src/interact.bash"
}

@test "test that sbp edit opens the files in the config folder" {
  assert_equal "$(sbp edit config)" "${XDG_CONFIG_HOME}/sbp/settings.conf"
  assert_equal "$(sbp edit colors)" "${XDG_CONFIG_HOME}/sbp/colors.conf"
}

@test "test that peekaboo toggles a file in the config folder" {
  sbp toggle peekaboo k8s
  [[ -f "${XDG_CONFIG_HOME}/sbp/peekaboo/k8s" ]]

  sbp toggle peekaboo k8s
  [[ ! -f "${XDG_CONFIG_HOME}/sbp/peekaboo/k8s" ]]
}
