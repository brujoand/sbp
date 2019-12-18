#! /usr/bin/env bash

# shellcheck source=helpers/formatting.bash
source "${sbp_path}/helpers/formatting.bash"
# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

load_config

color_reset='\[\e[00m\]'

execute_segment_script() {
  local segment=$1
  local segment_direction=$2
  local segment_max_length=$3
  local local_segment_script="${local_segments_folder}/${segment}.bash"
  local global_segment_script="${global_segments_folder}/${segment}.bash"

  if [[ -f "${config_folder}/peekaboo/${segment_name}" ]]; then
    return 0
  fi

  if [[ -x "$local_segment_script" ]]; then
    bash "$local_segment_script" "$command_exit_code" "$command_time" "$segment_direction" "$segment_max_length"
  elif [[ -x "$global_segment_script" ]]; then
    bash "$global_segment_script" "$command_exit_code" "$command_time" "$segment_direction" "$segment_max_length"
  else
    log_error "Could not execute $local_segment_script"
    log_error "Could not execute $global_segment_script"
    log_error "Make sure it exists, and is executable"
  fi
}

execute_prompt_hooks() {

  for hook in "${settings_hooks[@]}"; do
    local local_hook_script="${local_hooks_folder}/${hook}.bash"
    local global_hook_script="${global_hooks_folder}/${hook}.bash"

    if [[ -f "${config_folder}/peekaboo/${hook}" ]]; then
      return 0
    fi

    if [[ -x "$local_hook_script" ]]; then
      (nohup bash "$local_hook_script" "$command_exit_code" "$command_time" &>/dev/null &)
    elif [[ -x "$global_hook_script" ]]; then
      (nohup bash "$global_hook_script" "$command_exit_code" "$command_time" &>/dev/null &)
    else
      log_error "Could not execute ${local_hook_script}"
      log_error "Could not execute ${global_hook_script}"
      log_error "Make sure it exists, and is executable"
    fi
  done
}

generate_prompt() {
  columns=$1
  command_exit_code=$2
  command_time=$3

  execute_prompt_hooks

  local prompt_left="\n"
  local prompt_filler prompt_right prompt_ready seperator_direction
  local prompt_left_end=$(( ${#settings_segments_left[@]} - 1 ))
  local prompt_right_end=$(( ${#settings_segments_right[@]} + prompt_left_end ))
  local prompt_segments=("${settings_segments_left[@]}" "${settings_segments_right[@]}" 'prompt_ready')
  local number_of_top_segments=$(( ${#settings_segments_left[@]} + ${#settings_segments_right[@]} - 1))
  local segment_max_length=$(( columns / number_of_top_segments ))

  declare -A pid_left
  declare -A pid_right
  declare -A pid_two

  # Concurrent evaluation of promt segments
  tempdir=$(mktemp -d) && trap 'rm -rf "$tempdir"' EXIT;
  for i in "${!prompt_segments[@]}"; do
    segment_name="${prompt_segments[i]}"
    [[ -z "$segment_name" ]] && continue
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
    fi

    execute_segment_script "$segment_name" "$seperator_direction" "$segment_max_length" > "$tempdir/$i" & pids[i]=$!

  done

  total_empty_space="$columns"

  if [[ -n "${settings_prompt_prefix_upper}" ]]; then
    total_empty_space=$(( total_empty_space - ${#settings_prompt_prefix_upper} - 1 ))
    prefix_color="$(print_fg_color "$settings_prompt_ready_color_primary")"
    prompt_left="${prompt_left} ${prefix_color}${settings_prompt_prefix_upper}"
  fi

  for i in "${!pids[@]}"; do
    wait "${pids[i]}"
    segment_length=$?
    segment=$(<"$tempdir/$i");
    empty_space=$(( total_empty_space - segment_length ))
    if [[ -n "${pid_left["$i"]}"  && "$empty_space" -gt 0 ]]; then
      prompt_left="${prompt_left}${segment}"
      total_empty_space="$empty_space"
    elif [[ -n "${pid_right["$i"]}" && "$empty_space" -gt 0  ]]; then
      prompt_right="${prompt_right}${segment}"
      total_empty_space="$empty_space"
    elif [[ -n "${pid_two["$i"]}" ]]; then
      prompt_ready="${segment}"
    fi
  done

  # Generate the filler segment
  if [[ -n "$prompt_right" ]]; then
    prompt_uncolored="$(( total_empty_space - 1 ))" # Account for the filler seperator
  else
    prompt_uncolored=1
  fi
  padding=$(printf "%*s" "$prompt_uncolored")
  prompt_filler="$(pretty_print_segment "" "" "$padding" "right")"


  if [[ "${settings_prompt_ready_newline}" -eq 1 ]]; then
    prompt_ready="\n${prompt_ready}"
  fi

  # Print the prompt and reset colors
  printf '%s' "${prompt_left}${prompt_filler}${prompt_right}${color_reset}${prompt_ready}${color_reset}"
}

generate_prompt "$@"
