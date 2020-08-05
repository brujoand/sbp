#!/usr/bin/env bash

location=${SETTINGS_WTTR_LOCATION:-'Oslo'}
format=${SETTINGS_WTTR_FORMAT:-'%p;%t;%w'}
refresh_rate="${SEGMENTS_WTTR_REFRESH_RATE:-600}"

segments::wttr_refresh() {
  if [[ ! -f $SEGMENT_CACHE ]]; then
    debug::log "No cache folder"
  fi

  if [[ -f $SEGMENT_CACHE ]]; then
    last_update=$(stat -f "%m" "$SEGMENT_CACHE")
  else
    last_update=0
  fi

  current_time=$(date +%s)
  time_since_update=$((current_time - last_update))

  if [[ $time_since_update -lt $refresh_rate ]]; then
    return 0
  fi

  weather_data="$(curl -H "Accept-Language: ${LANG%_*}" --compressed "wttr.in/${location}?format=${format}" | tr -d '\n' | tr ';' '\n')"
  if [[ -n $weather_data ]]; then
    echo "$weather_data" >"$SEGMENT_CACHE"
  fi
}

segments::wttr() {
  if [[ -f $SEGMENT_CACHE ]]; then
    mapfile -t result <"$SEGMENT_CACHE"
    print_themed_segment 'normal' "${result[@]}"
  fi
  execute::execute_nohup_function segments::wttr_refresh
}
