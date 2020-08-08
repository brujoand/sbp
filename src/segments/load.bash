#! /usr/bin/env bash

shopt -s extglob

segments::load_get_cpu_count() {
  [[ -z $cpu_count ]] && cpu_count=$(nproc 2>/dev/null)
  [[ -z $cpu_count ]] && cpu_count=$(sysctl -n hw.ncpu)
  [[ -z $cpu_count ]] && cpu_count=$(\grep -c '^[Pp]rocessor' /proc/cpuinfo)

  if [[ $cpu_count -gt 0 ]]; then
    printf '%s\n' "$cpu_count"
  fi
}

segments::load_get_load_avg() {
  load_avg="$(LC_ALL=C sysctl -n vm.loadavg 2>/dev/null | cut -d ' ' -f 2)"
  if [[ -n $load_avg ]]; then
    printf '%s\n' "$load_avg"
    return 0
  fi

  local eol
  read -r load_avg eol </proc/loadavg
  if [[ -n $load_avg ]]; then
    printf '%s\n' "$load_avg"
    return 0
  fi
}

segments::load() {
  local load_avg cpu_count
  load_avg="$(segments::load_get_load_avg)"
  cpu_count="$(segments::load_get_cpu_count)"

  if [[ -z "$load_avg" || -z "$cpu_count" ]]; then
    debug::log 'No known ways of calculating load on this system'
    return 1
  fi

  load_avg=${load_avg/./}
  load_avg=${load_avg##+(0)}
  load_avg=$((load_avg / cpu_count))

  if [[ $load_avg -gt $SEGMENTS_LOAD_THRESHOLD ]]; then
    print_themed_segment 'normal' "$load_avg"
  elif [[ $load_avg -gt $SEGMENTS_LOAD_THRESHOLD_HIGH ]]; then
    print_themed_segment 'highlight' "$load_avg"
  fi
}
