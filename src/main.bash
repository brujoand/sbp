#! /usr/bin/env bash

# shellcheck source=src/debug.bash
source "${SBP_PATH}/src/debug.bash"
# shellcheck source=src/decorate.bash
source "${SBP_PATH}/src/decorate.bash"
# shellcheck source=src/configure.bash
source "${SBP_PATH}/src/configure.bash"
# shellcheck source=src/execute.bash
source "${SBP_PATH}/src/execute.bash"

configure::load_config

COMMAND_EXIT_CODE=$1
COMMAND_DURATION=$2

main::main() {
  execute::execute_prompt_hooks

  declare -a pids

  local segment_position='left'
  local start_of_current_line=0


  if [[ -n "${SBP_SEGMENTS_RIGHT}" ]]; then
    SBP_SEGMENTS=('newline' "${SBP_SEGMENTS_LEFT[@]}" 'filler' "${SBP_SEGMENTS_RIGHT[@]}" 'newline' "${SBP_SEGMENTS_LINE_TWO[@]}")
  else
    SBP_SEGMENTS=('newline' "${SBP_SEGMENTS_LEFT[@]}")
  fi

  # Trigger all segments
  # Mark all special cases and generate all other
  # segments
  for i in "${!SBP_SEGMENTS[@]}"; do
    local segment_name="${SBP_SEGMENTS[$i]}"

    case "$segment_name" in
      'newline')
        segment_position='left'
        start_of_current_line=$(( i + 1 ))
        pids[i]="$segment_name"
        ;;
      'filler')
        segment_position='right'
        pids[i]="$segment_name"
        ;;
      *)
        execute::execute_prompt_segment "$segment_name" "$segment_position" "$(( i - start_of_current_line ))" > "${SBP_TMP}/${i}" & pids[i]=$!
        ;;
    esac
  done

  local total_empty_space="$COLUMNS"
  local pre_filler=
  local post_filler=

  # Gather up all the generated segments
  # by their pid
  # and generate the special cases
  for i in "${!pids[@]}"; do
    local current_pid="${pids[$i]}"
    if [[ "$current_pid" == 'filler' ]]; then
      current_filler_position="$i"
    elif [[ "$current_pid" == 'newline' ]]; then
      if [[ -n "$current_filler_position" ]]; then
        local filler
        print_themed_filler 'filler' "$total_empty_space"
        pre_filler="${pre_filler}${filler}${post_filler}"
        unset current_filler_position post_filler
      fi
      total_empty_space="$COLUMNS"

      pre_filler="${pre_filler}\n"
    else
      wait "${pids[i]}"
      mapfile -t segment_output < "${SBP_TMP}/${i}"

      segment=${segment_output[1]}
      segment_length=${segment_output[0]}
      # Make fillers and newlines part of the theme?
      empty_space=$(( total_empty_space - segment_length ))

      if [[ "$empty_space" -gt 0 ]]; then
        if [[ -n "$current_filler_position" ]]; then
          post_filler="${post_filler}${segment}"
        else
          pre_filler="${pre_filler}${segment}"
        fi
        total_empty_space="$empty_space"
      fi
    fi
  done

  local color_reset
  decorate::print_colors 'color_reset'

  printf '%s%s%s' "$pre_filler" "$post_filler" "$color_reset"

}

main::main
