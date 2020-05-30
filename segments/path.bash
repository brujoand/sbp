#! /usr/bin/env bash

segment_generate_path() {
  local segment_max_length=$4

  local wdir=${PWD/${HOME}/\~}

  if [[ "${#wdir}" -gt "$segment_max_length" ]]; then
    folder=${wdir##*/}
    IFS='/' wdir=$(for p in ${wdir}; do printf '%s/' "${p:0:1}"; done;)
    wdir="${wdir%/*}${folder:1}"
  fi

  IFS=/ read -r -a wdir_array <<<"${wdir}"
  if [[ $settings_path_splitter_disable -ne 1 && "${#wdir_array[@]}" -gt 1 ]]; then
    declare -a segments
    for dir in "${wdir_array[@]}"; do
      if [[ -n "$dir" ]]; then
        segments+=("$dir")
      fi
    done
    print_themed_segment 'normal' "${segments[@]}"
  else
    print_themed_segment 'normal' "$wdir"
  fi
}
