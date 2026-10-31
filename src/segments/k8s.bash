#! /usr/bin/env bash
[[ -z $KUBECONFIG ]] && KUBECONFIG="${HOME}/.kube/config"

segments::k8s() {
  local max_length="${SEGMENTS_MAX_LENGTH}"
  local segment_icon_char="${SEGMENTS_K8S_ICON:-⎈}"

  [[ -f ${KUBECONFIG} ]] || return 0
  context="$(sed -n 's/.*current-context: \(.*\)/\1/p' "${KUBECONFIG}")"
  [[ -z ${context} ]] && return 0

  namespace="$(grep -Pzo "(?s)\n\-\s*context:\n(\s+\w[^\n]*\n)*\s*name: ${context}" "${KUBECONFIG}" | tr '\0' '\n' | sed -n 's/ *namespace: \(\w*\)/\1/p')"
  if [[ -z ${namespace} ]]; then
    namespace='default'
  fi

  segment="${segment_icon_char} ${context}/${namespace}"
  if [[ -n ${namespace} && ${SEGMENTS_K8S_HIDE_CLUSTER} -ne 1 ]]; then
    segment="${segment_icon_char} ${context}/${namespace}"
  fi

  if [[ ${#segment} -gt ${max_length} && ${max_length} -ne -1 ]]; then
    segment="${segment:0:$((max_length - 2))}.."
  fi

  print_themed_segment 'normal' "${segment,,}"
}
