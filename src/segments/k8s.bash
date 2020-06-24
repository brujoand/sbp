#! /usr/bin/env bash
KUBE_CONFIG="${HOME}/.kube/config"

segments::k8s() {
  [[ -f "$KUBE_CONFIG" ]] || return 0
  context="$(sed -n 's/.*current-context: \(.*\)/\1/p' "$KUBE_CONFIG")"
  [[ -z "$context" ]] && return 0
  user=${context##*/}
  namespace_and_host=${context%/*}
  host=${namespace_and_host##*/}
  host=${host%:*}
  namespace=${namespace_and_host%/*}

  if [[ "${user,,}" == "${SEGMENTS_K8S_DEFAULT_USER,,}" ]]; then
    if [[ "$SEGMENTS_K8S_HIDE_CLUSTER" -eq 1 ]]; then
      segment="${namespace}"
    else
      segment="${host}:${namespace}"
    fi
  else
    segment="${user}@${host}/${namespace}"
  fi

  print_themed_segment 'normal' "${segment,,}"
}
