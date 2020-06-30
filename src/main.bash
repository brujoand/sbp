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

COMMAND_EXIT_CODE=$1
COMMAND_DURATION=$2

main::main() {
  execute::execute_prompt_hooks

  # Execute the segments
  declare -A left_pids
  declare -A right_pids
  declare -A line_two_pids
  segment_groups=('left' 'right' 'line_two')

  for group in "${segment_groups[@]}"; do
    local -n segment_list="SBP_SEGMENTS_${group^^}"
    local -n pid_list="${group}_pids"
    if [[ "$group" == 'right' ]]; then
      segment_position='right'
    else
      segment_position='left'
    fi
    for i in "${!segment_list[@]}"; do
      local segment_name="${segment_list[$i]}"
      execute::execute_prompt_segment "$segment_name" "$segment_position" > "${SBP_TMP}/${segment_name}" & pid_list["$segment_name"]=$!
    done
  done


  # Collect the segments
  local left_size=0
  local left_segments

  local right_size=0
  local right_segments

  local line_two_size=0
  local line_two_segments

  for group in "${segment_groups[@]}"; do
    local -n segment_list="SBP_SEGMENTS_${group^^}"
    local -n pid_list="${group}_pids"
    local -n segments_size="${group}_size"
    local -n segments_output="${group}_segments"

    for segment_name in "${segment_list[@]}"; do
      local current_pid="${pid_list[$segment_name]}"
        wait "$current_pid"
        mapfile -t segment_data < "${SBP_TMP}/${segment_name}"

        segment_size=${segment_data[0]}
        segment_output=${segment_data[1]}
        if [[ -n "$segment_output" ]]; then
          segments_size=$(( segments_size + segment_size ))
          segments_output="${segments_output}${segment_output}"
        fi
    done
  done

  local prompt_gap_size=$(( COLUMNS - (left_size + right_size) ))
  print_themed_prompt "$left_segments" "$right_segments" "$line_two_segments" "$prompt_gap_size"
}

main::main
