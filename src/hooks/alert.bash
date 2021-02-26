#! /usr/bin/env bash

HOOKS_ALERT_THRESHOLD="${HOOKS_ALERT_THRESHOLD:-60}"

hooks::alert_notify() {
  [[ -z "$2" ]] && return

  title=$1
  message=$2

  if type terminal-notifier &> /dev/null; then
    (terminal-notifier -title "$title" -message "$message" &)
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    osascript -e "display notification \"$message\" with title \"$title\""
  elif type ntfy &> /dev/null; then
    if [[ -z $HOOKS_ALERT_NTFY_BACKEND ]]; then
      (ntfy -t "$title" send "$message" &)
    else
      (ntfy -b $HOOKS_ALERT_NTFY_BACKEND -t "$title" send "$message" &)
    fi
  elif type notify-send &> /dev/null; then
    (notify-send --icon=terminal "$title" "$message" &)
  fi
}

hooks::alert() {
  [[ "$COMMAND_EXIT_CODE" -lt 0 ]] && return
  if [[ "$HOOKS_ALERT_THRESHOLD" -le "$COMMAND_DURATION" ]]; then
    local title message

    if [[ "$COMMAND_EXIT_CODE" -eq "0" ]]; then
      title="Command Succeded"
      message="Time spent was ${COMMAND_DURATION}s"
    else
      title="Command Failed"
      message="Time spent was ${COMMAND_DURATION}s"
    fi

    hooks::alert_notify "$title" "$message"
  fi
}
