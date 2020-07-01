SEPERATOR_LEFT=${LAYOUT_LINES_SEPARATOR_LEFT:-'['}
SEPERATOR_RIGHT=${LAYOUT_LINES_SEPARATOR_RIGHT:-']'}
PROMPT_PREFIX_UPPER=${LAYOUT_LINES_PROMPT_PREFIX_UPPER:-'┍'}
PROMPT_PREFIX_LOWER=${LAYOUT_LINES_PROMPT_PREFIX_LOWER:-'└'}
SEGMENTS_PROMPT_READY_ICON=${LAYOUT_LINES_PROMPT_READY_ICON:-'➜'}
SETTINGS_GIT_ICON=${LAYOUT_LINES_GIT_ICON:-' '}
SEGMENTS_PATH_SPLITTER_DISABLE=1

print_themed_prompt() {
  local left_segments=$1
  local right_segments=$2
  local line_two_segments=$3
  local prompt_gap_size=$4

  # Remove the first seperator as it's not ending a previous segment
  prefix_upper_size="${#PROMPT_PREFIX_UPPER}"
  left_segments="\e[0m${PROMPT_PREFIX_UPPER}${left_segments}"
  prompt_gap_size=$(( prefix_upper_size - prompt_gap_size ))
  # Remove the first seperator as it's not ending a previous segment
  prefix_lower_size="${#PROMPT_PREFIX_LOWER}"
  line_two_segments="\e[0m${PROMPT_PREFIX_LOWER}${line_two_segments}"

  local filler_segment
  print_themed_filler 'filler_segment' "$prompt_gap_size"
  printf '%s%s%s\n%s' "$left_segments" "$filler_segment" "$right_segments" "$line_two_segments "
}

print_themed_command_mode() {
  local command_color
  decorate::print_fg_color 'command_color' "$SEGMENTS_PROMPT_READY_VI_COMMAND_COLOR" false
  echo "\1\e[0m\2${PROMPT_PREFIX_LOWER}\1${command_color}\2${PROMPT_READY_ICON} \1\e[0m\2"
}

print_themed_insert_mode() {
  local insert_color
  decorate::print_fg_color 'insert_color' "$SEGMENTS_PROMPT_READY_VI_INSERT_COLOR" false
  echo "\1\e[0m\2${PROMPT_PREFIX_LOWER}\1${insert_color}\2${PROMPT_READY_ICON} \1\e[0m\2"
}


print_themed_filler() {
  local -n return_value=$1
  local filler_size=$2
  # Account for seperator and padding
  padding=$(printf "%*s" "$filler_size")
  prompt_filler_output="$(print_themed_segment 'filler' "$padding")"
  mapfile -t segment_output <<< "$prompt_filler_output"

  return_value=${segment_output[1]}
}

print_themed_segment() {
  local segment_type=$1
  shift
  local segment_parts=("${@}")
  local themed_parts
  local segment_length=0

  if [[ "$segment_type" == 'prompt_ready' && "$SEGMENTS_PROMPT_READY_VI_MODE" -eq 1 ]]; then
    return 0
  fi


  if [[ "$segment_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
  fi

  if [[ "$segment_type" == 'filler' || "$segment_type" == 'prompt_ready' ]]; then
    SEPERATOR_RIGHT=''
    SEPERATOR_LEFT=''
  fi

  seperator_size=$(( ${#SEPERATOR_RIGHT} + ${#SEPERATOR_LEFT} ))

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


  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  local color_reset
  decorate::print_colors 'color_reset'

  full_output="${color_reset}${color}${SEPERATOR_LEFT}${themed_parts}${SEPERATOR_RIGHT}"
  segment_length=$(( segment_length + seperator_size ))

  printf '%s\n%s' "$segment_length" "$full_output"
}

