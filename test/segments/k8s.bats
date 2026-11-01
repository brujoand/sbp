#!/usr/bin/env bats

load segment_helper

setup() {
  export KUBECONFIG="${TMP_DIR}/config"
  cat <<EOF >"$KUBECONFIG"
apiVersion: v1
clusters:
- cluster:
    server: https://example.com
  name: prod
contexts:
- context:
    cluster: other
    namespace: wrong-namespace
    user: sbp
  name: other
- context:
    cluster: prod
    namespace: my-namespace
    user: sbp
  name: prod
- name: name-first
  context:
    cluster: prod
    namespace: other-namespace
    user: sbp
- context:
    cluster: prod
    user: sbp
  name: no-namespace
current-context: prod
kind: Config
preferences: {}
users:
- name: sbp
  user:
    token: some_token
EOF
}

use_context() {
  local content
  content=$(<"$KUBECONFIG")
  printf '%s\n' "${content/current-context: prod/current-context: $1}" >"$KUBECONFIG"
}

@test "test no config k8s segment" {
  command rm "$KUBECONFIG"
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test no current context k8s segment" {
  use_context ''
  result="$(execute_segment)"
  assert_equal "$result" ''
}

@test "test normal config k8s segment" {
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${#result[@]}" 2
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" '⎈ prod/my-namespace'
}

@test "test k8s context with the name before the namespace" {
  use_context 'name-first'
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${result[1]}" '⎈ name-first/other-namespace'
}

@test "test k8s context with no namespace" {
  use_context 'no-namespace'
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${result[1]}" '⎈ no-namespace/default'
}

@test "test that only the k8s namespace value is shown" {
  local value
  for value in 'my-ns # a comment' '"my-ns"' "'my-ns'" $'my-ns\r' 'my-ns   '; do
    printf 'contexts:\n- context:\n    namespace: %s\n  name: prod\ncurrent-context: prod\n' "$value" >"$KUBECONFIG"
    mapfile -t result <<<"$(execute_segment)"

    assert_equal "${result[1]}" '⎈ prod/my-ns'
  done
}

@test "test hiding the k8s namespace" {
  SEGMENTS_K8S_HIDE_CLUSTER=1
  mapfile -t result <<<"$(execute_segment)"

  assert_equal "${result[1]}" '⎈ prod'
}
