_sbp_themed_helper="${SBP_PATH}/src/interact_themed.bash"

_sbp_print_usage() {
  cat << EOF
  Usage: sbp [command]

  Commands:
  reload            - Reload SBP and user settings
  status            - Show the current configuration
  help              - Show this help text
  list
    segments        - List all available segments
    hooks           - List all available hooks
    themes          - List all available color themes and layouts
  edit
    config          - Opens the sbp config in \$EDITOR (${EDITOR:-'not set'})
    colors          - Opens the colors config in \$EDITOR (${EDITOR:-'not set'})
  set
    color           - Set [color] for the current session
    layout          - Set [layout] for the current session
  toggle
    peekaboo        - Toggle execution of [segment] or [hook]
    debug           - Toggle debug mode
EOF
}

_sbp_require_argument() {
  local argument=$1
  local name=$2

  if [[ -z "$argument" ]]; then
    echo "Value for required argument '$name' is missing"
    _sbp_print_usage && return 1
  fi
}

_sbp_reload() {
  # shellcheck source=/dev/null
  source "$SBP_PATH"/sbp.bash
}

_sbp_edit_config() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbp/settings.conf"
  else
    echo "No \$EDITOR set, unable to open config"
    echo "You can edit it here: ${HOME}/.config/sbp/settings.conf"
  fi
}

_sbp_edit_colors() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbp/colors.conf"
  else
    echo "No \$EDITOR set, unable to open color"
    echo "You can edit it here: ${HOME}/.config/sbp/colors.conf"
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
  feature_hook="${SBP_PATH}/src/hooks/${feature}.bash"
  feature_segment="${SBP_PATH}/src/segments/${feature}.bash"
  peekaboo_folder="${HOME}/.config/sbp/peekaboo"
  mkdir -p "${peekaboo_folder}"
  peekaboo_file="${peekaboo_folder}/${feature}"


  if [[ -f "$feature_hook" || -f "$feature_segment" ]]; then
    if [[ -f "$peekaboo_file" ]]; then
      command rm "$peekaboo_file"
    else
      touch "$peekaboo_file"
    fi
  fi
}

sbp() {
  case $1 in
    'list')
      case $2 in
        'segments') # Show all available segments
          "$_sbp_themed_helper" 'list_segments'
          ;;
        'hooks') # Show all available hooks
          "$_sbp_themed_helper" 'list_hooks'
          ;;
        'themes') # Show all defined colors and layouts
          "$_sbp_themed_helper" 'list_themes'
          ;;
        *)
          _sbp_print_usage && return 1
          ;;
      esac
      ;;
    'toggle')
      case $2 in
        'peekaboo')
          _sbp_require_argument "$3" '[segment|hook]'
          _sbp_peekaboo "$3"
          ;;
        'debug') # Toggle debug mode
          _sbp_toggle_debug
          ;;
        *)
          _sbp_print_usage && return 1
          ;;
      esac
      ;;
    'set')
      case $2 in
        'color') # Show currently defined colors
          _sbp_require_argument "$3" '[color]'
          export SBP_THEME_COLOR_OVERRIDE="$3"
          _sbp_reload
          ;;
        'layout')
          _sbp_require_argument "$3" '[layout]'
          export SBP_THEME_LAYOUT_OVERRIDE="$3"
          _sbp_reload
          ;;
        *)
          _sbp_print_usage && return 1
          ;;
      esac
      ;;
    'edit')
      case $2 in
        'config') # Open the config file
          _sbp_edit_config
          ;;
        'colors') # Open the config file
          _sbp_edit_colors
          ;;
        *)
          _sbp_print_usage && return 1
          ;;
      esac
      ;;
    'reload') # Reload settings and SBP
      _sbp_reload
      ;;
    'status')
      "$_sbp_themed_helper" 'show_status'
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
  prev="${COMP_WORDS[$(( COMP_CWORD - 1 ))]}"

  words=()
  case "$prev" in
    'set')
      words=('layout' 'color')
      ;;
    'list')
      words=('hooks' 'segments' 'themes')
      ;;
    'toggle')
      words=('debug' 'peekaboo')
      ;;
    'edit')
      words=('config' 'colors')
      ;;
    'peekaboo')
      for hook in $($_sbp_themed_helper list_words 'hooks'); do
        words+=("$hook")
      done

      for segment in $($_sbp_themed_helper list_words 'segments'); do
        words+=("$segment")
      done
      ;;
    'color')
      for color in $($_sbp_themed_helper list_words 'colors'); do
        words+=("$color")
      done
      ;;
    'layout')
      for layout in $($_sbp_themed_helper list_words 'layouts'); do
        words+=("$layout")
      done
      ;;
    *)
      words=('set' 'list' 'toggle' 'edit' 'reload' 'help' 'status')
      ;;
  esac

  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbp sbp

