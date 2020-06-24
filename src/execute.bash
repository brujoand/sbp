#!/usr/bin/env bash

execute::get_script() {
  local -n return_value=$1
  local type=$2
  local feature=$3

  if [[ -f "${SBP_CONFIG}/peekaboo/${segment_name}" ]]; then
    return 0
  fi

  local local_script="${SBP_CONFIG}/${type}s/${feature}.bash"
  local global_script="${SBP_PATH}/src/${type}s/${feature}.bash"

  if [[ -f "$local_script" ]]; then
    return_value="$local_script"
  elif [[ -f "$global_script" ]]; then
    return_value="$global_script"
  else
    debug::log_error "Could not find $local_script"
    debug::log_error "Could not find $global_script"
    debug::log_error "Make sure it exists"
  fi
}

execute::execute_nohup_function() {
  (trap '' HUP INT
    "$@"
  ) </dev/null &>>"${SBP_CONFIG}/hook.log" &
}

execute::execute_prompt_hooks() {
  local hook_script
  for hook in "${SETTINGS_HOOKS[@]}"; do
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
  local SEGMENT_LINE_POSITION=$3
  local SEGMENT_CACHE="${SBP_CACHE}/${segment}"

  local segment_script
  execute::get_script 'segment_script' 'segment' "$segment"

  if [[ -f "$segment_script" ]]; then
    source "$segment_script"

    local primary_color_var="SEGMENTS_${segment^^}_COLOR_PRIMARY"
    local secondary_color_var="SEGMENTS_${segment^^}_COLOR_SECONDARY"

    local primary_color_highlight_var="${primary_color_var}_HIGHLIGHT"
    local secondary_color_highlight_var="${secondary_color_var}_HIGHLIGHT"

    PRIMARY_COLOR="${!primary_color_var}"
    SECONDARY_COLOR="${!secondary_color_var}"

    PRIMARY_COLOR_HIGHLIGHT="${!primary_color_highlight_var}"
    SECONDARY_COLOR_HIGHLIGHT="${!secondary_color_highlight_var}"

    local splitter_color_var="SEGMENTS_${segment}_SPLITTER_COLOR"
    SPLITTER_COLOR="${!splitter_color_var}"

    "segments::${segment}"
  fi

}
