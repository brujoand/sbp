#! /usr/bin/env bash

user_id="$(id -u)"

segments::host() {

  if [[ -n "$SSH_CLIENT" ]]; then
    host_value="${USER}@${HOSTNAME}"
  else
    host_value="$USER"
  fi

  if [[ "$user_id" -eq 0 ]]; then
    print_themed_segment 'highlight' "$host_value"
  else
    print_themed_segment 'normal' "$host_value"
  fi

}
