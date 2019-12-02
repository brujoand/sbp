#!/usr/bin/env bash

segment_direction=$3
cache_file="${cache_folder}/rescuetime.csv"

if [[ -f "$cache_file" ]]; then
  cache=$(<"$cache_file")
  pulse="${cache/;*}"
  time="${cache/*;}"
else
  pulse="0%"
  time="0h:0m"
fi

if [[ "$segment_direction" = 'right' ]]; then
  segment_seperator=$(pretty_print_segment "$settings_rescuetime_sep_fg" "$settings_rescuetime_bg" "$settings_char_path")
else
  segment_seperator=$(pretty_print_segment "$settings_rescuetime_sep_fg" "$settings_rescuetime_bg" "$settings_char_pathrev")
fi

time_segment=$(pretty_print_segment "$settings_rescuetime_fg" "$settings_rescuetime_bg" "${time}")
segment_value="${pulse} ${segment_seperator} ${time_segment}"

pretty_print_segment "$settings_rescuetime_fg" "$settings_rescuetime_bg" " ${segment_value} " "$segment_direction"

