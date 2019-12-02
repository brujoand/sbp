#! /usr/bin/env bash

# shellcheck source=helpers/formatting.bash
source "${sbp_path}/helpers/formatting.bash"
# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

columns=$1
command_exit_code=$2
command_time=$3

function calculate_padding() {
  local string=$1
  local width=$2
  uncolored=$(strip_escaped_colors "${string}")
  echo $(( width - ${#uncolored} + 1 ))
}

function execute_segment_script() {
  local segment=$1
  local segment_direction=$2
  local segment_max_length=$3
  local segment_script="${sbp_path}/segments/${segment}.bash"

  if [[ -x "$segment_script" ]]; then
    bash "$segment_script" "$command_exit_code" "$command_time" "$segment_direction" "$segment_max_length"
  else
    >&2 echo "Could not execute $segment_script"
    >&2 echo "Make sure it exists, and is executable"
  fi
}

function execute_prompt_hooks() {
  for hook in "${settings_hooks[@]}"; do
    local hook_script="${sbp_path}/hooks/${hook}.bash"
    if [[ -x "$hook_script" ]]; then
      (nohup bash "$hook_script" "$command_exit_code" "$command_time" &>/dev/null &)
    else
      >&2 echo "Could not execute $hook_script"
      >&2 echo "Make sure it exists, and is executable"
    fi
  done
}

function generate_prompt() {
  load_config

  execute_prompt_hooks

  local prompt_left="\n"
  local prompt_filler prompt_right prompt_line_two seperator_direction
  local prompt_left_end=$(( ${#settings_segments_left[@]} - 1 ))
  local prompt_right_end=$(( ${#settings_segments_right[@]} + prompt_left_end ))
  local prompt_segments=(${settings_segments_left[@]} ${settings_segments_right[@]} ${settings_segment_line_two[@]})
  local number_of_top_segments=$(( ${#settings_segments_left[@]} + ${#settings_segments_right[@]} - 1))
  local segment_max_length=$(( columns / number_of_top_segments ))

  declare -A pid_left
  declare -A pid_right
  declare -A pid_two

  # Concurrent evaluation of promt segments
  tempdir=$(mktemp -d) && trap 'rm -rf "$tempdir"' EXIT;
  for i in "${!prompt_segments[@]}"; do

    if [[ "$i" -eq 0 ]]; then
      seperator_direction=''
      pid_left["$i"]="$i"
    elif [[ "$i" -le "$prompt_left_end" ]]; then
      seperator_direction='right'
      pid_left["$i"]="$i"
    elif [[ "$i" -le "$prompt_right_end" ]]; then
      seperator_direction='left'
      pid_right["$i"]="$i"
    elif [[ "$i" -gt "$prompt_right_end" && -z "$pid_two" ]]; then
      seperator_direction=''
      pid_two["$i"]="$i"
    else
      seperator_direction='right'
      pid_two["$i"]="$i"
    fi

    execute_segment_script "${prompt_segments[i]}" "$seperator_direction" "$segment_max_length" > "$tempdir/$i" & pids[i]=$!

  done

  for i in "${!pids[@]}"; do
    wait "${pids[i]}"
    segment=$(<"$tempdir/$i");
    if [[ -n "${pid_left["$i"]}"  ]]; then
      prompt_left="${prompt_left}${segment}"
    elif [[ -n "${pid_right["$i"]}" ]]; then
      prompt_right="${prompt_right}${segment}"
    elif [[ -n "${pid_two["$i"]}" ]]; then
      prompt_line_two="${prompt_line_two}${segment}"
    fi
  done

  # Generate the filler segment
  prompt_uncolored=$(calculate_padding "${prompt_left}${prompt_right}" "$columns")
  padding=$(printf "%*s" "$prompt_uncolored")
  prompt_filler="$(pretty_print_segment -1 -1 "$padding" "right")"
  if [[ -n "$prompt_line_two" ]]; then
    line_two_filler="$(pretty_print_segment -1 -1 " " "right")"
    prompt_line_two="${prompt_line_two}${line_two_filler}"
  fi

  # Print the prompt and reset colors
  printf '%s' "${prompt_left}${prompt_filler}${prompt_right}${color_reset}\n${prompt_line_two}${color_reset}"
}

generate_prompt
