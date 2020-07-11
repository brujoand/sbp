#!/usr/bin/env bash

# TODO replace with call to configure::get feature file
# and check for peekaboo in the segment execution
execute::get_script() {
  local -n get_script_result=$1
  local feature_type=$2
  local feature_name=$3

  if [[ -f "${SBP_CONFIG}/peekaboo/${feature_name}" ]]; then
    return 0
  fi

  local feature_file
  configure::get_feature_file 'feature_file' "$feature_type" "$feature_name"
  get_script_result="$feature_file"
}

execute::execute_nohup_function() {
  (trap '' HUP INT
    "$@"
  ) </dev/null &>>"${SBP_CONFIG}/hook.log" &
}

execute::execute_prompt_hooks() {
  local hook_script
  for hook in "${SBP_HOOKS[@]}"; do
    execute::get_script 'hook_script' 'hook' "$hook"

    if [[ -f "$hook_script" ]]; then
        source "$hook_script"
        execute::execute_nohup_function "hooks::${hook}"
    fi
  done
}

execute::execute_prompt_segment() {
  local segment=$1
  local SEGMENT_POSITION=$2
  local SEGMENT_CACHE="${SBP_CACHE}/${segment}"

  local segment_script
  execute::get_script 'segment_script' 'segment' "$segment"

  if [[ -f "$segment_script" ]]; then
    source "$segment_script"

    local -n PRIMARY_COLOR="SEGMENTS_${segment^^}_COLOR_PRIMARY"
    local -n SECONDARY_COLOR="SEGMENTS_${segment^^}_COLOR_SECONDARY"

    local -n PRIMARY_COLOR_HIGHLIGHT="SEGMENTS_${segment^^}_COLOR_PRIMARY_HIGHLIGHT"
    local -n SECONDARY_COLOR_HIGHLIGHT="SEGMENTS_${segment^^}_COLOR_SECONDARY_HIGHLIGHT"

    local -n SPLITTER_COLOR="SEGMENTS_${segment^^}_COLOR_SPLITTER"

    local -n max_length_override="SEGMENTS_${segment^^}_MAX_LENGTH"
    if [[ -n "$max_length_override" ]]; then
      SEGMENTS_MAX_LENGTH="$max_length_override"
    fi

    "segments::${segment}"
  fi

}
