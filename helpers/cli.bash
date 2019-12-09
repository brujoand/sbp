function _sbp_print_usage() {
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
  generator="${sbp_path}/helpers/generator.bash"
  case $1 in
    segments) # Show all available segments
      "$generator" 'list_segments'
      ;;
    hooks) # Show all available hooks
      "$generator" 'list_hooks'
      ;;
    colors) # Show currently defined colors
      "$generator" 'list_colors'
      ;;
    themes) # Show all defined colors themes
      "$generator" 'list_themes'
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
      "$generator" 'generate_extra_options'
      ;;
    *)
      _sbp_print_usage && exit 1
      ;;
  esac
}

function _sbp() {
  local cur words
  _get_comp_words_by_ref cur
  words=('segments' 'hooks' 'colors' 'themes' 'reload' 'help' 'config' 'debug')
  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp

