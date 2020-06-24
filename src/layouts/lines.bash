SETTINGS_SEGMENT_SEPARATOR_RIGHT='['
SETTINGS_SEGMENT_SEPARATOR_LEFT=']'
SETTINGS_SEGMENT_SPLITTER_LEFT='-'
SETTINGS_SEGMENT_SPLITTER_RIGHT='-'
SETTINGS_PROMPT_PREFIX_UPPER='┍'
SETTINGS_PROMPT_PREFIX_LOWER='└'
SETTINGS_PROMPT_READY_ICON='➜'
SETTINGS_GIT_ICON=''
SETTINGS_PATH_SPLITTER_DISABLE=1

print_themed_command_mode() {
  local command_color
  decorate::print_fg_color 'command_color' "$SETTINGS_PROMPT_READY_VI_COMMAND_COLOR" false
  echo "${SETTINGS_PROMPT_PREFIX_LOWER}\\1${command_color}\\2${SETTINGS_PROMPT_READY_ICON} "
}

print_themed_insert_mode() {
  local insert_color
  decorate::print_fg_color 'insert_color' "$SETTINGS_PROMPT_READY_VI_INSERT_COLOR" false
  echo "${SETTINGS_PROMPT_PREFIX_LOWER}\\1${insert_color}\\2${SETTINGS_PROMPT_READY_ICON} "
}


print_themed_filler() {
  local -n return_value=$1
  local filler_size=$2
  # Account for seperator and padding
  padding=$(printf "%*s" "$filler_size")
  SEGMENT_LINE_POSITION=2
  prompt_filler_output="$(print_themed_segment 'normal' "$padding")"
  mapfile -t segment_output <<< "$prompt_filler_output"

  return_value=${segment_output[1]}
}

print_themed_segment() {
  local segment_type=$1
  shift
  local segment_parts=("${@}")
  local themed_parts
  local segment_length=0
  local prefix_size=0

  if [[ "$segment_type" == 'prompt_ready' && "$SETTINGS_PROMPT_READY_VI_MODE" -eq 1 ]]; then
    return 0
  fi


  if [[ "$segment_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
  fi

  if [[ -z "${segment_parts[*]// /}" || "$segment_type" == 'prompt_ready' ]]; then
    SETTINGS_SEGMENT_SEPARATOR_RIGHT=''
    SETTINGS_SEGMENT_SEPARATOR_LEFT=''
  fi

  seperator_size=$(( ${#SETTINGS_SEGMENT_SEPARATOR_RIGHT} + ${#SETTINGS_SEGMENT_SEPARATOR_LEFT} ))

  for part in "${segment_parts[@]}"; do
    [[ -z "$part" ]] && continue
    part_length="${#part}"

    if [[ -n "$themed_parts" ]]; then
      themed_parts="${themed_parts} ${part}"
      segment_length=$(( segment_length + part_length + 1 ))
    else
      segment_length="$(( segment_length + part_length ))"
      themed_parts="${part}"
    fi
  done


  if [[ "$SEGMENT_LINE_POSITION" -eq 0 ]]; then
    if [[ "$segment_type" == 'prompt_ready' ]]; then
      prefix="$SETTINGS_PROMPT_PREFIX_LOWER"
    else
      prefix="$SETTINGS_PROMPT_PREFIX_UPPER"
      themed_parts="${themed_parts} "
      segment_length=$(( segment_length + 1 ))
    fi
    prefix_size=${#prefix}
  fi


  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  full_output="${prefix}${color}${SETTINGS_SEGMENT_SEPARATOR_RIGHT}${themed_parts}${SETTINGS_SEGMENT_SEPARATOR_LEFT}"
  segment_length=$(( segment_length + seperator_size + prefix_size ))

  printf '%s\n%s' "$segment_length" "$full_output"
}

