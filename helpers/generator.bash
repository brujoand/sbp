#! /usr/bin/env bash

# shellcheck source=helpers/formatting.bash
source "${sbp_path}/helpers/formatting.bash"
# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

load_config

color_reset='\[\e[00m\]'

function generate_extra_options() {
  if [[ "$settings_prompt_ready_vi_mode" -eq 1 ]]; then
    local cache_file="${cache_folder}/extra_options.bash"
    local insert_color="$settings_prompt_ready_vi_insert_color"
    local command_color="$settings_prompt_ready_vi_command_color"
    cat << EOF > "$cache_file"
bind 'set show-mode-in-prompt on'
bind "set vi-cmd-mode-string \1\x1b[38;2;${command_color}m\e[49m\2 ${settings_prompt_ready_icon} \1\e[0m\2"
bind "set vi-ins-mode-string \1\x1b[38;2;${insert_color}m\e[49m\2 ${settings_prompt_ready_icon} \1\e[0m\2"
EOF
    echo "$cache_file"
  else
    return 1
  fi

}

function list_segments() {
  local active_segments=( ${settings_segments_left[@]} ${settings_segments_right[@]} ${settings_segment_line_two[@]} )

  for segment in "$sbp_path"/segments/*.bash; do
    local status='disabled'
    local segment_name="${segment##*/}"
    if printf '%s.bash\n' "${active_segments[@]}" | grep -qo "${segment_name}"; then
      status='enabled'
    fi

    _sbp_timer_start
    (bash "$segment" 0 0 left 0 &>/dev/null)
    duration=$(_sbp_timer_tick 2>&1 | tr -d ':')

    echo "${segment_name}: ${status}" "$duration"
  done | column -t -c " "
}

function list_hooks() {
  for hook in "$sbp_path"/hooks/*.bash; do
    script="${hook##*/}"
    status='disabled'
    if printf '%s.bash\n' "${settings_hooks[@]}" | grep -qo "${script}"; then
      status='enabled'
    fi
    echo "${script/.bash/}: ${status}" | column -t
  done
}

function list_colors() {
  source "${sbp_path}/helpers/formatting.bash"
  colors=( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 )
  for n in "${colors[@]}"; do
    color="color${n}"
    text_color=$(get_complement_rgb "${!color}")
    printf '\x1b[48;2;%sm \x1b[38;2;%sm %s \x1b[0m ' "${!color}" "$text_color" "$n"
  done
  printf '\n'

}

function list_themes() {
  source "${sbp_path}/helpers/formatting.bash"
  for theme in "$sbp_path"/themes/*.bash; do
    source "$theme"
    printf '\n%s \n' "${theme##*/}"
    colors=( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 )
    for n in "${colors[@]}"; do
      color="color${n}"
      text_color=$(get_complement_rgb "${!color}")
      printf '\x1b[48;2;%sm \x1b[38;2;%sm %s \x1b[0m ' "${!color}" "$text_color" "$n"
    done
    printf '\n'
  done
}


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
  columns=$1
  command_exit_code=$2
  command_time=$3

  execute_prompt_hooks

  local prompt_left="\n"
  local prompt_filler prompt_right prompt_line_two seperator_direction
  local prompt_left_end=$(( ${#settings_segments_left[@]} - 1 ))
  local prompt_right_end=$(( ${#settings_segments_right[@]} + prompt_left_end ))
  local prompt_segments=(${settings_segments_left[@]} ${settings_segments_right[@]} 'prompt_ready')
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
    fi

    execute_segment_script "${prompt_segments[i]}" "$seperator_direction" "$segment_max_length" > "$tempdir/$i" & pids[i]=$!

  done

  total_empty_space="$columns"

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
      prompt_line_two="${segment}"
    fi
  done

  # Generate the filler segment
  prompt_uncolored="$(( total_empty_space - 1 ))" # Account for the filler seperator
  padding=$(printf "%*s" "$prompt_uncolored")
  prompt_filler="$(pretty_print_segment "" "" "$padding" "right")"

  # Print the prompt and reset colors
  printf '%s' "${prompt_left}${prompt_filler}${prompt_right}${color_reset}\n${prompt_line_two}${color_reset}"
}

"$@"
