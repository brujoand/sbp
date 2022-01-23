#! /usr/bin/env bash

SBP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/sbp"
config_file="${SBP_CONFIG}/settings.conf"
colors_file="${SBP_CONFIG}/colors.conf"
config_template="${SBP_PATH}/config/settings.conf.template"
colors_template="${SBP_PATH}/config/colors.conf.template"
default_colors="${SBP_PATH}/config/colors.conf"
default_config="${SBP_PATH}/config/settings.conf"
SBP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/sbp"

configure::list_feature_files() {
  local feature_type=$1
  IFS=" " read -r -a features <<< "$(\
    shopt -s nullglob; \
    echo "${SBP_PATH}/src/${feature_type}"/*.bash \
      "${SBP_CONFIG}/${feature_type}"/*.bash; \
  )"

  for file in "${features[@]}"; do
    printf '%s\n' "$file"
  done
}

configure::get_feature_file() {
  local -n get_feature_file_result=$1
  local feature_type=$2
  local feature_name=$3

  local local_file="${SBP_PATH}/src/${feature_type}s/${feature_name}.bash"
  local global_file="${SBP_CONFIG}/${feature_type}s/${feature_name}.bash"

  if [[ -f "$local_file" ]]; then
    get_feature_file_result="$local_file"
  elif [[ -f "$global_file" ]]; then
    get_feature_file_result="$global_file"
  else
    debug::log "Could not find $local_file"
    debug::log "Could not find $global_file"
    debug::log "Make sure at least on of them exists"
  fi

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
  local color_name=$1
  local colors_file
  configure::get_feature_file 'colors_file' 'color' "$color_name"

  if [[ -n "$colors_file" ]]; then
    source "$colors_file"
  else
    debug::log "Using the default color config"
    source "${SBP_PATH}/src/colors/default.bash"
  fi
}

configure::set_layout() {
  local layout_name=$1
  local layout_file

  configure::get_feature_file 'layout_file' 'layout' "$layout_name"

  if [[ -n "$layout_file" ]]; then
    source "$layout_file"
  else
    debug::log "Using the default layout"
    source "${SBP_PATH}/src/layouts/plain.bash"
  fi
}

configure::load_config() {
  [[ -d "$SBP_CACHE" ]] || mkdir -p "$SBP_CACHE"

  if [[ ! -f "$config_file" ]]; then
    debug::log "Config file not found: ${config_file}"
    debug::log "Creating it.."
    cp "$config_template" "$config_file"
  fi

  if [[ ! -f "$colors_file" ]]; then
    debug::log "Color config file not found: ${colors_file}"
    debug::log "Creating it.."
    cp "$colors_template" "$colors_file"
  fi

  # shellcheck source=/dev/null
  source "$config_file"
  source "$default_config"
  configure::set_layout "${SBP_THEME_LAYOUT_OVERRIDE:-$SBP_THEME_LAYOUT}"
  configure::set_colors "${SBP_THEME_COLOR_OVERRIDE:-$SBP_THEME_COLOR}"
  # shellcheck source=/dev/null
  source "$colors_file"
  source "$default_colors"
}
