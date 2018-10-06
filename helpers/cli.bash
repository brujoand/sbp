function _sbp_print_usage() {
  cat << EOF
  Usage: sbp <command>

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  colors    - List all defined colors
  reload    - Reload SBP and user settings
  config    - Opens the config in $EDITOR
EOF
  return 1
}

function _sbp_load_config() {
  # shellcheck source=helpers/environment.bash
  source "${sbp_path}/helpers/environment.bash"
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
    echo "${segment_name}: ${status}"
  done | column -t -c ':'
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
  $EDITOR "${HOME}/.config/sbp/sbp.conf"
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
    *)
      _sbp_print_usage
      ;;
  esac
}

function _sbp() {
  local cur words
  _get_comp_words_by_ref cur
  words=('segments' 'hooks' 'colors' 'reload' 'help' 'config')
  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp
