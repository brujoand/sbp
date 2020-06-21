#!/usr/bin/env bats

load segment_helper

execute::execute_nohup_function() {
  "$@"
}

segments::rescuetime_fetch_changes() {
  cat << EOF
1,6658,1,0
2,6503,1,2
3,81,1,1
4,15,1,-2
EOF
}

@test "test parsing the rescuetime segment" {
  SBP_CACHE="$TMP_DIR"
  RESCUETIME_CACHE="${TMP_DIR}/rescuetime.csv"
  stats='77%;3h:20m'
  echo "$stats" > "$RESCUETIME_CACHE"
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "77%"
  assert_equal "${result[2]}" "3h:20m"
}

@test "test a refreshing the rescuetime segment" {
  SBP_CACHE="$TMP_DIR"
  RESCUETIME_CACHE="${TMP_DIR}/rescuetime.csv"
  RESCUETIME_ENDPOINT="http://localhost:8080"

  execute_segment
  cat "$RESCUETIME_CACHE"
}
