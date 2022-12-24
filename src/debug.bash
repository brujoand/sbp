#! /usr/bin/env bash

debug::log() {
  local timestamp file function
  printf -v timestamp '%(%y.%m.%d %H:%M:%S)T' -1
  file="${BASH_SOURCE[1]##*/}"
  function="${FUNCNAME[1]}"
  printf >&2 '\n[%s] [%s - %s]: \e[31m%s\e[0m\n' "$timestamp" "$file" "$function" "${*}"
}

if [[ ${EPOCHREALTIME-} ]]; then
  date_cmd=EPOCHREALTIME
else
  if [[ $OSTYPE == "darwin"* ]]; then
    if type -P gdate &>/dev/null; then
      date_cmd='gdate'
    fi
  else
    date_cmd='date'
  fi
fi

debug::get_clock() {
  if [[ $date_cmd == EPOCHREALTIME ]]; then
    printf -v "$1" %s "${EPOCHREALTIME//[!0-9]/}"
    printf -v "$1" %s "${!1%???}" # strip 3 digits of microsec resolution
  else
    printf -v "$1" %s "$("$date_cmd" +'%s%3N')"
  fi
}

debug::start_timer() {
  debug::get_clock timer_start
}

debug::tick_timer() {
  [[ -z $date_cmd ]] && return 0
  local timer_stop timer_spent
  debug::get_clock timer_stop
  # shellcheck disable=SC2154
  timer_spent=$((timer_stop - timer_start))
  echo >&2 "${timer_spent}ms: $1"
  debug::get_clock timer_start
}
