#! /usr/bin/env bash

segments::1password() {
  command -v op &>/dev/null || return 0

  local icon="${SEGMENTS_1PASSWORD_ICON:-op}"
  local whoami account

  if ! whoami="$(op whoami 2>/dev/null)"; then
    print_themed_segment 'highlight' "$icon" 'signed out'
    return 0
  fi

  [[ $whoami =~ URL:[[:space:]]+https://([^.]+) ]] && account="${BASH_REMATCH[1]}"
  print_themed_segment 'normal' "$icon" ${account:+"$account"}
}
