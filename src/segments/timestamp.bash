#! /usr/bin/env bash

segments::timestamp() {
  local timestamp_format=${SEGMENTS_TIMESTAMP_FORMAT:-'%H:%M:%S'}
  print_themed_segment 'normal' "$(date +"$timestamp_format")"
}
