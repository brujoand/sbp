#! /usr/bin/env bash

SBP_CONFIG="${HOME}/.config/sbp"
config_file="${SBP_CONFIG}/settings.conf"
colors_file="${SBP_CONFIG}/colors.conf"
default_config_file="${SBP_PATH}/config/settings.conf"
default_colors_file="${SBP_PATH}/config/colors.conf"
SBP_CACHE="${SBP_CONFIG}/cache"

configure::list_feature_files() {
  local feature_type=$1
  IFS=" " read -r -a features <<< "$(\
    shopt -s nullglob; \
    echo ${SBP_PATH}/{src,config}/${feature_type}/*.bash \
      "${SBP_CONFIG}/${feature_type}"/*.bash; \
  )"

  for file in "${features[@]}"; do
    printf '%s\n' "$file"
  done
}

configure::list_feature_names() {
  local feature_type=$1
  for file in $(configure::list_feature_files "$feature_type"); do
    file_name="${file##*/}"
    name="${file_name/.bash/}"
    printf '%s\n' "$name"
  done
}

configure::set_colors() {
  local theme_name=$1
  if [[ -z "$theme_name" ]]; then
    debug::log_error "No theme name set"
    debug::log_info "Using the default theme"
    source "${SBP_PATH}/config/colors/default.bash"
    return 1
  fi

  user_theme="${SBP_CONFIG}/themes/colors/${theme_name}.bash"
  sbp_theme="${SBP_PATH}/config/colors/${theme_name}.bash"

  if [[ -f "$user_theme" ]]; then
    source "$user_theme"
  elif [[ -f "$sbp_theme" ]]; then
    source "$sbp_theme"
  else
    debug::log_error "Could not find theme file: ${user_theme}"
    debug::log_error "Could not find theme file: ${sbp_theme}"
    debug::log_info "Using the default theme"
    source "${SBP_PATH}/config/colors/default.bash"
  fi
}

configure::set_layout() {
  local layout_name=$1
  if [[ -z "$layout_name" ]]; then
    debug::log_error "No layout name set"
    debug::log_info "Using the default layout"
    source "${SBP_PATH}/themes/layouts/default.bash"
    return 1
  fi

  user_layout="${SBP_CONFIG}/themes/layouts/${layout_name}.bash"
  sbp_layout="${SBP_PATH}/src/layouts/${layout_name}.bash"

  if [[ -f "$user_layout" ]]; then
    source "$user_layout"
  elif [[ -f "$sbp_layout" ]]; then
    source "$sbp_layout"
  else
    debug::log_error "Could not find theme file: ${user_layout}"
    debug::log_error "Could not find theme file: ${sbp_layout}"
    debug::log_info "Using the default theme"
    source "${SBP_PATH}/src/layouts/plain.bash"
  fi
}

configure::load_config() {
  [[ -d "$SBP_CACHE" ]] || mkdir -p "$SBP_CACHE"

  if [[ ! -f "$config_file" ]]; then
    debug::log_info "Config file note found: ${config_file}"
    debug::log_info "Creating it.."
    cp "$default_config_file" "$config_file"
  fi

  if [[ ! -f "$colors_file" ]]; then
    debug::log_info "Config file note found: ${colors_file}"
    debug::log_info "Creating it.."
    cp "$default_colors_file" "$colors_file"
  fi

  # shellcheck source=/dev/null
  source "$config_file"
  configure::set_layout "${SBP_THEME_LAYOUT_OVERRIDE:-$SBP_THEME_LAYOUT}"
  configure::set_colors "${SBP_THEME_COLOR_OVERRIDE:-$SBP_THEME_COLOR}"
  # shellcheck source=/dev/null
  source "$colors_file"
}
