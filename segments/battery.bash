#! /usr/bin/env bash

command_exit_code=$1
command_time=$2
segment_direction=$3
timer_m=0
timer_s=0

if [[ uname == "Darwin" ]]; then
  pmset -g batt
fi

if [[ "$command_exit_code" -lt 0 || "$command_exit_code" -eq 130 ]]; then
  command_time=0
fi

if [[ "$command_exit_code" -le 0 || "$command_exit_code" -eq 130 ]]; then
  command_color_bg="$settings_command_color_bg"
  command_color_fg="$settings_command_color_fg"
else
  command_color_bg="$settings_command_color_bg_error"
  command_color_fg="$settings_command_color_fg_error"
fi

if [[ "$command_time" -gt 0 ]]; then
  timer_m=$(( command_time / 60 ))
  timer_s=$(( command_time % 60 ))
fi

command_value="last: ${timer_m}m ${timer_s}s"

pretty_print_segment "$command_color_fg" "$command_color_bg" " ${command_value} " "$segment_direction"

