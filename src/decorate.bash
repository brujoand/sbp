#! /usr/bin/env bash

decorate::calculate_complementing_color() {
  local -n return_value=$1
  local source_color=$2
  input_colors=()
  output_colors=()

  if [[ -z "${source_color//[0123456789]}" ]]; then
    # This is not accurate
    return_value="$(( 255 - source_color ))"
  else
    mapfile -t input_colors < <(tr ';' '\n' <<< "$source_color")
    r_lum=$(( ${input_colors[0]} * 2126 ))
    g_lum=$(( ${input_colors[1]} * 7152 ))
    b_lum=$(( ${input_colors[2]} * 722 ))

    lum=$(( r_lum + g_lum + b_lum ))
    if [[ "$lum" -gt 1400000 ]]; then
      return_value='0;0;0'
    else
      return_value='255;255;255'
    fi

  fi
}

decorate::print_colors() {
  local -n return_value=$1
  local fg_code=$2
  local bg_code=$3
  local fg_color bg_color

  decorate::print_fg_color 'fg_color' "$fg_code"
  decorate::print_bg_color 'bg_color' "$bg_code"
  return_value="${fg_color}${bg_color}"
}

decorate::print_bg_color() {
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

decorate::print_fg_color() {
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
