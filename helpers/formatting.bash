#! /usr/bin/env bash

export colors_ids=( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 )

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
  local fg_code=$1
  local bg_code=$2

  printf '%s%s' "$(print_fg_color "$fg_code")" "$(print_bg_color "$bg_code")"
}

print_bg_color() {
  local bg_code=$1
  local escaped=$2

  if [[ "$settings_segment_enable_bg_color" -eq 0 ]]; then
    return 0
  fi

  if [[ -z "$bg_code" ]]; then
    bg_escaped="\e[49m"
  elif [[ -z "${bg_code//[0123456789]}" ]]; then
    bg_escaped="\e[48;5;${bg_code}m"
  else
    bg_escaped="\e[48;2;${bg_code}m"
  fi

  if [[ -z "$escaped" ]]; then
    printf '\[%s\]' "${bg_escaped}"
  else
    printf '%s' "${bg_escaped}"
  fi
}

print_fg_color() {
  local fg_code=$1
  local escaped=$2

  if [[ -z "$fg_code" ]]; then
    fg_escaped="\e[39m"
  elif [[ -z "${fg_code//[0123456789]}" ]]; then
    fg_escaped="\e[38;5;${fg_code}m"
  else
    fg_escaped="\e[38;2;${fg_code}m"
  fi

  if [[ -z "$escaped" ]]; then
    printf '\[%s\]' "${fg_escaped}"
  else
    printf '%s' "${fg_escaped}"
  fi
}

pretty_print_segment() {
  local segment_color_bg="$1"
  local segment_color_fg="$2"
  local segment_value="$3"
  local segment_direction="$4"

  [[ -z "$segment_value" ]] && return 0

  if [[ "$settings_segment_enable_bg_color" -eq 0 ]]; then
    segment_color_fg="$segment_color_bg"
    segment_color_bg=""
    color="$(print_fg_color "$segment_color_fg")"

    if [[ -z "${segment_value// /}" || -z "$segment_direction" ]]; then
      full_output="${color}${segment_value}"
    else
      full_output="${color}${settings_segment_separator_right}${segment_value}${settings_segment_separator_left}"
    fi
  else
    prepare_color="$(print_fg_color "$segment_color_bg")"
    seperator="$(pretty_print_seperator "$segment_color_bg" "$segment_direction")"
    segment="$(print_colors "$segment_color_fg" "$segment_color_bg")${segment_value}"
    full_output="${seperator}${segment}${prepare_color}"
  fi

  uncolored=$(strip_escaped_colors "$full_output")
  printf '%s' "$full_output"
  return "${#uncolored}"
}


pretty_print_seperator() {
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

strip_escaped_colors() {
  sed -E 's/\\\[\\e\[[0123456789]([0123456789;])+m\\\]//g' <<< "$1"
}

export -f pretty_print_segment
export -f pretty_print_seperator
export -f strip_escaped_colors
export -f print_colors
export -f print_bg_color
export -f print_fg_color
export -f get_complement_rgb
