SETTINGS_SEGMENT_SEPARATOR_RIGHT=''
SETTINGS_SEGMENT_SEPARATOR_LEFT=''
SETTINGS_SEGMENT_SPLITTER_LEFT=''
SETTINGS_SEGMENT_SPLITTER_RIGHT=''
SETTINGS_SEGMENT_SEPARATOR_RIGHT=''
SETTINGS_SEGMENT_SEPARATOR_LEFT=''
SETTINGS_PROMPT_PREFIX_UPPER=''
SETTINGS_PROMPT_PREFIX_LOWER=''
SETTINGS_GIT_ICON=''
SETTINGS_GIT_INCOMING_ICON='out:'
SETTINGS_GIT_OUTGOING_ICON='in:'
SETTINGS_PATH_SPLITTER_DISABLE=1
SETTINGS_TIMESTAMP_FORMAT="%H:%M:%S"
SETTINGS_OPENSHIFT_DEFAULT_USER="$USER"
SETTINGS_RESCUETIME_REFRESH_RATE=600
SETTINGS_SEGMENT_ENABLE_BG_COLOR=0
SETTINGS_PROMPT_READY_ICON='➜'
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
  local segment_parts=("${@}")
  local segment_length=0
  local themed_parts

  if [[ "$color_type" == 'highlight' ]]; then
    PRIMARY_COLOR="$PRIMARY_COLOR_HIGHLIGHT"
  fi

  if [[ "${#segment_parts[@]}" -eq 1 && -z "${segment_parts// /}" ]]; then
    themed_parts="$segment_parts"
  else
    for part in "${segment_parts[@]}"; do
      [[ -z "${part// /}" ]] && continue
      part_length="${#part}"

      themed_parts="${themed_parts} ${part}"
      segment_length=$(( segment_length + part_length + 1 ))
    done
  fi
  if [[ "$SEGMENT_LINE_POSITION" -eq 1 ]]; then
    if [[ "$themed_parts" == " $SETTINGS_PROMPT_READY_ICON" ]]; then
      themed_parts="${themed_parts} "
      segment_length=$(( segment_length + 1 ))
    fi
    themed_parts="${themed_parts:1}"
    segment_length=$(( segment_length - 1 ))
  fi



  local color
  decorate::print_fg_color 'color' "$PRIMARY_COLOR"

  full_output="${color}${themed_parts}"

  printf '%s\n%s' "$segment_length" "$full_output"
}
