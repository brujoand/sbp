#! /usr/bin/env bash

function log_error() {
  local context="${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;196m%s\e[00m\n' "${context}" "${*}"
}

function log_info() {
  local context="${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;76m%s\e[00m\n' "${context}" "${*}"
}

function set_theme() {
  local theme_name=$1
  if [[ -z "$theme_name" ]]; then
    log_error "No theme name set"
    log_info "Using the default theme"
    source "${sbp_path}/themes/default.bash"
    return 1
  fi

  user_theme="${config_dir}/themes/${theme_name}.bash"
  sbp_theme="${sbp_path}/themes/${theme_name}.bash"

  if [[ -f "$user_theme" ]]; then
    source "$user_theme"
  elif [[ -f "$sbp_theme" ]]; then
    source "$sbp_theme"
  else
    log_error "Could not find theme file: ${user_theme}"
    log_error "Could not find theme file: ${sbp_theme}"
    log_info "Using the default theme"
    source "${sbp_path}/themes/default.bash"
  fi
}

function load_config() {
  config_dir="${HOME}/.config/sbp"
  config_file="${config_dir}/sbp.conf"
  cache_folder="${config_dir}/cache"
  mkdir -p "$cache_folder"
  default_config_file="${sbp_path}/helpers/defaults.bash"

  # Load the users settings if it exists
  if [[ -f "$config_file" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$config_file"
    set +a
  else
    set -a
    # shellcheck source=helpers/defaults.bash
    source "$default_config_file"
    set +a
    mkdir -p "$config_dir"
    cp "$default_config_file" "$config_file"
  fi
}

export -f log_error
export -f log_info
export -f set_theme
export cache_folder
