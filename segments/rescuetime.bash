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

if [[ "$segment_direction" = 'right' ]]; then
  segment_seperator=$(pretty_print_segment "$settings_rescuetime_splitter_color" "$settings_rescuetime_bg" "$settings_segment_splitter_right")
else
  segment_seperator=$(pretty_print_segment "$settings_rescuetime_splitter_color" "$settings_rescuetime_bg" "$settings_segment_splitter_left")
fi

time_segment=$(pretty_print_segment "$settings_rescuetime_fg" "$settings_rescuetime_bg" "${time}")
segment_value="${pulse} ${segment_seperator} ${time_segment}"

pretty_print_segment "$settings_rescuetime_fg" "$settings_rescuetime_bg" " ${segment_value} " "$segment_direction"

