#! /usr/bin/env bash

debug::log_error() {
  local timestamp=$(date +'%y.%m.%d %H:%M:%S')
  local context="${timestamp}:${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;196m%s\e[00m\n' "${context}" "${*}"
}

debug::log_info() {
  local timestamp=$(date +'%y.%m.%d %H:%M:%S')
  local context="${timestamp}:${BASH_SOURCE[1]}:${FUNCNAME[1]}"
  >&2 printf '%s: \e[38;5;76m%s\e[00m\n' "${context}" "${*}"
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  if type -P gdate &>/dev/null; then
    date_cmd='gdate'
  fi
else
  date_cmd='date'
fi

debug::start_timer() {
  timer_start=$("$date_cmd" +'%s%3N')
}

debug::tick_timer() {
  [[ -z "$date_cmd" ]] && return 0
  timer_stop=$("$date_cmd" +'%s%3N')
  timer_spent=$(( timer_stop - timer_start))
  >&2 echo "${timer_spent}ms: $1"
  timer_start=$("$date_cmd" +'%s%3N')
}

