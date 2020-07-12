#! /usr/bin/env bash

# shellcheck source=src/debug.bash
source "${SBP_PATH}/src/debug.bash"
# shellcheck source=src/decorate.bash
source "${SBP_PATH}/src/decorate.bash"
# shellcheck source=src/execute.bash
source "${SBP_PATH}/src/execute.bash"
# shellcheck source=src/configure.bash
source "${SBP_PATH}/src/configure.bash"

configure::load_config

readonly COMMAND_EXIT_CODE=$1
readonly COMMAND_DURATION=$2

main::main() {
  execute::execute_prompt_hooks

  # Execute the segments
  segment_groups=('left' 'right' 'line_two')

  declare -a pids_left
  declare -a pids_right
  declare -a pids_line_two

  left_segment_count=${#SBP_SEGMENTS_LEFT[@]}
  right_segment_count=${#SBP_SEGMENTS_RIGHT[@]}
  total_segment_count=$(( left_segment_count + right_segment_count ))
  SEGMENTS_MAX_LENGTH=$(( COLUMNS / total_segment_count ))

  for group in "${segment_groups[@]}"; do
    # Bash doesn't support array -> array, so we use pointers instead :(
    local -n segment_list="SBP_SEGMENTS_${group^^}"
    local -n pids="pids_${group}"

    for i in "${!segment_list[@]}"; do
      local segment_name="${segment_list[$i]}"
      execute::execute_prompt_segment "$segment_name" "$group" > "${SBP_TMP}/${group}.${i}" & pids["$i"]=$!
    done
  done

  declare -A segments_output
  declare -A segments_length

  # Collect the segments
  for group in "${segment_groups[@]}"; do
    # Bash doesn't support array -> array, so we use pointers instead :(
    local -n pids="pids_${group}"

    for i in "${!pids[@]}"; do
      pid=${pids[$i]}
      wait "$pid"
      mapfile -t segment_data < "${SBP_TMP}/${group}.${i}"

      segment_size=${segment_data[0]}
      segment_value=${segment_data[1]}
      if [[ -n "$segment_value" ]]; then
        segments_length["$group"]=$(( ${segments_length["$group"]} + segment_size ))
        segments_output["$group"]="${segments_output["$group"]}${segment_value}"
      fi
    done
  done

  local prompt_gap_size=$(( COLUMNS - segments_length['left'] - segments_length['right'] ))
  print_themed_prompt "${segments_output['left']}" "${segments_output['right']}" "${segments_output[line_two]}" "$prompt_gap_size"
}

main::main
