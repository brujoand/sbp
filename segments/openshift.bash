#! /usr/bin/env bash
segment_direction=$3
if grep -q token "${HOME}/.kube/config"; then
  config="$(sed -n 's|current-context: \(.*\)/\(.*\)/\(.*\)$|\1;\2;\3|p' "${HOME}/.kube/config")"
  project="$(cut -d ';' -f 1 <<<"$config")"
  server="$(cut -d ';' -f 2 <<<"$config" | sed 's/:443//')"
  user="$(cut -d ';' -f 3 <<<"$config")"

  if [[ "${user,,}" == "${settings_openshift_default_user,,}" ]]; then
    segment="${server}:${project}"
  else
    segment="${user}@${server}:${project}"
  fi

  pretty_print_segment "$settings_openshift_color_fg" "$settings_openshift_color_bg" " ${segment} " "$segment_direction"
fi
