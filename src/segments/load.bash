#! /usr/bin/env bash

# Adapted from liquidprompts load average
# https://github.com/nojhan/liquidprompt/blob/deff598f30f097279d6f6959ba49441923dec041/liquidprompt

segments::init_load() {
  case "$(uname -s)" in
    Darwin | FreeBSD | OpenBSD)
      CPU_COUNT=$(sysctl -n hw.ncpu)

      get_load_average() {
        local bol eol IFS=$' \t'
        # shellcheck disable=SC2034,SC2162
        read bol LOAD_AVERAGE eol <<<"$(LC_ALL=C sysctl -n vm.loadavg)"
      }
      ;;
    Linux)
      CPU_COUNT=$(nproc 2>/dev/null || \grep -c '^[Pp]rocessor' /proc/cpuinfo)

      get_load_average() {
        local eol IFS=$' \t'
        # shellcheck disable=SC2034,SC2162
        read LOAD_AVERAGE eol </proc/loadavg
      }
      ;;
    *)
      # TODO inform the user that his system is not supported
      ;;
  esac
}

segments::load() {
  segments::init_load

  local LOAD_AVERAGE
  get_load_average
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
