#! /usr/bin/env bash

refresh_rate="${settings_rescuetime_refresh_rate:-600}"
if [[ -z "$cache_folder" ]]; then
  log_error "No cache folder"
fi
cache_file="${cache_folder}/rescuetime.csv"

if [[ -f "$cache_file" ]]; then
  last_update=$(stat -f "%m" "$cache_file")
else
  last_update=0
fi

current_time=$(date +%s)
time_since_update=$(( current_time - last_update ))

if [[ "$time_since_update" -lt "$refresh_rate" ]]; then
  exit 0
fi

if [[ -z $RESCUETIME_API_KEY ]]; then
  log_error "RESCUETIME_API_KEY not set"
  exit 0
fi

endpoint="https://www.rescuetime.com/anapi/data?key=$RESCUETIME_API_KEY&format=csv&rs=day&rk=productivity"
result=$(curl -s "$endpoint" | grep -v '^Rank')
exit_code=$?
if [[ "$exit_code" -gt 0 ]]; then
  log_error "Could not reach rescuetime endpoint"
  exit 0
fi

if [[ -z "$result" ]]; then
  # No data, so no logging of time today
  rm -f "$cache_file"
  exit 0
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

printf '%s;%s' "$pulse" "$time" > "$cache_file"
