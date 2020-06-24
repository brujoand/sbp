SEGMENTS_PROMPT_READY_ICON=${LAYOUTS_PLAIN_PROMPT_READY_ICON:-'➜'}
SEGMENTS_GIT_ICON=${LAYOUTS_PLAIN_GIT_ICON:-' '}
SEGMENTS_GIT_INCOMING_ICON=${LAYOUTS_PLAIN_GIT_INCOMING_ICON:-'↓'}
SEGMENTS_GIT_OUTGOING_ICON=${LAYOUTS_PLAIN_GIT_OUTGOING_ICON:-'↑'}

print_themed_command_mode() {
  local command_color
  decorate::print_fg_color 'command_color' "$SEGMENTS_PROMPT_READY_VI_COMMAND_COLOR" false
  echo "\1\e[0m\2\1${command_color}\2 ${PROMPT_READY_ICON} \1\e[0m\2"
}

print_themed_insert_mode() {
  local insert_color
  decorate::print_fg_color 'insert_color' "$SEGMENTS_PROMPT_READY_VI_INSERT_COLOR" false
  echo "\1\e[0m\2\1${insert_color}\2 ${PROMPT_READY_ICON} \1\e[0m\2"
}

print_themed_filler() {
  local -n return_value=$1
  local filler_size=$2
  # Account for seperator and padding
  padding=$(printf "%*s" "$filler_size")
  SEGMENT_LINE_POSITION=2
  prompt_filler_output="$(print_themed_segment 'filler' "$padding")"
  mapfile -t segment_output <<< "$prompt_filler_output"

  return_value=${segment_output[1]}
}

print_themed_segment() {
  local segment_type=$1
  shift
  local segment_parts=("${@}")
  local segment_length=0
  local themed_parts

  if [[ "$segment_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
  fi

  if [[ "$segment_type" == 'filler' ]]; then
    themed_parts="$segment_parts"
  else
    for part in "${segment_parts[@]}"; do
      [[ -z "${part// /}" ]] && continue
      part_length="${#part}"

      themed_parts="${themed_parts} ${part}"
      segment_length=$(( segment_length + part_length + 1 ))
    done
  fi
  if [[ "$segment_type" == 'prompt_ready' ]]; then
    themed_parts="${themed_parts} "
    segment_length=$(( segment_length + 1 ))
  elif [[ "$SEGMENT_LINE_POSITION" -eq 0 ]]; then
    themed_parts="${themed_parts:1}"
    segment_length=$(( segment_length - 1 ))
  fi



  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  full_output="${color}${themed_parts}"

  printf '%s\n%s' "$segment_length" "$full_output"
}
