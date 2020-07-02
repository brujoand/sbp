#! /usr/bin/env bash

segments::exit_code() {
  if [[ "$COMMAND_EXIT_CODE" -ne 0 && "$COMMAND_EXIT_CODE" -ne 130 ]]; then
    print_themed_segment 'highlight' "$COMMAND_EXIT_CODE"
  fi
}
