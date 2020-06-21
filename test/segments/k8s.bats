#!/usr/bin/env bats

load segment_helper

setup() {
  export KUBE_CONFIG="${TMP_DIR}/config"
  cat << EOF > "$KUBE_CONFIG"
  current-context: project/k8s:443/sbp
  kind: Config
  preferences: {}
  users:
  - name: sbp/k8s:443
    user:
      token: some_token
EOF
}

@test "test no config k8s segment" {
  rm "$KUBE_CONFIG"
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test normal config k8s segment" {
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" 'sbp@k8s/project'
}
