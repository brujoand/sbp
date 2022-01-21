#! /usr/bin/env bash

SBP_CONFIG="${HOME}/.config/sbp"
config_file="${SBP_CONFIG}/settings.conf"
colors_file="${SBP_CONFIG}/colors.conf"
config_template="${SBP_PATH}/config/settings.conf.template"
colors_template="${SBP_PATH}/config/colors.conf.template"
default_colors="${SBP_PATH}/config/colors.conf"
default_config="${SBP_PATH}/config/settings.conf"
SBP_CACHE="${SBP_CONFIG}/cache"

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

configure::deprecate::_is_warning_enabled() {
  # shellcheck disable=SC2154 # _sbp_set_prompt_count is supposed to be
  # exported by the parent shell.
  ((_sbp_set_prompt_count <= 1))
}

configure::deprecate::_warn_proc() {
  local old_config_name=$1 new_config_name=${2-} message=${3-}
  local sgr0=$'\e[m' sgr_old=$'\e[1;31m' sgr_new=$'\e[1;34m'
  if [[ ! $message && $new_config_name ]]; then
    message="Please use '$sgr_new$new_config_name$sgr0'."
  fi
  printf '\e[35m%s\e[36m:\e[32m%s\e[36m:\e[m %s\n' "${BASH_SOURCE[1]}" "${BASH_LINENO[0]}" "'$sgr_old$old_config_name$sgr0' is deprecated.${message:+ $message}" >/dev/tty
}

configure::deprecate::_add_scalar() {
  local old_config_name=$1 new_config_name=$2
  local fallback_variable=${new_config_name:-_sbp_configure_deprecate__$old_config_name}
  if configure::deprecate::_is_warning_enabled; then
    # shellcheck disable=SC1087
    declare -gn "$old_config_name=$fallback_variable[\$(configure::deprecate::_warn_proc '$old_config_name' '$new_config_name')]"
  else
    declare -gn "$old_config_name=$fallback_variable"
  fi
  _sbp_configure_deprecated_configs+=()
}

configure::deprecate::_add_array() {
  local old_config_name=$1 new_config_name=$2 default_elements=$3
  _sbp_configure_deprecated_arrays+=("$old_config_name:$new_config_name:$default_elements")
}

configure::deprecate::reset() {
  local old_config_name
  for old_config_name in "${_sbp_configure_deprecated_configs[@]}"; do
    unset -n "$old_config_name"
  done
  unset -v _sbp_configure_deprecated_configs

  local entry new_config_name default_elements
  for entry in "${_sbp_configure_deprecated_arrays[@]}"; do
    old_config_name=${entry%%:*} entry=${entry#*:}
    new_config_name=${entry%%:*} entry=${entry#*:}
    default_elements=$entry
    if ! declare -p "$new_config_name" &>/dev/null; then
      if declare -p "$old_config_name" &>/dev/null; then
        if configure::deprecate::_is_warning_enabled; then
          local sgr0=$'\e[m' sgr_file=$'\e[35m' sgr_sep=$'\e[36m' sgr_old=$'\e[1;31m' sgr_new=$'\e[1;34m'
          printf '%s\n' "$sgr_file$config_file$sgr_sep:$sgr0 Array '$sgr_old$old_config_name$sgr0' is deprecated. Please assign to '$sgr_new$new_config_name$sgr0'." >/dev/tty
        fi
        eval -- "$new_config_name=(\"\${$old_config_name[@]}\")"
      else
        eval -- "$new_config_name=($default_elements)"
      fi
    fi
  done
}

configure::deprecate::setup() {
  # List of deprecated configuration variables

  # commit 3c9b999f24445441fa828627c6b269e8c322704b
  configure::deprecate::_add_scalar color00 color0
  configure::deprecate::_add_scalar color01 color1
  configure::deprecate::_add_scalar color02 color2
  configure::deprecate::_add_scalar color03 color3
  configure::deprecate::_add_scalar color04 color4
  configure::deprecate::_add_scalar color05 color5
  configure::deprecate::_add_scalar color06 color6
  configure::deprecate::_add_scalar color07 color7
  configure::deprecate::_add_scalar color08 color8
  configure::deprecate::_add_scalar color09 color9
  configure::deprecate::_add_scalar color0A color10
  configure::deprecate::_add_scalar color0B color11
  configure::deprecate::_add_scalar color0C color12
  configure::deprecate::_add_scalar color0D color13
  configure::deprecate::_add_scalar color0E color14
  configure::deprecate::_add_scalar color0F color15

  configure::deprecate::_add_array settings_hooks          SBP_HOOKS          "'alert'"
  configure::deprecate::_add_array settings_segments_left  SBP_SEGMENTS_LEFT  "'host' 'path' 'python_env' 'k8s' 'git' 'nix'"
  configure::deprecate::_add_array settings_segments_right RBP_SEGMENTS_RIGHT "'command' 'timestamp'"

  configure::deprecate::_add_scalar settings_theme_color             SBP_THEME_COLOR
  configure::deprecate::_add_scalar settings_theme_layout            SBP_THEME_LAYOUT
  configure::deprecate::_add_scalar settings_timestamp_format        SEGMENTS_TIMESTAMP_FORMAT
  configure::deprecate::_add_scalar settings_openshift_default_user  SEGMENTS_K8S_DEFAULT_USER
  configure::deprecate::_add_scalar settings_openshift_hide_cluster  SEGMENTS_K8S_HIDE_CLUSTER
  configure::deprecate::_add_scalar settings_rescuetime_refresh_rate SEGMENTS_RESCUETIME_REFRESH_RATE
  configure::deprecate::_add_scalar settings_git_icon                SEGMENTS_GIT_ICON              'This will be set up by layout.'
  configure::deprecate::_add_scalar settings_git_incoming_icon       SEGMENTS_GIT_INCOMING_ICON     'This will be set up by layout.'
  configure::deprecate::_add_scalar settings_git_outgoing_icon       SEGMENTS_GIT_OUTGOING_ICON     'This will be set up by layout.'
  configure::deprecate::_add_scalar settings_path_splitter_disable   SEGMENTS_PATH_SPLITTER_DISABLE 'This will be set up by layout.'
  configure::deprecate::_add_scalar settings_prompt_ready_icon       SEGMENTS_PROMPT_READY_ICON     'This will be set up by layout.'

  configure::deprecate::_add_scalar settings_command_color_primary              SEGMENTS_COMMAND_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_command_color_secondary            SEGMENTS_COMMAND_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_command_color_primary_error        SEGMENTS_COMMAND_COLOR_PRIMARY_HIGHLIGHT
  configure::deprecate::_add_scalar settings_command_color_secondary_error      SEGMENTS_COMMAND_COLOR_SECONDARY_HIGHLIGHT
  configure::deprecate::_add_scalar settings_git_color_primary                  SEGMENTS_GIT_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_git_color_secondary                SEGMENTS_GIT_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_host_color_primary                 SEGMENTS_HOST_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_host_color_secondary               SEGMENTS_HOST_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_host_root_color_primary            SEGMENTS_HOST_COLOR_PRIMARY_HIGHLIGHT
  configure::deprecate::_add_scalar settings_host_root_color_secondary          SEGMENTS_HOST_COLOR_SECONDARY_HIGHLIGHT
  configure::deprecate::_add_scalar settings_path_color_primary                 SEGMENTS_PATH_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_path_color_secondary               SEGMENTS_PATH_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_path_splitter_color                SEGMENTS_PATH_COLOR_SPLITTER
  configure::deprecate::_add_scalar settings_path_readonly_color_secondary      SEGMENTS_PATH_RO_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_path_readonly_color_primary        SEGMENTS_PATH_RO_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_prompt_ready_color_primary         SEGMENTS_PROMPT_READY_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_prompt_ready_color_secondary       SEGMENTS_PROMPT_READY_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_python_virtual_env_color_primary   SEGMENTS_PYTHON_ENV_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_python_virtual_env_color_secondary SEGMENTS_PYTHON_ENV_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_return_code_color_primary          SEGMENTS_RETURN_CODE_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_return_code_color_secondary        SEGMENTS_RETURN_CODE_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_timestamp_color_primary            SEGMENTS_TIMESTAMP_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_timestamp_color_secondary          SEGMENTS_TIMESTAMP_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_aws_color_primary                  SEGMENTS_AWS_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_aws_color_secondary                SEGMENTS_AWS_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_openshift_color_primary            SEGMENTS_K8S_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_openshift_color_secondary          SEGMENTS_K8S_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_rescuetime_color_primary           SEGMENTS_RESCUETIME_COLOR_PRIMARY
  configure::deprecate::_add_scalar settings_rescuetime_color_secondary         SEGMENTS_RESCUETIME_COLOR_SECONDARY
  configure::deprecate::_add_scalar settings_rescuetime_splitter_color          SEGMENTS_RESCUETIME_SPLITTER_COLOR
  configure::deprecate::_add_scalar settings_prompt_ready_vi_mode          ''
  configure::deprecate::_add_scalar settings_prompt_ready_newline          ''
  configure::deprecate::_add_scalar settings_prompt_ready_vi_insert_color  ''
  configure::deprecate::_add_scalar settings_prompt_ready_vi_command_color ''

  # commit 3e2eba8f62098fb07be071445482494c4b36c03f
  configure::deprecate::_add_scalar SEGMENTS_PATH_SPLITTER_COLOR SEGMENTS_PATH_COLOR_SPLITTER

  # commit b3b3c0ba039036ef7eeccddfa3e9fda26eda1642
  configure::deprecate::_add_scalar SEGMENTS_PATH_READONLY_COLOR_SECONDARY SEGMENTS_PATH_RO_COLOR_SECONDARY
  configure::deprecate::_add_scalar SEGMENTS_PATH_READONLY_COLOR_PRIMARY   SEGMENTS_PATH_RO_COLOR_PRIMARY

  # commit f5d0b29e2647ce644ea01be469da10a3cbb4939d
  configure::deprecate::_add_scalar SETTINGS_WTTR_LOCATION SEGMENTS_WTTR_LOCATION
  configure::deprecate::_add_scalar SETTINGS_WTTR_FORMAT   SEGMENTS_WTTR_FORMAT
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

  configure::deprecate::setup

  # shellcheck source=/dev/null
  source "$config_file"
  source "$default_config"
  configure::set_layout "${SBP_THEME_LAYOUT_OVERRIDE:-$SBP_THEME_LAYOUT}"
  configure::set_colors "${SBP_THEME_COLOR_OVERRIDE:-$SBP_THEME_COLOR}"
  # shellcheck source=/dev/null
  source "$colors_file"
  source "$default_colors"

  configure::deprecate::reset
}
