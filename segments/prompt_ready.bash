#! /usr/bin/env bash

segment_direction=$3
if [[ "$settings_prompt_ready_vi_mode" -eq 1 ]]; then
  exit 0
fi

pretty_print_segment "$settings_prompt_ready_color_primary" "$settings_prompt_ready_color_secondary" " ${settings_prompt_ready_icon} " "$segment_direction"


