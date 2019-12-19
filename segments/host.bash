#! /usr/bin/env bash

segment_direction=$3

if [[ -n "$SSH_CLIENT" ]]; then
  host_value="${USER}@${HOSTNAME}"
else
  host_value="${USER}"
fi

if [[ "$(id -u)" -eq 0 ]]; then
  host_color_primary="$settings_host_root_color_primary"
  host_color_secondary="$settings_host_root_color_secondary"
else
  host_color_primary="$settings_host_color_primary"
  host_color_secondary="$settings_host_color_secondary"
fi

pretty_print_segment "$host_color_primary" "$host_color_secondary" " ${host_value} " "$segment_direction"
