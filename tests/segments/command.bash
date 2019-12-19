function test_that_we_get_the_right_spent_time() {
  local result
  result=$("${sbp_path}/segments/command.bash" 0 5)
  assert_equals " last: 0m 5s " "$result"
}

function test_that_we_get_a_failed_color() {
  local result color
  export settings_command_color_error_primary=32
  export settings_command_color_error_secondary=24
  result=$("${sbp_path}/segments/command.bash" 1 0)
  local colors="${settings_command_color_fg_error}${settings_command_color_bg_error}"
  assert_equals "${colors} last: 0m 0s " "$result"
}
