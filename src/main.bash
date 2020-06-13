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

  tempdir=$_SBP_CACHE

  declare -a fillers
  declare -a newlines
  declare -a pids

  local segment_position='left'
  local last_newline=0

  for i in "${!SETTINGS_SEGMENTS[@]}"; do
    segment_name="${SETTINGS_SEGMENTS[i]}"

    case "$segment_name" in
      'newline')
        newlines+=("$i")
        segment_position='left'
        last_newline=$i
        pids[i]=0
        ;;
      'filler')
        fillers+=("$i")
        segment_position='right'
        pids[i]=0
        ;;
      *)
        execute::execute_prompt_segment "$segment_name" "$segment_position" "$(( i - last_newline ))" > "${tempdir}/${i}" & pids[i]=$!
        ;;
    esac
  done

  local total_empty_space="$COLUMNS"
  local pre_filler=
  local post_filler=

  for i in "${!pids[@]}"; do
    if [[ "${fillers[0]}" -eq "$i" ]]; then
      current_filler_position="$i"
      fillers=("${fillers[@]:1}")
    elif [[ ${newlines[0]} -eq "$i" ]]; then
      newlines=("${newlines[@]:1}")
      local filler
      if [[ -n "$current_filler_position" ]]; then
        print_themed_filler 'filler' "$total_empty_space"
        total_empty_space="$COLUMNS"
        pre_filler="${pre_filler}${filler}${post_filler}"
        unset current_filler_position post_filler
      fi

      pre_filler="${pre_filler}\n"
    else
      wait "${pids[i]}"
      mapfile -t segment_output < "${tempdir}/${i}"

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
  prompt="${pre_filler}${post_filler}"

  # Print the prompt and reset colors
  printf '%s' "$prompt"
}

main::main
