#! /usr/bin/env bash

function print_colorized() { # prints ansi escape codes for fg and bg (optional)
  local fg_code=$1
  local bg_code=$2

  if [[ "$bg_code" == -1 ]]; then
    bg_escaped="\[\e[49m\]"
  else
    bg_escaped="\[\e[48;2;${bg_code}m\]"
  fi

  if [[ "$fg_code" == -1 ]]; then
    fg_escaped="\[\e[39m\]"
  else
    fg_escaped="\[\e[38;2;${fg_code}m\]"
  fi

  printf '%s' "${fg_escaped}${bg_escaped}"
}

function get_complement_rgb() {
  input_colors=()
  output_colors=()
  mapfile -t input_colors < <(tr ';' '\n' <<< "$1")
  for color_value in "${input_colors[@]}"; do
    output_colors+=("$(( 255 - color_value ))")
  done

  printf '%s;%s;%s' "${output_colors[0]}" "${output_colors[1]}" "${output_colors[2]}"
}

function print_bg_color() {
  local bg_code=$1
  if [[ "$bg_code" == -1 ]]; then
    bg_escaped="\[\e[49m\]"
  else
    bg_escaped="\[\e[48;2;${bg_code}m\]"
  fi

  printf '%s' "${bg_escaped}"
}

function print_fg_color() {
  local fg_code=$1
  if [[ "$fg_code" == -1 ]]; then
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
  sed -E 's/\\\[\\e\[([38\|48]+;2;)?[0-9]+(;[0-9]+;[0-9]+)?m\\\]//g' <<< "$1"

}

export -f pretty_print_segment
export -f pretty_print_seperator
export -f print_colorized
export -f print_bg_color
export -f print_fg_color
export -f get_complement_rgb

