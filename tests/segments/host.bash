function pretty_print_segment() {
  printf '%s' "${@}"
}

export -f pretty_print_segment

function test_we_get_the_user_right() {
  result=$("${sbp_path}/segments/host.bash" 0 0)
  assert_equals " $USER " "$result"
}

function test_that_we_detect_ssh() {
  export SSH_CLIENT=yes
  result=$("${sbp_path}/segments/host.bash" 0 0)
  assert_equals " ${USER}@${HOSTNAME} " "$result"
}
