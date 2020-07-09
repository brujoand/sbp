#! /usr/bin/env bash

segment_value="${SEGMENT_PATH_RO_ICON:-}"

segments::path_ro() {
  #TODO the character needs to be a setting
  if [[ ! -w "$PWD" ]] ; then
    segment_value=""
    print_themed_segment 'normal' "$segment_value"
  fi
}
