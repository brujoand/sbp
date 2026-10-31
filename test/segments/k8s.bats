#!/usr/bin/env bats

load segment_helper

setup() {
  export SEGMENTS_K8S_ICON='*'
  export KUBECONFIG="${TMP_DIR}/config"
  export SEGMENTS_MAX_LENGTH=99
  cat <<EOF >"$KUBECONFIG"
  current-context: sbp-prj
  kind: Config
  preferences: {}
  users:
  - name: sbp/k8s:443
    user:
      token: some_token
EOF
}

@test "test no config k8s segment" {
  command rm "${KUBECONFIG}"
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test normal config k8s segment" {
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '* sbp-prj/default'
}

@test "test shortened segment" {
  export SEGMENTS_MAX_LENGTH=15
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '* sbp-prj/def..' # 15 characters
}
