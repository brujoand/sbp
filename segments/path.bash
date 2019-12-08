#! /usr/bin/env bash

segment_direction=$3
segment_max_length=$4

path_value=
wdir=${PWD/${HOME}/\~}

if [[ "${#wdir}" -gt "$segment_max_length" ]]; then
  folder=${wdir##*/}
  IFS='/' wdir=$(for p in ${wdir}; do printf '/%s' "${p:0:1}"; done;)
  wdir="${wdir}${folder:1}"
fi

IFS=/ read -r -a wdir_array <<<"${wdir}"
if [[ $settings_path_splitter_disable -eq 0 && "${#wdir_array[@]}" -gt 1 ]]; then
  if [[ "$segment_direction" == 'right' ]]; then
    segment_seperator=$(pretty_print_segment "$settings_path_splitter_color" "$settings_path_color_bg" "$settings_segment_splitter_right")
  else
    segment_seperator=$(pretty_print_segment "$settings_path_splitter_color" "$settings_path_color_bg" "$settings_segment_splitter_left")
  fi

  for i in "${!wdir_array[@]}"; do
    dir=${wdir_array["$i"]}
    if [[ -n "$dir" ]]; then
      segment_value=$(pretty_print_segment "$settings_path_color_fg" "$settings_path_color_bg" " $dir ")
      [[ "$(( i + 1 ))" -eq "${#wdir_array[@]}" ]] && unset segment_seperator
      path_value="${path_value}${segment_value}${segment_seperator}"
    fi
  done
else
  path_value=" $wdir "
fi

pretty_print_segment "$settings_path_color_fg" "$settings_path_color_bg" "${path_value}" "$segment_direction"

