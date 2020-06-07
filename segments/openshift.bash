#! /usr/bin/env bash
segment_generate_openshift() {
  if grep -q token "${HOME}/.kube/config" &>/dev/null; then
    config="$(sed -n 's|current-context: \(.*\)/\(.*\)/\(.*\)$|\1;\2;\3|p' "${HOME}/.kube/config")"
    project="$(cut -d ';' -f 1 <<<"$config")"
    cluster="$(cut -d ';' -f 2 <<<"$config" | sed 's/:443//')"
    user="$(cut -d ';' -f 3 <<<"$config")"

    if [[ "${user,,}" == "${SETTINGS_OPENSHIFT_DEFAULT_USER,,}" ]]; then
      if [[ "$SETTINGS_OPENSHIFT_HIDE_CLUSTER" -eq 1 ]]; then
        segment="${project}"
      else
        segment="${cluster}:${project}"
      fi
    else
      segment="${user}@${cluster}:${project}"
    fi

    print_themed_segment 'normal' "$segment"
  fi
}
