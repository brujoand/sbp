_sbp_print_usage() {
  cat << EOF
  Usage: sbp <command>

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  colors    - List the currently defined colors
  themes    - List all available color themes
  reload    - Reload SBP and user settings
  debug     - Toggle debug mode
  config    - Opens the config in $EDITOR
EOF
}

_sbp_reload() {
  # shellcheck source=/dev/null
  source "$sbp_path"/sbp.bash
}

_sbp_edit_config() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbp/sbp.conf"
  else
    log_error "No \$EDITOR set, unable to open config"
  fi
}

_sbp_toggle_debug() {
  if [[ -z "$SBP_DEBUG" ]]; then
    SBP_DEBUG=true
  else
    unset SBP_DEBUG
  fi
}

sbp() {
  themed_helper="${sbp_path}/helpers/themed_cli_helper.bash"
  case $1 in
    segments) # Show all available segments
      "$themed_helper" 'list_segments'
      ;;
    hooks) # Show all available hooks
      "$themed_helper" 'list_hooks'
      ;;
    colors) # Show currently defined colors
      "$themed_helper" 'list_colors'
      ;;
    themes) # Show all defined colors themes
      "$themed_helper" 'list_themes'
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
    extra_options) # Woho, hiddden function
      "$themed_helper" 'generate_extra_options'
      ;;
    *)
      _sbp_print_usage && return 1
      ;;
  esac
}

_sbp() {
  local cur words
  _get_comp_words_by_ref cur
  words=('segments' 'hooks' 'colors' 'themes' 'reload' 'help' 'config' 'debug')
  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp

