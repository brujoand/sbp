#! /usr/bin/env bash

_sbp_timer_tick "Starting"
segment_direction=$3
segment_max_length=$4

path_value=
wdir=${PWD/${HOME}/\~}

_sbp_timer_tick "checking maxlength"
if [[ "${#wdir}" -gt "$segment_max_length" ]]; then
  folder=${wdir##*/}
  IFS='/' wdir=$(for p in ${wdir}; do printf '/%s' "${p:0:1}"; done;)
  wdir="${wdir}${folder:1}"
fi

_sbp_timer_tick "starting main job"
IFS=/ read -r -a wdir_array <<<"${wdir}"
if [[ $settings_path_splitter_disable -ne 1 && "${#wdir_array[@]}" -gt 1 ]]; then
  if [[ "$segment_direction" == 'right' ]]; then
    splitter_character="$settings_segment_splitter_right"
  else
    splitter_character="$settings_segment_splitter_left"
  fi

  splitter_colors=$(print_colors "$settings_path_splitter_color" "$settings_path_color_bg")
  splitter_segment="${splitter_colors}${splitter_character}"

  _sbp_timer_tick "starting to iterate"
  for i in "${!wdir_array[@]}"; do
    dir=${wdir_array["$i"]}
    if [[ -n "$dir" ]]; then
      segment_color=$(print_colors "$settings_path_color_fg" "$settings_path_color_bg")
      segment_value="${segment_color} ${dir} "
      [[ "$(( i + 1 ))" -eq "${#wdir_array[@]}" ]] && unset splitter_segment
      path_value="${path_value}${segment_value}${splitter_segment}"
    fi
  done
else
  path_value=" $wdir "
fi

_sbp_timer_tick "ready for pretty print"
pretty_print_segment "$settings_path_color_fg" "$settings_path_color_bg" "${path_value}" "$segment_direction"
_sbp_timer_tick "done pretty print"

