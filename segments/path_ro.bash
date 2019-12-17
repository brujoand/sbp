#! /usr/bin/env bash

segment_direction=$3

if [[ ! -w "$PWD" ]] ; then
  segment_value=""
  pretty_print_segment "$settings_path_readonly_color_primary" "$settings_path_readonly_color_secondary" " ${segment_value}" "$segment_direction"
fi
