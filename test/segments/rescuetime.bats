#!/usr/bin/env bats

load segment_helper

RESCUETIME_API_KEY=password

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
  SEGMENT_CACHE="${TMP_DIR}/rescuetime"
  stats='77%;3h:20m'
  echo "$stats" > "$SEGMENT_CACHE"
  mapfile -t result <<< "$(execute_segment)"

  assert_equal "${#result[@]}" 3
  assert_equal "${result[0]}" 'normal'
  assert_equal "${result[1]}" "77%"
  assert_equal "${result[2]}" "3h:20m"
}

@test "test a refreshing the rescuetime segment" {
  SEGMENT_CACHE="${TMP_DIR}/rescuetime"
  command rm -rf "$SEGMENT_CACHE"
  RESCUETIME_ENDPOINT="http://localhost:8080"

  execute_segment
  [[ -f "$SEGMENT_CACHE" ]]

}
