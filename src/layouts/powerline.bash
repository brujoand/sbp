SEPERATOR_LEFT=${LAYOUTS_POWERLINE_SEPARATOR_LEFT:-''}
SEPERATOR_RIGHT=${LAYOUTS_POWERLINE_SEPARATOR_RIGHT:-''}
SPLITTER_LEFT=${LAYOUTS_POWERLINE_SPLITTER_LEFT:-''}
SPLITTER_RIGHT=${LAYOUTS_POWERLINE_SPLITTER_RIGHT:-''}
SEGMENTS_PROMPT_READY_ICON=${LAYOUTS_POWERLINE_PROMPT_READY_ICON:-'➜'}
SEGMENTS_GIT_ICON=${LAYOUTS_POWERLINE_GIT_ICON:-''}
SEGMENTS_GIT_INCOMING_ICON=${LAYOUTS_POWERLINE_GIT_INCOMING_ICON:-'↓'}
SEGMENTS_GIT_OUTGOING_ICON=${LAYOUTS_POWERLINE_GIT_OUTGOING_ICON:-'↑'}
PROMPT_COMPACT=${SBP_PROMPT_COMPACT:-false}

print_themed_prompt() {
  local left_segments=$1
  local right_segments=$2
  local line_two_segments=$3
  local prompt_gap_size=$4

  # Remove the first seperator as it's not ending a previous segment
  local seperator_left_size=${#SEPERATOR_LEFT}
  left_segments=${left_segments#*$SEPERATOR_LEFT}
  prompt_gap_size=$(( seperator_left_size + prompt_gap_size ))
  # Remove the first seperator as it's not ending a previous segment
  [[ -n "$line_two_segments" ]] && line_two_segments=${line_two_segments#*$SEPERATOR_LEFT}

  local reset_color
  decorate::print_colors 'reset_color'

  if [[ "$PROMPT_COMPACT" == false ]]; then
    left_segments="\n${left_segments}"
  fi


  local filler_segment
  if [[ -n "$right_segments" || -n "$line_two_segments" ]]; then
    print_themed_filler 'filler_segment' "$prompt_gap_size"
    right_segments="${right_segments}${reset_color}\n"
  elif [[ "${SBP_SEGMENTS_LEFT[-1]}" != 'prompt_ready' ]]; then
    # We need to finish the last segment in this case
    print_themed_filler 'filler_segment' 1
    filler_segment="${filler_segment// /}${reset_color} "
  fi

  line_two_segments="${line_two_segments}${reset_color}"

  printf '%s' "${left_segments}${filler_segment}${right_segments}${line_two_segments}"

}

print_themed_filler() {
  local -n print_themed_filler_result=$1
  local seperator_size=${#SEPERATOR_LEFT}
  # Account for seperator and padding
  local filler_size=$(( $2 - seperator_size - 2 ))
  printf -v padding '%*s' "$filler_size"
  SEGMENT_POSITION='left'
  prompt_filler_output="$(print_themed_segment 'normal' "$padding")"
  mapfile -t segment_output <<< "$prompt_filler_output"

  print_themed_filler_result=${segment_output[1]}
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
    local prepare_color=
    decorate::print_fg_color 'prepare_color' "$PRIMARY_COLOR"
  elif [[ "$SEGMENT_POSITION" == 'right' ]]; then
    part_splitter="$SPLITTER_RIGHT"
    seperator="$SEPERATOR_RIGHT"
    local seperator_color
    decorate::print_fg_color 'seperator_color' "$PRIMARY_COLOR"
    seperator_themed="${seperator_color}${seperator}"
    local prepare_color=
    decorate::print_fg_color 'prepare_color' "$PRIMARY_COLOR"
  fi

  local segment_colors
  decorate::print_colors 'segment_colors' "$SECONDARY_COLOR" "$PRIMARY_COLOR"

  if [[ -n "${part_splitter/ /}" ]]; then
    part_splitter=" ${part_splitter} "
  else
    part_splitter=' '
  fi

  local part_splitter_length="${#part_splitter}"
  segment_length="${#seperator}"
  themed_segment="$seperator_themed"
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

  themed_segment="${themed_segment}${prepare_color}"
  printf '%s\n%s' "$segment_length" "$themed_segment"
}
