#! /usr/bin/env bash

segments::1password() {
  command -v op &>/dev/null || return 0

  local icon="${SEGMENTS_1PASSWORD_ICON:-⚿}"

  if op whoami &>/dev/null; then
    print_themed_segment 'normal' "$icon"
  else
    print_themed_segment 'highlight' "$icon"
  fi
}
