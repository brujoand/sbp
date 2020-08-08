#! /usr/bin/env bash

decorate::calculate_complementing_color() {
  local -n calculate_complementing_color_result=$1
  local source_color=$2
  input_colors=()

  if [[ -z "${source_color//[0123456789]}" ]]; then
    # This is not accurate
    calculate_complementing_color_result="$(( 255 - source_color ))"
  else
    mapfile -t input_colors < <(tr ';' '\n' <<< "$source_color")
    local red=${input_colors[0]}
    local green=${input_colors[1]}
    local blue=${input_colors[2]}

    red=$(( red * 2126 ))
    green=$(( green * 7152 ))
    blue=$(( blue * 722 ))

    lum=$(( red + green + blue ))
    if [[ "$lum" -gt 1400000 ]]; then
      calculate_complementing_color_result='0;0;0'
    else
      calculate_complementing_color_result='255;255;255'
    fi
  fi
}

decorate::print_colors() {
  local -n print_colors_result=$1
  local fg_code=$2
  local bg_code=$3
  local escaped=${4}
  local fg_color bg_color

  decorate::print_fg_color 'fg_color' "$fg_code"
  decorate::print_bg_color 'bg_color' "$bg_code"
  print_colors_result="${fg_color}${bg_color}"
}

decorate::print_bg_color() {
  local -n print_bg_color_result=$1
  local bg_code=$2
  local escaped=${3:-'true'}

  decorate::format_color 'print_bg_color_result' 48 "$bg_code" "$escaped"
}

decorate::print_fg_color() {
  local -n print_fg_color_result=$1
  local fg_code=$2
  local escaped=${3:-'true'}

  decorate::format_color 'print_fg_color_result' 38 "$fg_code" "$escaped"
}

decorate::format_color() {
  local -n format_color_result=$1
  local color_code=$2
  local color_value=$3
  local escaped=$4
  local color_reset_code=$(( color_code + 1 ))

  if [[ -z "$color_value" ]]; then
    format_color_result="\e[${color_reset_code}m"
  elif [[ -z "${color_value//[0123456789]}" ]]; then
    format_color_result="\e[${color_code};5;${color_value}m"
  else
    format_color_result="\e[${color_code};2;${color_value}m"
  fi

  if [[ "$escaped" == 'true' ]]; then
    format_color_result="\[${format_color_result}\]"
  fi
}
