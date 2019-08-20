function pretty_print_segment() {
  printf '%s' "$3"
}

export -f pretty_print_segment

function test_that_we_detect_ssh() {
  export SSH_CLIENT=yes
  result=$("${sbp_path}/segments/host.bash" 0 0)
  assert_equals " ${USER}@${HOSTNAME} " "$result"
}
