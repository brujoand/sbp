#! /usr/bin/env bash

# shellcheck source=functions/decorate.bash
source "${sbp_path}/functions/decorate.bash"
# shellcheck source=functions/configure.bash
source "${sbp_path}/functions/configure.bash"

load_config

generate_extra_options() {
  # TODO this should probably be rewritten to better check
  # if we are messing with any previous settings
  if [[ "$settings_prompt_ready_vi_mode" -eq 1 ]]; then
    local cache_file="${cache_folder}/extra_options.bash"
    rm -f "$cache_file"
    if [[ -n "$settings_prompt_ready_icon" ]]; then
      local insert_color="$settings_prompt_ready_vi_insert_color"
      local command_color="$settings_prompt_ready_vi_command_color"
      local command_segment="\1\e[38;2;${command_color}m\e[49m\2 ${settings_prompt_ready_icon} \1\e[0m\2"
      local insert_segment="\1\e[38;2;${insert_color}m\e[49m\2 ${settings_prompt_ready_icon} \1\e[0m\2"
    fi
    cat << EOF > "$cache_file"
bind 'set show-mode-in-prompt on'
bind "set vi-cmd-mode-string \1\e[2 q\2${command_segment}"
bind "set vi-ins-mode-string \1\e[1 q\2${insert_segment}"
EOF
    echo "$cache_file"
  else
    return 1
  fi

}

list_segments() {
  local active_segments=( "${settings_segments_left[@]}" "${settings_segments_right[@]}" )
  for segment in $(list_feature_files 'segments'); do
    local status='disabled'
    local segment_file="${segment##*/}"
    local segment_name="${segment_file/.bash/}"
    if printf '%s.bash\n' "${active_segments[@]}" | grep -qo "${segment_name}"; then
      if [[ -f "${config_folder}/peekaboo/${segment_name/.bash/}" ]]; then
        status='hidden'
      else
        status='enabled'
      fi
    fi

    _sbp_timer_start
    (bash "$segment" 0 0 left 0 &>/dev/null)
    duration=$(_sbp_timer_tick 2>&1 | tr -d ':')

    echo "${segment_name}: ${status}" "$duration"
  done | column -t -c " "
}

list_hooks() {
  for hook in $(list_feature_files 'hooks'); do
    hook_file="${hook##*/}"
    hook_name="${hook_file/.bash/}"
    status='disabled'
    if printf '%s.bash\n' "${settings_hooks[@]}" | grep -qo "${hook_name}"; then
      if [[ -f "${config_folder}/peekaboo/${hook_name}" ]]; then
        status='paused'
      else
        status='enabled'
      fi
    fi
    echo "${hook_name}: ${status}" | column -t
  done
}

list_layouts() {
  for layout in $(list_feature_files 'themes/layouts'); do
    file="${layout##*/}"
    printf '  %s\n' "${file/.bash/}"
  done
}

show_current_colors() {
  settings_segment_enable_bg_color=1
  for n in "${colors_ids[@]}"; do
    color="color${n}"
    text_color_value=$(get_complement_rgb "${!color}")
    text_color="$(print_fg_color "$text_color_value" 'false')"
    bg_color="$(print_bg_color "${!color}" 'false')"
    printf '%b%b %b%b ' "$bg_color" "$text_color" " $n " "\e[00m"
  done
  printf '\n'
}

list_colors() {
  for color in $(list_feature_files 'themes/colors'); do
    source "$color"
    file="${color##*/}"
    printf '\n%s \n' "${file/.bash/}"
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
  list_feature_names "$1"
}

show_status() {
  read -r -d '' splash <<'EOF'

' _____________________________
 /   _____/\______   \______   \
 \_____  \  |    |  _/|     ___/
 /        \ |    |   \|    |
/_______  / |______  /|____|
        \/         \/
EOF
  printf '%s\n' "${splash}"
  printf '%s: %s\n' 'Color' "${SBP_THEME_LAYOUT:-$settings_theme_layout}"
  printf '%s: %s\n' 'Layout' "${SBP_THEME_COLOR:-$settings_theme_color}"
  printf '\n%s\n' "Current colors:"
  show_current_colors
}

"$@"
