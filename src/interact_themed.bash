#! /usr/bin/env bash

# shellcheck source=src/decorate.bash
source "${SBP_PATH}/src/decorate.bash"
# shellcheck source=src/configure.bash
source "${SBP_PATH}/src/configure.bash"
# shellcheck source=src/execute.bash
source "${SBP_PATH}/src/execute.bash"
# shellcheck source=src/debug.bash
source "${SBP_PATH}/src/debug.bash"


configure::load_config

list_config() {
  for setting in $(compgen -A variable | grep '^SEGMENTS_'); do
    local -n value="$setting"
    printf '%s %s\n' "$setting" "$value"
  done | column -t
}

list_segments() {
  for segment_path in $(configure::list_feature_files 'segments'); do
    local status='disabled'
    local segment_file="${segment_path##*/}"
    local segment_name="${segment_file/.bash/}"
    SBP_SEGMENTS=("${SBP_SEGMENTS_LEFT[@]}" "${SBP_SEGMENTS_RIGHT[@]}" "${SBP_SEGMENTS_LINE_TWO[@]}")
    if printf '%s.bash\n' "${SBP_SEGMENTS[@]}" | grep -qo "${segment_name}"; then
      if [[ -f "${SBP_CONFIG}/peekaboo/${segment_name/.bash/}" ]]; then
        status='hidden'
      else
        status='enabled'
      fi
    fi

    debug::start_timer
    (execute::execute_prompt_segment "$segment_name" &>/dev/null)
    duration=$(debug::tick_timer 2>&1 | tr -d ':')

    echo "${segment_name}: ${status}" "$duration"
  done | column -t
}

list_hooks() {
  for hook in $(configure::list_feature_files 'hooks'); do
    hook_file="${hook##*/}"
    hook_name="${hook_file/.bash/}"
    status='disabled'
    if printf '%s.bash\n' "${SBP_HOOKS[@]}" | grep -qo "${hook_name}"; then
      if [[ -f "${SBP_CONFIG}/peekaboo/${hook_name}" ]]; then
        status='paused'
      else
        status='enabled'
      fi
    fi
    echo "${hook_name}: ${status}" | column -t
  done
}

list_layouts() {
  for layout in $(configure::list_feature_files 'layouts'); do
    file="${layout##*/}"
    printf '  %s\n' "${file/.bash/}"
  done
}

show_current_colors() {
  printf '    '
  for n in {0..15}; do
    color="color${n}"
    local text_color_value
    decorate::calculate_complementing_color 'text_color_value' "${!color}"
    local text_color
    decorate::print_fg_color 'text_color' "$text_color_value" 'false'
    local bg_color
    decorate::print_bg_color 'bg_color' "${!color}" 'false'
    printf '%b%b %b%b ' "$bg_color" "$text_color" " $n " "\e[00m"
  done
  printf '\n'
}

list_colors() {
  for color in $(configure::list_feature_files 'colors'); do
    source "$color"
    file="${color##*/}"
    printf '\n  %s \n' "${file/.bash/}"
    show_current_colors
  done
}

list_themes() {
  printf '\n%s:\n' "Colors"
  list_colors
  printf '\n%s:\n' "Layouts"
  list_layouts
}

list_words() {
  configure::list_feature_names "$1"
}

show_status() {
  read -r -d '' splash <<'EOF'

- _____________________________
 /   _____/\______   \______   \
 \_____  \  |    |  _/|     ___/
 /        \ |    |   \|    |
/_______  / |______  /|____|
        \/         \/
EOF
  printf '%s\n' "${splash}"
  printf '%s: %s\n' 'Color' "${SBP_THEME_COLOR:-$SETTINGS_THEME_COLOR}"
  printf '%s: %s\n' 'Layout' "${SBP_THEME_LAYOUT:-$SETTINGS_THEME_LAYOUT}"
  printf '\n%s\n' "Current colors:"
  show_current_colors
}

"$@"
