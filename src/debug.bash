#! /usr/bin/env bash

debug::log() {
  local timestamp file function
  timestamp=$(date +'%y.%m.%d %H:%M:%S')
  file="${BASH_SOURCE[1]##*/}"
  function="${FUNCNAME[1]}"
  >&2 printf '\n[%s] [%s - %s]: \e[31m%s\e[0m\n' "$timestamp" "$file" "$function" "${*}"
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

