#! /usr/bin/env bash

# Adapted from liquidprompts load average
# https://github.com/nojhan/liquidprompt/blob/deff598f30f097279d6f6959ba49441923dec041/liquidprompt

CPU_COUNT=$(nproc 2>/dev/null || \grep -c '^[Pp]rocessor' /proc/cpuinfo)

segments::load() {
  local eol IFS=$' \t'
  # shellcheck disable=SC2034,2162
  read LOAD_AVERAGE eol </proc/loadavg
  LOAD_AVERAGE=${LOAD_AVERAGE/./}
  LOAD_AVERAGE=${LOAD_AVERAGE#0}
  LOAD_AVERAGE=${LOAD_AVERAGE#0}
  LOAD_AVERAGE=$((LOAD_AVERAGE / CPU_COUNT))

  if [[ $LOAD_AVERAGE -gt $SEGMENTS_LOAD_THRESHOLD ]]; then
    print_themed_segment 'normal' "$LOAD_AVERAGE"
  elif [[ $LOAD_AVERAGE -gt $SEGMENTS_LOAD_THRESHOLD_HIGH ]]; then
    print_themed_segment 'highlight' "$LOAD_AVERAGE"
  fi
}
