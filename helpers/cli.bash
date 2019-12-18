_sbp_print_usage() {
  cat << EOF
  Usage: sbp [command]

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  peekaboo  - Toggle visibility of [segment] or [hook]
  color     - Set [color] for the current session
  layout    - Set [layout] for the current session
  themes    - List all available color themes and layouts
  reload    - Reload SBP and user settings
  debug     - Toggle debug mode
  status    - Show the current configuration
  config    - Opens the config in \$EDITOR ($EDITOR)
EOF
}

_sbp_require_argument() {
  local argument=$1
  local name=$2

  if [[ -z "$argument" ]]; then
    echo "Value for required argument '$name' is missing"
    _sbp_print_usage
    return 1
  fi
}

_sbp_reload() {
  # shellcheck source=/dev/null
  source "$sbp_path"/sbp.bash
}

_sbp_edit_config() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbp/settings.conf"
  else
    echo "No \$EDITOR set, unable to open config"
    echo "You can edit it here: ${HOME}/.config/sbp/settings.conf"
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
    'segments') # Show all available segments
      "$themed_helper" 'list_segments'
      ;;
    'hooks') # Show all available hooks
      "$themed_helper" 'list_hooks'
      ;;
    'peekaboo')
      _sbp_require_argument "$2" '[segment|hook]'
      _sbp_peekaboo "$2"
      ;;
    'color') # Show currently defined colors
      _sbp_require_argument "$2" '[color]'
      export SBP_THEME_COLORS="$2"
      ;;
    'layout')
      _sbp_require_argument "$2" '[layout]'
      export SBP_THEME_LAYOUT="$2"
      ;;
    'themes') # Show all defined colors and layouts
      "$themed_helper" 'list_themes'
      ;;
    'reload') # Reload settings and SBP
      _sbp_reload
      ;;
    'config') # Open the config file
      _sbp_edit_config
      ;;
    'debug') # Toggle debug mode
      _sbp_toggle_debug
      ;;
    'extra_options') # Woho, hiddden function
      "$themed_helper" 'generate_extra_options'
      ;;
    'status')
      "$themed_helper" 'show_status'
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
  prev="${COMP_WORDS[1]}"

  words=()
  case "$prev" in
    'peekaboo')
      for feature in "${sbp_path}/hooks/"*.bash "${sbp_path}segments/"*.bash; do
        file=${feature##*/}
        words+=("${file/.bash}")
      done
      ;;
    'color')
      for color in "${sbp_path}/themes/colors/"*.bash; do
        file=${color##*/}
        words+=("${file/.bash}")
      done
      ;;
    'layout')
      for layout in "${sbp_path}/themes/layouts/"*.bash; do
        file=${layout##*/}
        words+=("${file/.bash}")
      done
      ;;
    *)
      words=('segments' 'hooks' 'peekaboo' 'color' 'layout' 'themes' 'reload' 'help' 'config' 'status' 'debug')
      ;;
  esac

  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp

