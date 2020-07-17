#!/usr/bin/env bats

load segment_helper

execute::execute_nohup_function() {
  "$@"
}

segments::wttr_fetch_changes() {
  echo -e '0.1mm\n+16°C\n↓13km/h'
}

@test "test parsing the wttr segment" {
  SEGMENT_CACHE="${TMP_DIR}/wttr"
  stats="$(segments::wttr_fetch_changes)"
  echo "$stats" > "$SEGMENT_CACHE"
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 4
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "0.1mm"
  assert_equal "${result[2]}" "+16°C"
  assert_equal "${result[3]}" "↓13km/h"
}

@test "test refreshing the wttr segment" {
  SEGMENT_CACHE="${TMP_DIR}/wttr"
  command rm -rf "$SEGMENT_CACHE"
  execute_segment
  [[ -f "$SEGMENT_CACHE" ]]

}
