#! /usr/bin/env bash
set +a
global_themes_folder="${sbp_path}/themes"
global_layouts_folder="${global_themes_folder}/layouts"
global_colors_folder="${global_themes_folder}/colors"
global_hooks_folder="${sbp_path}/hooks"
global_segments_folder="${sbp_path}/segments"
local_themes_folder="${config_folder}/themes"
local_layouts_folder="${local_themes_folder}/layouts"
local_colors_folder="${local_themes_folder}/colors"
local_hooks_folder="${config_folder}/hooks"
local_segments_folder="${config_folder}/segments"
set -a

log_error() {
  local context="${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;196m%s\e[00m\n' "${context}" "${*}"
}

log_info() {
  local context="${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;76m%s\e[00m\n' "${context}" "${*}"
}

set_colors() {
  local theme_name=$1
  if [[ -z "$theme_name" ]]; then
    log_error "No theme name set"
    log_info "Using the default theme"
    source "${sbp_path}/themes/colors/default.bash"
    return 1
  fi

  user_theme="${config_folder}/themes/colors/${theme_name}.bash"
  sbp_theme="${sbp_path}/themes/colors/${theme_name}.bash"

  if [[ -f "$user_theme" ]]; then
    source "$user_theme"
  elif [[ -f "$sbp_theme" ]]; then
    source "$sbp_theme"
  else
    log_error "Could not find theme file: ${user_theme}"
    log_error "Could not find theme file: ${sbp_theme}"
    log_info "Using the default theme"
    source "${sbp_path}/themes/colors/default.bash"
  fi
}

set_layout() {
  local layout_name=$1
  if [[ -z "$layout_name" ]]; then
    log_error "No layout name set"
    log_info "Using the default layout"
    source "${sbp_path}/themes/layouts/default.bash"
    return 1
  fi

  user_layout="${config_folder}/themes/layouts/${layout_name}.bash"
  sbp_layout="${sbp_path}/themes/layouts/${layout_name}.bash"

  if [[ -f "$user_layout" ]]; then
    source "$user_layout"
  elif [[ -f "$sbp_layout" ]]; then
    source "$sbp_layout"
  else
    log_error "Could not find theme file: ${user_layout}"
    log_error "Could not find theme file: ${sbp_layout}"
    log_info "Using the default theme"
    source "${sbp_path}/themes/layouts/default.bash"
  fi
}

load_config() {
  config_folder="${HOME}/.config/sbp"
  config_file="${config_folder}/settings.conf"
  colors_file="${config_folder}/colors.conf"
  default_config_file="${sbp_path}/config/settings.conf"
  default_colors_file="${sbp_path}/config/colors.conf"
  cache_folder="${config_folder}/cache"
  [[ -d "$cache_folder" ]] || mkdir -p "$cache_folder"

  if [[ ! -f "$config_file" ]]; then
    log_info "Config file note found: ${config_file}"
    log_info "Creating it.."
    cp "$default_config_file" "$config_file"
  fi

  if [[ ! -f "$colors_file" ]]; then
    log_info "Config file note found: ${colors_file}"
    log_info "Creating it.."
    cp "$default_colors_file" "$colors_file"
  fi

  set -a
  # shellcheck source=/dev/null
  source "$config_file"
  set_layout "${SBP_THEME_LAYOUT:-$settings_theme_layout}"
  set_colors "${SBP_THEME_COLOR:-$settings_theme_color}"
  # shellcheck source=/dev/null
  source "$colors_file"
  set +a
}

export -f log_error
export -f log_info
export -f load_config
export -f set_layout
export -f set_colors
export cache_folder
export config_folder
