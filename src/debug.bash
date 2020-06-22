#! /usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  date_cmd='gdate'
else
  date_cmd='date'
fi

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

debug::start_timer() {
  timer_start=$("$date_cmd" +'%s%3N')
}

debug::tick_timer() {
  timer_stop=$("$date_cmd" +'%s%3N')
  timer_spent=$(( timer_stop - timer_start))
  >&2 echo "${timer_spent}ms: $1"
  timer_start=$("$date_cmd" +'%s%3N')
}

