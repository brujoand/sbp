#! /usr/bin/env bash
KUBE_CONFIG="${HOME}/.kube/config"

segments::k8s() {
  [[ -f "$KUBE_CONFIG" ]] || return 0
  context="$(sed -n 's/.*current-context: \(.*\)/\1/p' "$KUBE_CONFIG")"
  [[ -z "$context" ]] && return 0
  namespace="$(pcregrep -M -- "- context:\n(^\s\s\w*.*\n)*  name: ${context}" ${KUBE_CONFIG} | sed -n 's/ *namespace: \(\w*\)/\1/p')"
  if [[ -z "$namespace" ]]; then
    namespace='default'
  fi

  if [[ -z $namespace || "$SEGMENTS_K8S_HIDE_CLUSTER" -eq 1 ]]; then
    segment="${context}"
  else
    segment="${context}/${namespace}"
  fi

  print_themed_segment 'normal' "${segment,,}"
}
