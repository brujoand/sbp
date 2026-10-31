#! /usr/bin/env bash

# op authorizes per terminal, so the state lives in the per-shell SBP_TMP.
segments::1password_refresh() {
  local cache=$1
  local whoami state='signed_out' account=''

  if whoami="$(op whoami --format=json 2>/dev/null)"; then
    state='signed_in'
    if [[ $whoami =~ \"url\":[[:space:]]*\"(https://)?([^\".]+) ]]; then
      account="${BASH_REMATCH[2]}"
    fi
  fi

  printf '%s\n%s\n' "$state" "$account" >"${cache}.new"
  command mv "${cache}.new" "$cache"
}

segments::1password() {
  command -v op &>/dev/null || return 0

  local cache="${SBP_TMP}/1password"
  local icon="${SEGMENTS_1PASSWORD_ICON:-op}"
  local state account current_time checked=0

  if [[ -f $cache ]]; then
    {
      read -r state
      read -r account
    } <"$cache"

    if [[ $state == 'signed_in' ]]; then
      print_themed_segment 'normal' "$icon" ${account:+"$account"}
    else
      print_themed_segment 'highlight' "$icon" 'signed out'
    fi
  fi

  [[ -f ${cache}.checked ]] && read -r checked <"${cache}.checked"
  _sbp_get_current_time current_time

  if ((current_time - checked >= SEGMENTS_1PASSWORD_REFRESH_RATE)); then
    # Stamped before the refresh so that a slow op is not started again by the next prompt
    printf '%s\n' "$current_time" >"${cache}.checked"
    execute::execute_nohup_function segments::1password_refresh "$cache"
  fi
}
