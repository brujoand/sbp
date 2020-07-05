SEGMENTS_PROMPT_READY_ICON=${LAYOUTS_PLAIN_PROMPT_READY_ICON:-'➜'}
SEGMENTS_GIT_ICON=${LAYOUTS_PLAIN_GIT_ICON:-' '}
SEGMENTS_GIT_INCOMING_ICON=${LAYOUTS_PLAIN_GIT_INCOMING_ICON:-'↓'}
SEGMENTS_GIT_OUTGOING_ICON=${LAYOUTS_PLAIN_GIT_OUTGOING_ICON:-'↑'}
SEGMENTS_PATH_SPLITTER_DISABLE=${LAYOUTS_PLAIN_PATH_SPLITTER_DISABLE:-1}
PROMPT_COMPACT=${SBP_PROMPT_COMPACT:-false}

print_themed_prompt() {
  local left_segments=$1
  local right_segments=$2
  local line_two_segments=$3
  local prompt_gap_size=$4

  local reset_color
  decorate::print_colors 'reset_color'

  if [[ -n "$right_segments" ]]; then
    right_segments="${right_segments} "
    prompt_gap_size=$(( prompt_gap_size - 1 ))
    right_segments="${right_segments}${reset_color}"
  fi

  if [[ "$PROMPT_COMPACT" == false ]]; then
    left_segments="\n${left_segments}"
  fi

  local filler_segment
  if [[ -n "$right_segments" || -n "$line_two_segments" ]]; then
    print_themed_filler 'filler_segment' "$prompt_gap_size"
    right_segments="${right_segments}\n"
  fi

  line_two_segments="${line_two_segments}${reset_color}"

  printf '%s' "${left_segments}${filler_segment}${right_segments}${line_two_segments}"
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

  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  full_output="${color}${themed_parts}"

  if [[ "$segment_type" == 'prompt_ready' ]]; then
    full_output="${full_output} "
  fi

  printf '%s\n%s' "$segment_length" "$full_output"
}
