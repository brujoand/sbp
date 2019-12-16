_sbp_print_usage() {
  cat << EOF
  Usage: sbp <command>

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  peekaboo  - Toggle enabled segments or hooks
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
    $EDITOR "${HOME}/.config/sbp/settings.conf"
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

_sbp_peekaboo() {
  local feature=$1
  feature_hook="${sbp_path}/hooks/${feature}.bash"
  feature_segment="${sbp_path}/segments/${feature}.bash"
  peekaboo_folder="${HOME}/.config/sbp/peekaboo"
  mkdir -p "${peekaboo_folder}"
  peekaboo_file="${peekaboo_folder}/${feature}"


  if [[ -f "$feature_hook" || -f "$feature_segment" ]]; then
    if [[ -f "$peekaboo_file" ]]; then
      rm "$peekaboo_file"
    else
      touch "$peekaboo_file"
    fi
  fi
}

sbp() {
  themed_helper="${sbp_path}/helpers/cli_helpers.bash"
  case $1 in
    segments) # Show all available segments
      "$themed_helper" 'list_segments'
      ;;
    hooks) # Show all available hooks
      "$themed_helper" 'list_hooks'
      ;;
    peekaboo)
      [[ -z "$2" ]] && _sbp_print_usage
      _sbp_peekaboo "$2"
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
  #_get_comp_words_by_ref cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  words=()
  if [[ "${COMP_WORDS[1]}" == 'peekaboo' ]]; then
    for feature in hooks/*.bash segments/*.bash; do
      file=${feature##*/}
      words+=("${file/.bash}")
    done
  else
    words=('segments' 'hooks' 'peekaboo' 'colors' 'themes' 'reload' 'help' 'config' 'debug')
  fi

  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp

