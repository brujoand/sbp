# shellcheck source=helpers/formatting.bash
source "${sbp_path}/helpers/formatting.bash"
# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

function calculate_padding() {
  local string=$1
  local width=$2
  uncolored=$(strip_escaped_colors "${string}")
  echo $(( width - ${#uncolored}))
}

function execute_segment_script() {
  local segment=$1
  local exit_code=$2
  local time_start=$3
  local segment_direction=$4
  local segment_script="${sbp_path}/segments/${segment}.bash"

  if [[ -x "$segment_script" ]]; then
    "$segment_script" "$exit_code" "$time_start" "$segment_direction"
  else
    >&2 echo "Could not execute $segment_script"
    >&2 echo "Make sure it exists, and is executable"
  fi
}

function generate_prompt() {
  load_config
  local columns=$1
  local command_exit_code=$2
  local command_time=$3

  # Execute hooks
  for hook in "${settings_hooks[@]}"; do
    local hook_script="${sbp_path}/hooks/${hook}.bash"
    if [[ -x "$hook_script" ]]; then
      "$hook_script" "$command_exit_code" "$command_time"
    else
      >&2 echo "Could not execute $hook_script"
      >&2 echo "Make sure it exists, and is executable"
    fi
  done

  local prompt_left="\n"
  local prompt_filler
  local prompt_right
  local prompt_line_two=
  local prompt_left_end=$(( ${#settings_segments_left[@]} - 1 ))
  local prompt_right_end=$(( ${#settings_segments_right[@]} + prompt_left_end ))
  local prompt_segments=(${settings_segments_left[@]} ${settings_segments_right[@]} ${settings_segment_line_two[@]})

  local seperator_direction=''

  # Concurrent evaluation of promt segments
  tempdir=$(mktemp -d) && trap 'rm -rf "$tempdir"' EXIT;
  for i in "${!prompt_segments[@]}"; do
    execute_segment_script "${prompt_segments[i]}" "$command_exit_code" "$command_time" "$seperator_direction" > "$tempdir/$i" & pids[i]=$!
    if [[ "$i" -lt "$prompt_left_end" ]]; then
      seperator_direction='right'
    elif [[ "$i" -eq "$prompt_left_end" ]]; then
      seperator_direction='left'
    elif [[ "$i" -eq "$prompt_right_end" ]]; then
      seperator_direction=''
    fi
  done
  for i in "${!pids[@]}"; do
    wait "${pids[i]}" && prompt_segments[i]=$(<"$tempdir/$i");
  done

  # Format the segments
  for i in "${!prompt_segments[@]}"; do
    local seperator=
    local segment="${prompt_segments["$i"]}"

    if [[ "$i" -lt "$prompt_left_end" ]]; then
      prompt_left="${prompt_left}${segment}"
    elif [[ "$i" -eq "$prompt_left_end" ]]; then
      prompt_filler="$segment"
    elif [[ "$i" -lt "$prompt_right_end" ]]; then
      prompt_right="${prompt_right}${segment}"
    elif [[ "$i" -eq "$prompt_right_end" ]]; then
      prompt_right="${prompt_right}${segment}$(reset_colors)\n"
    else
      prompt_line_two="${prompt_line_two}${segment}"
    fi
  done

  # Generate the filler segment
  local prompt_line_one
  ## TODO Call the filler segment here instead
  prompt_line_one="${prompt_left}${filler}${prompt_right}"
  prompt_uncolored=$(calculate_padding "${prompt_line_one}" "$columns")
  padding=$(printf "%*s" "$prompt_uncolored")
  prompt_filler=$(sed "s/_filler_/ ${padding}  /" <<< "$prompt_filler")

  # Print the prompt and reset colors
  printf '%s' "${prompt_left}${prompt_filler}${prompt_right}${prompt_line_two}$(reset_colors)"
}

generate_prompt "$@"
