#! /usr/bin/env bash

segments::command() {
  local timer_m=0
  local timer_s=0

  if [[ "$COMMAND_EXIT_CODE" -lt 0 || "$COMMAND_EXIT_CODE" -eq 130 ]]; then
    timer_m=0
    timer_s=0
  fi

  if [[ "$COMMAND_DURATION" -gt 0 ]]; then
    timer_m=$(( COMMAND_DURATION / 60 ))
    timer_s=$(( COMMAND_DURATION % 60 ))
  fi

  command_value="last: ${timer_m}m ${timer_s}s"


  if [[ "$COMMAND_EXIT_CODE" -gt 0 && "$COMMAND_EXIT_CODE" -ne 130 ]]; then
    print_themed_segment 'highlight' "$command_value"
  else
    print_themed_segment 'normal' "$command_value"
  fi

}
