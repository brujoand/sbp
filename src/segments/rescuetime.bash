#!/usr/bin/env bash

RESCUETIME_CACHE="${SBP_CACHE}/rescuetime.csv"
RESCUETIME_ENDPOINT="https://www.rescuetime.com/anapi/data?key=${RESCUETIME_API_KEY}&format=csv&rs=day&rk=productivity"

segment::rescuetime_fetch_changes() {
  result=$(curl -s "$RESCUETIME_ENDPOINT" | grep -v '^Rank')
  exit_code=$?
  if [[ "$exit_code" -gt 0 ]]; then
    debug::log_error "Could not reach rescuetime RESCUETIME_ENDPOINT"
    return 0
  fi
  echo "$result"
}

segments::rescuetime_refresh() {
  refresh_rate="${SETTINGS_RESCUETIME_REFRESH_RATE:-600}"
  if [[ -z "$SBP_CACHE" ]]; then
    debug::log_error "No cache folder"
  fi
  RESCUETIME_CACHE="${SBP_CACHE}/rescuetime.csv"

  if [[ -f "$RESCUETIME_CACHE" ]]; then
    last_update=$(stat -f "%m" "$RESCUETIME_CACHE")
  else
    last_update=0
  fi

  current_time=$(date +%s)
  time_since_update=$(( current_time - last_update ))

  if [[ "$time_since_update" -lt "$refresh_rate" ]]; then
    return 0
  fi

  if [[ -z $RESCUETIME_API_KEY ]]; then
    debug::log_error "RESCUETIME_API_KEY not set"
    return 1
  fi

  result="$(segments::rescuetime_fetch_changes)"

  if [[ -z "$result" ]]; then
    # No data, so no logging of time today
    rm -f "$RESCUETIME_CACHE"
    return 0
  fi

  for line in $result ; do
    seconds=$(cut -d ',' -f 2 <<<"$line")
    total_seconds=$(( seconds + total_seconds ))
    value=$(cut -d ',' -f 4 <<<"$line")

    productivity_value=$(( value + 2 ))
    score=$(( seconds * productivity_value ))
    productive_score=$(( score + productive_score ))
  done


  max_score=$(( total_seconds * 4 ))
  pulse="$(( productive_score  * 100 / max_score ))%"
  hours=$(( total_seconds / 60 / 60 ))
  hour_seconds=$(( hours * 60 * 60 ))
  remaining_seconds=$(( total_seconds - hour_seconds ))
  minutes=$(( remaining_seconds / 60 ))
  time="${hours}h:${minutes}m"

  printf '%s;%s' "$pulse" "$time" > "$RESCUETIME_CACHE"
}


segments::rescuetime() {
  if [[ -f "$RESCUETIME_CACHE" ]]; then
    read -r cache < "$RESCUETIME_CACHE"
    pulse="${cache/;*}"
    time="${cache/*;}"
    print_themed_segment 'normal' "$pulse" "$time"
  fi
  execute::execute_nohup_function segments::rescuetime_refresh
}
