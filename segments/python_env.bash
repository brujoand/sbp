#! /usr/bin/env bash

segment_direction=$3

if [[ -n "$VIRTUAL_ENV" ]]; then
  segment_value="${VIRTUAL_ENV##*/}"
else
  path=${PWD}
  while [[ $path ]]; do
    if [[ -f "${path}/.python-version" ]]; then
      segment_value=$(< "${path}/.python-version")
      break
    fi
    path=${path%/*}
  done
fi

if [[ -n "$segment_value" ]]; then
  pretty_print_segment "$settings_python_virtual_env_fg" "$settings_python_virtual_env_bg" " ${segment_value} " "$segment_direction"
fi
