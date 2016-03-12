### Defaults
_sbp_timestamp_color_bg=${_sbp_timestamp_color_bg-:$_sbp_color_dgrey}
_sbp_timestamp_color_fg=${_sbp_timestamp_color_fg-:$_sbp_color_lgrey}
_sbp_timestamp_format=${_sbp_timestamp_format-:"%H:%M:%S"}

function _sbp_generate_timestamp_segment {
  local timestamp_color timestamp_value
  timestamp_color=$(print_color_escapes "$_sbp_timestamp_color_fg" "$_sbp_timestamp_color_bg")
  timestamp_value=$(date +"$_sbp_timestamp_format")

  _sbp_segment_new_color="$_sbp_timestamp_color_bg" 
  _sbp_segment_new_length="$(( ${#timestamp_value} + 2 ))" 
  _sbp_segment_new_value="${timestamp_color} ${timestamp_value} "
  _sbp_segment_new_create
}
