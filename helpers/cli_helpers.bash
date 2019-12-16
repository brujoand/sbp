#! /usr/bin/env bash

# shellcheck source=helpers/formatting.bash
source "${sbp_path}/helpers/formatting.bash"
# shellcheck source=helpers/environment.bash
source "${sbp_path}/helpers/environment.bash"

load_config

generate_extra_options() {
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
  local active_segments=( ${settings_segments_left[@]} ${settings_segments_right[@]} ${settings_segment_line_two[@]} )

  for segment in "$sbp_path"/segments/*.bash; do
    local status='disabled'
    local segment_name="${segment##*/}"
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
  for hook in "$sbp_path"/hooks/*.bash; do
    script="${hook##*/}"
    status='disabled'
    if printf '%s.bash\n' "${settings_hooks[@]}" | grep -qo "${script}"; then
      if [[ -f "${config_folder}/peekaboo/${script/.bash/}" ]]; then
        status='paused'
      else
        status='enabled'
      fi
    fi
    echo "${script/.bash/}: ${status}" | column -t
  done
}

list_colors() {
  for n in "${colors_ids[@]}"; do
    settings_segment_enable_bg_color=1
    color="color${n}"
    text_color_value=$(get_complement_rgb "${!color}")
    text_color="$(print_fg_color "$text_color_value" 'false')"
    bg_color="$(print_bg_color "${!color}" 'false')"
    printf '%b%b %b%b ' "$bg_color" "$text_color" " $n " "\e[00m"
  done
  printf '\n'

}

list_themes() {
  for theme in "$sbp_path"/themes/colors/*.bash; do
    settings_segment_enable_bg_color=1
    source "$theme"
    printf '\n%s \n' "${theme##*/}"
    for n in "${colors_ids[@]}"; do
      color="color${n}"
      text_color_value=$(get_complement_rgb "${!color}")
      text_color="$(print_fg_color "$text_color_value" 'false')"
      bg_color="$(print_bg_color "${!color}" 'false')"
      printf '%b%b %b%b ' "$bg_color" "$text_color" " $n " "\e[00m"
    done
    printf '\n'
  done
}

"$@"
