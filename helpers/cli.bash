# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

function _sbp_print_usage() {
  cat << EOF
  Usage: sbp <command>

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  colors    - List all defined colors
  reload    - Reload SBP and user settings
  debug     - Toggle debug mode
  config    - Opens the config in $EDITOR
EOF
}

function _sbp_load_config() {
  load_config
}

function _sbp_list_segments() {
  _sbp_load_config
  local active_segments=( ${settings_segments_left[@]} ${settings_segments_right[@]} ${settings_segment_line_two[@]} )

  for segment in "$sbp_path"/segments/*.bash; do
    local status='disabled'
    local segment_name="${segment##*/}"
    if printf '%s.bash\n' "${active_segments[@]}" | grep -qo "${segment_name}"; then
      status='enabled'
    fi

    _sbp_timer_start
    (bash "$segment" 0 0 left 0 &>/dev/null)
    duration=$(_sbp_timer_tick 2>&1 | tr -d ':')

    echo "${segment_name}: ${status}" "$duration"
  done | column -t -c " "
}

function _sbp_list_hooks() {
  _sbp_load_config
  for hook in "$sbp_path"/hooks/*.bash; do
    script="${hook##*/}"
    status='disabled'
    if printf '%s.bash\n' "${settings_hooks[@]}" | grep -qo "${script}"; then
      status='enabled'
    fi
    echo "${script/.bash/}: ${status}" | column -t
  done
}

function _sbp_list_colors() {
  _sbp_load_config
  grep -Eo 'settings_color_[a-z]+' "${sbp_path}"/helpers/defaults.bash | sort -u | while IFS= read -r color_name; do
    color_number="${!color_name}"
    [[ "$color_number" -ge 0 ]] && echo -e "\e[38;5;${color_number}m \$${color_name}\e[00m"
  done
}

function _sbp_reload() {
  # shellcheck source=/dev/null
  source "$sbp_path"/sbp.bash
}

function _sbp_edit_config() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbp/sbp.conf"
  else
    log_error "No \$EDITOR set, unable to open config"
  fi
}

function _sbp_toggle_debug() {
  if [[ -z "$SBP_DEBUG" ]]; then
    SBP_DEBUG=true
  else
    unset SBP_DEBUG
  fi
}

function sbp() {
  case $1 in
    segments) # Show all available segments
      (_sbp_list_segments)
      ;;
    hooks) # Show all available hooks
      (_sbp_list_hooks)
      ;;
    colors) # Show all defined colors
      (_sbp_list_colors)
      ;;
    reload) # Reload settings and SBP
      _sbp_reload
      ;;
    config) # Open the config file
      _sbp_edit_config
      ;;
    debug) # Toggle debug mode
      _sbp_toggle_debug
      ;;
    *)
      _sbp_print_usage && return 1
      ;;
  esac
}

function _sbp() {
  local cur words
  _get_comp_words_by_ref cur
  words=('segments' 'hooks' 'colors' 'reload' 'help' 'config' 'debug')
  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp
