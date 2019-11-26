#! /usr/bin/env bash

segment_direction=$3

segment_value="${VIRTUAL_ENV##*/}"

if [[ -n "$segment_value" ]]; then
  pretty_print_segment "$settings_python_virtual_env_fg" "$settings_python_virtual_env_bg" " ${segment_value} " "$segment_direction"
fi
