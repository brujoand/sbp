#! /usr/bin/env bash
[[ -z $KUBECONFIG ]] && KUBECONFIG="${HOME}/.kube/config"

segments::k8s() {
  [[ -f $KUBECONFIG ]] || return 0

  local line context='' namespace='default' entry_name='' entry_namespace=''
  local namespace_re='^[[:space:]]*namespace:[[:space:]]*["'\'']?([^[:space:]#"'\'']*)'
  local -a lines
  mapfile -t lines <"$KUBECONFIG"

  for line in "${lines[@]}"; do
    if [[ $line =~ ^[[:space:]]*current-context:[[:space:]]*(.*)$ ]]; then
      context=${BASH_REMATCH[1]}
      break
    fi
  done
  [[ -z $context ]] && return 0

  for line in "${lines[@]}"; do
    [[ $line =~ ^[[:space:]]*-[[:space:]] ]] && entry_name='' entry_namespace=''

    if [[ $line =~ ^[-[:space:]]*name:[[:space:]]*(.*)$ ]]; then
      entry_name=${BASH_REMATCH[1]}
    elif [[ $line =~ $namespace_re ]]; then
      entry_namespace=${BASH_REMATCH[1]}
    fi

    if [[ $entry_name == "$context" && -n $entry_namespace ]]; then
      namespace=$entry_namespace
      break
    fi
  done

  local segment_icon_char="${SEGMENTS_K8S_ICON:-⎈}"

  if [[ $SEGMENTS_K8S_HIDE_CLUSTER -eq 1 ]]; then
    segment="${segment_icon_char} ${context}"
  else
    segment="${segment_icon_char} ${context}/${namespace}"
  fi

  print_themed_segment 'normal' "${segment,,}"
}
