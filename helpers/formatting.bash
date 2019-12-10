#! /usr/bin/env bash

function get_complement_rgb() {
  input_colors=()
  output_colors=()
  mapfile -t input_colors < <(tr ';' '\n' <<< "$1")
  for color_value in "${input_colors[@]}"; do
    output_colors+=("$(( 255 - color_value ))")
  done

  printf '%s;%s;%s' "${output_colors[0]}" "${output_colors[1]}" "${output_colors[2]}"
}

function print_colors() { # prints ansi escape codes for fg and bg (optional)
  local fg_code=$1
  local bg_code=$2

  printf '%s%s' "$(print_fg_color "$fg_code")" "$(print_bg_color "$bg_code")"
}

function print_bg_color() {
  local bg_code=$1
  if [[ -z "$bg_code" ]]; then
    bg_escaped="\[\e[49m\]"
  else
    bg_escaped="\[\e[48;2;${bg_code}m\]"
  fi

  printf '%s' "${bg_escaped}"
}

function print_fg_color() {
  local fg_code=$1
  if [[ -z "$fg_code" ]]; then
    fg_escaped="\[\e[39m\]"
  else
    fg_escaped="\[\e[38;2;${fg_code}m\]"
  fi

  printf '%s' "${fg_escaped}"
}

function pretty_print_segment() {
  local segment_color_fg="$1"
  local segment_color_bg="$2"
  local segment_value="$3"
  local segment_direction="$4"

  [[ -z "$segment_value" ]] && return 0

  seperator="$(pretty_print_seperator "$segment_color_bg" "$segment_direction")"
  segment="$(print_colors "$segment_color_fg" "$segment_color_bg")${segment_value}"
  prepare_color="$(print_fg_color "$segment_color_bg")"
  full_output="${seperator}${segment}${prepare_color}"
  uncolored=$(strip_escaped_colors "$full_output")
  printf '%s' "$full_output"
  return "${#uncolored}"
}


function pretty_print_seperator() {
  local to_color=$1
  local direction=$2

  case $direction in
    right)
      printf '%s' "$(print_bg_color "$to_color")${settings_segment_separator_right}"
    ;;
    left)
      printf '%s' "$(print_fg_color "$to_color")${settings_segment_separator_left}"
      ;;
  esac
}

function strip_escaped_colors() {
  sed -E 's/\\\[\\e\[[0123456789]([0123456789;])+m\\\]//g' <<< "$1"
}

export -f pretty_print_segment
export -f pretty_print_seperator
export -f strip_escaped_colors
export -f print_colors
export -f print_bg_color
export -f print_fg_color
export -f get_complement_rgb
