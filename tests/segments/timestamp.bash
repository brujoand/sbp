function test_that_we_get_the_right_time() {
  local result timestamp
  timestamp=$(date +'%H:%M:%S')
  export settings_timestamp_format="%H:%M:%S"
  result=$("${sbp_path}/segments/timestamp.bash" 0 "$(date +'%s')")
  assert_equals " $timestamp " "$result"
}
