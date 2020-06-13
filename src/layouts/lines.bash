SETTINGS_SEGMENT_SEPARATOR_RIGHT='['
SETTINGS_SEGMENT_SEPARATOR_LEFT=']'
SETTINGS_SEGMENT_SPLITTER_LEFT='-'
SETTINGS_SEGMENT_SPLITTER_RIGHT='-'
SETTINGS_PROMPT_PREFIX_UPPER='┍'
SETTINGS_PROMPT_PREFIX_LOWER='└'
SETTINGS_PROMPT_READY_ICON="${SETTINGS_PROMPT_PREFIX_LOWER}${SETTINGS_PROMPT_READY_ICON}"
SETTINGS_GIT_ICON=' '

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
  local color_type=$1
  shift
  local segment_value="${*}"
  local segment_length=${#segment_value}
  local prefix_size=0

  if [[ "$color_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
  fi

  if [[ -z "${segment_value// /}" || "$segment_value" == "$SETTINGS_PROMPT_READY_ICON" ]]; then
    SETTINGS_SEGMENT_SEPARATOR_RIGHT=''
    SETTINGS_SEGMENT_SEPARATOR_LEFT=''
  fi

  seperator_size=$(( ${#SETTINGS_SEGMENT_SEPARATOR_RIGHT} + ${#SETTINGS_SEGMENT_SEPARATOR_LEFT} ))

  if [[ "$SEGMENT_LINE_POSITION" == 1 ]]; then
    if [[ "$segment_value" == "$SETTINGS_PROMPT_READY_ICON" ]]; then
      segment_value="${segment_value} "
      segment_length=$(( segment_length + 1 ))
    else
      prefix="$SETTINGS_PROMPT_PREFIX_UPPER"
    fi
    prefix_size=${#prefix}
  fi


  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  full_output="${prefix}${color}${SETTINGS_SEGMENT_SEPARATOR_RIGHT}${segment_value}${SETTINGS_SEGMENT_SEPARATOR_LEFT}"
  segment_length=$(( segment_length + seperator_size + prefix_size ))

  printf '%s\n%s' "$segment_length" "$full_output"
}

