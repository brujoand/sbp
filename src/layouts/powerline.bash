SEPERATOR_LEFT=${LAYOUTS_POWERLINE_SEPARATOR_LEFT:-''}
SEPERATOR_RIGHT=${LAYOUTS_POWERLINE_SEPARATOR_RIGHT:-''}
SPLITTER_LEFT=${LAYOUTS_POWERLINE_SPLITTER_LEFT:-''}
SPLITTER_RIGHT=${LAYOUTS_POWERLINE_SPLITTER_RIGHT:-''}
SEGMENTS_PROMPT_READY_ICON=${LAYOUTS_POWERLINE_PROMPT_READY_ICON:-'➜'}
SEGMENTS_GIT_ICON=${LAYOUTS_POWERLINE_GIT_ICON:-''}
SEGMENTS_GIT_INCOMING_ICON=${LAYOUTS_POWERLINE_GIT_INCOMING_ICON:-'↓'}
SEGMENTS_GIT_OUTGOING_ICON=${LAYOUTS_POWERLINE_GIT_OUTGOING_ICON:-'↑'}

print_themed_command_mode() {
  local command_color
  decorate::print_fg_color 'command_color' "$SETTINGS_PROMPT_READY_VI_COMMAND_COLOR" false
  echo "\1\e[0m\2\1${command_color}\2 ${PROMPT_READY_ICON} \1\e[0m\2"
}

print_themed_insert_mode() {
  local insert_color
  decorate::print_fg_color 'insert_color' "$SETTINGS_PROMPT_READY_VI_INSERT_COLOR" false
  echo "\1\e[0m\2\1${insert_color}\2 ${PROMPT_READY_ICON} \1\e[0m\2"
}


print_themed_filler() {
  local -n return_value=$1
  local seperator_size=${#SEPERATOR_LEFT}
  # Account for seperator and padding
  local filler_size=$(( $2 - seperator_size - 2 ))
  padding=$(printf '%*s' "$filler_size")
  SEGMENT_POSITION='left'
  SEGMENT_LINE_POSITION=2
  prompt_filler_output="$(print_themed_segment 'normal' "$padding")"
  mapfile -t segment_output <<< "$prompt_filler_output"

  return_value=${segment_output[1]}
}

print_themed_segment() {
  local segment_type=$1
  shift
  local segment_parts=("${@}")
  local segment_length=0
  local part_length=0
  local themed_segment
  local seperator_themed
  local part_splitter

  if [[ "$segment_type" == 'prompt_ready' && "$SEGMENTS_PROMPT_READY_VI_MODE" -eq 1 ]]; then
    return 0
  fi

  if [[ "$segment_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
    SECONDARY_COLOR="$SECONDARY_COLOR_HIGHLIGHT"
  fi

  if [[ "$SEGMENT_POSITION" == 'left' ]]; then
    part_splitter="$SPLITTER_LEFT"
    seperator="$SEPERATOR_LEFT"
    local seperator_color
    decorate::print_bg_color 'seperator_color' "$PRIMARY_COLOR"
    seperator_themed="${seperator_color}${seperator}"
  elif [[ "$SEGMENT_POSITION" == 'right' ]]; then
    part_splitter="$SPLITTER_RIGHT"
    seperator="$SEPERATOR_RIGHT"
    local seperator_color
    decorate::print_fg_color 'seperator_color' "$PRIMARY_COLOR"
    seperator_themed="${seperator_color}${seperator}"
  fi

  local segment_colors
  decorate::print_colors 'segment_colors' "$SECONDARY_COLOR" "$PRIMARY_COLOR"

  if [[ -n "${part_splitter/ /}" ]]; then
    part_splitter=" ${part_splitter} "
  else
    part_splitter=' '
  fi
  local part_splitter_length="${#part_splitter}"

  if [[ "$SEGMENT_LINE_POSITION" -gt 0 ]]; then
    segment_length="${#seperator}"
    themed_segment="$seperator_themed"
  fi

  themed_segment="${themed_segment}${segment_colors}"

  if [[ "${#segment_parts[@]}" -gt 1 ]]; then
    local splitter_color_on
    decorate::print_fg_color 'splitter_color_on' "$SPLITTER_COLOR"
    local splitter_color_off
    decorate::print_fg_color 'splitter_color_off' "$SECONDARY_COLOR"
    part_splitter_themed="${splitter_color_on}${part_splitter}${splitter_color_off}"
  fi

  local themed_parts

  for part in "${segment_parts[@]}"; do
    [[ -z "$part" ]] && continue
    part_length="${#part}"

    if [[ -n "$themed_parts" ]]; then
      themed_parts="${themed_parts}${part_splitter_themed}${part}"
      segment_length=$(( segment_length + part_length + part_splitter_length ))
    else
      segment_length="$(( segment_length + part_length))"
      themed_parts="${part}"
    fi
  done

  themed_segment="${themed_segment} ${themed_parts} "
  segment_length=$(( segment_length + 2 ))

  local prepare_color=
  decorate::print_colors 'prepare_color' "$PRIMARY_COLOR" "$PRIMARY_COLOR"
  themed_segment="${themed_segment}${prepare_color}"
  printf '%s\n%s' "$segment_length" "$themed_segment"
}
