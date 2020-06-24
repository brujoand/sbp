SETTINGS_SEGMENT_SEPARATOR_LEFT=''
SETTINGS_SEGMENT_SEPARATOR_RIGHT=''
SETTINGS_SEGMENT_SPLITTER_LEFT=''
SETTINGS_SEGMENT_SPLITTER_RIGHT=''
SETTINGS_PROMPT_READY_ICON='➜'
SETTINGS_GIT_ICON=''

#TODO these layouts need a refactor, and should share common functionality

print_themed_command_mode() {
  echo "\1\e[38;2;${command_color}m\e[49m\2 ${SETTINGS_PROMPT_READY_ICON} \1\e[0m\2"
}

print_themed_insert_mode() {
  echo "\1\e[38;2;${insert_color}m\e[49m\2 ${SETTINGS_PROMPT_READY_ICON} \1\e[0m\2"
}


print_themed_filler() {
  local -n return_value=$1
  local seperator_size=${#SETTINGS_SEGMENT_SEPARATOR_LEFT}
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

  if [[ "$segment_type" == 'prompt_ready' && "$SETTINGS_PROMPT_READY_VI_MODE" -eq 1 ]]; then
    return 0
  fi

  if [[ "$segment_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
    SECONDARY_COLOR="$SECONDARY_COLOR_HIGHLIGHT"
  fi

  if [[ "$SEGMENT_POSITION" == 'left' ]]; then
    part_splitter="$SETTINGS_SEGMENT_SPLITTER_LEFT"
    seperator="$SETTINGS_SEGMENT_SEPARATOR_LEFT"
    local seperator_color
    decorate::print_bg_color 'seperator_color' "$PRIMARY_COLOR"
    seperator_themed="${seperator_color}${seperator}"
  elif [[ "$SEGMENT_POSITION" == 'right' ]]; then
    part_splitter="$SETTINGS_SEGMENT_SPLITTER_RIGHT"
    seperator="$SETTINGS_SEGMENT_SEPARATOR_RIGHT"
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
    local local splitter_color_off
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
  themed_segment="${themed_segment_colors}${themed_segment}${prepare_color}"
  printf '%s\n%s' "$segment_length" "$themed_segment"
}
