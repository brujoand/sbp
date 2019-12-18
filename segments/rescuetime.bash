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

splitter_segment="$(pretty_print_splitter "$settings_rescuetime_color_primary" "$settings_rescuetime_color_secondary" "$settings_rescuetime_splitter_color" "$segment_direction")"

segment_value="${pulse} ${splitter_segment} ${time}"

pretty_print_segment "$settings_rescuetime_color_primary" "$settings_rescuetime_color_secondary" " ${segment_value} " "$segment_direction"

