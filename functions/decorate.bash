#! /usr/bin/env bash

export colors_ids=( 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F )

get_complement_rgb() {
  input_colors=()
  output_colors=()

  if [[ -z "${1//[0123456789]}" ]]; then
    # This is not accurate
    printf '%s' "$(( 255 - $1 ))"
  else
    mapfile -t input_colors < <(tr ';' '\n' <<< "$1")
    for color_value in "${input_colors[@]}"; do
      output_colors+=("$(( 255 - color_value ))")
    done

    printf '%s;%s;%s' "${output_colors[0]}" "${output_colors[1]}" "${output_colors[2]}"
  fi
}

print_colors() { # prints ansi escape codes for fg and bg (optional)
  local -n return_value=$1
  local fg_code=$2
  local bg_code=$3
  local fg_color bg_color

  print_fg_color 'fg_color' "$fg_code"
  print_bg_color 'bg_color' "$bg_code"
  return_value="${fg_color}${bg_color}"
}

print_bg_color() {
  local -n return_value=$1
  local bg_code=$2
  local escaped=$3

  if [[ -z "$bg_code" ]]; then
    bg_escaped="\e[49m"
  elif [[ -z "${bg_code//[0123456789]}" ]]; then
    bg_escaped="\e[48;5;${bg_code}m"
  else
    bg_escaped="\e[48;2;${bg_code}m"
  fi

  if [[ -z "$escaped" ]]; then
    return_value="\[${bg_escaped}\]"
  else
    return_value="${bg_escaped}"
  fi
}

print_fg_color() {
  local -n return_value=$1
  local fg_code=$2
  local escaped=$3

  if [[ -z "$fg_code" ]]; then
    fg_escaped="\e[39m"
  elif [[ -z "${fg_code//[0123456789]}" ]]; then
    fg_escaped="\e[38;5;${fg_code}m"
  else
    fg_escaped="\e[38;2;${fg_code}m"
  fi

  if [[ -z "$escaped" ]]; then
    return_value="\[${fg_escaped}\]"
  else
    return_value="${fg_escaped}"
  fi
}
