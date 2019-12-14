#!/usr/bin/env bash

segment_direction=$3
cache_file="${cache_folder}/rescuetime.csv"

if [[ -f "$cache_file" ]]; then
  cache=$(<"$cache_file")
  pulse="${cache/;*}"
  time="${cache/*;}"
else
  exit 0
fi

if [[ "$segment_direction" == 'right' ]]; then
  splitter_character="$settings_segment_splitter_right"
else
  splitter_character="$settings_segment_splitter_left"
fi

splitter_on_color=$(print_fg_color "$settings_rescuetime_splitter_color")
splitter_off_color=$(print_fg_color "$settings_rescuetime_fg")
splitter_segment="${splitter_on_color}${splitter_character}${splitter_off_color}"


segment_value="${pulse} ${splitter_segment} ${time}"

pretty_print_segment "$settings_rescuetime_fg" "$settings_rescuetime_bg" " ${segment_value} " "$segment_direction"

