#!/usr/bin/env bash

segments::rescuetime() {
  local cache_file="${cache_folder}/rescuetime.csv"

  if [[ -f "$cache_file" ]]; then
    read -r cache < "$cache_file"
    pulse="${cache/;*}"
    time="${cache/*;}"
  else
    exit 0
  fi

  print_themed_segment 'normal' "$pulse" "$time"

}
