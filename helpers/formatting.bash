#! /usr/bin/env bash

function print_colorized() { # prints ansi escape codes for fg and bg (optional)
  local fg_code=$1
  local bg_code=$2
  local bg_escaped="\[\e[49m\]"
  local fg_escaped="\[\e[39m\]"
  [[ "$fg_code" -lt 0 ]] || fg_escaped="\[\e[38;5;${fg_code}m\]"
  [[ "$bg_code" -lt 0 ]] || bg_escaped="\[\e[48;5;${bg_code}m\]"

  printf '%s' "${fg_escaped}${bg_escaped}"
}

function print_bg_color() {
  local bg_code=$1
  local bg_escaped="\[\e[49m\]"
  [[ "$bg_code" -lt 0 ]] || bg_escaped="\[\e[48;5;${bg_code}m\]"

  printf '%s' "${bg_escaped}"
}

function print_fg_color() {
  local fg_code=$1
  local fg_escaped="\[\e[39m\]"
  [[ "$fg_code" -lt 0 ]] || fg_escaped="\[\e[38;5;${fg_code}m\]"

  printf '%s' "${fg_escaped}"
}

function reset_colors() {
  print_colorized  "$settings_default_fg" "$settings_default_bg"
}

function pretty_print_segment() {
  local segment_color_fg="$1"
  local segment_color_bg="$2"
  local segment_value="$3"
  local segment_direction="$4"

  [[ -z "$segment_value" ]] && return 0

  seperator="$(pretty_print_seperator "$segment_color_bg" "$segment_direction")"
  segment="$(print_colorized "$segment_color_fg" "$segment_color_bg")${segment_value}"
  prepare_color="$(print_fg_color "$segment_color_bg")"
  full_output="${seperator}${segment}${prepare_color}"
  printf '%s' "$full_output"
}


function pretty_print_seperator() {
  local to_color=$1
  local direction=$2

  case $direction in
    right)
      printf '%s' "$(print_bg_color "$to_color")$settings_char_segment"
    ;;
    left)
      printf '%s' "$(print_fg_color "$to_color")$settings_char_segrev"
      ;;
  esac
}

function strip_escaped_colors() {
  sed -E 's/\\\[\\e\[([0-9]+;[0-9]+;)?[0-9]+m\\\]//g' <<< "$1"
}

export -f pretty_print_segment
export -f pretty_print_seperator
export -f print_colorized
export -f reset_colors
export -f print_bg_color
export -f print_fg_color
