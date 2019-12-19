function test_that_we_detect_ssh() {
  export SSH_CLIENT=yes
  result=$("${sbp_path}/segments/host.bash" 0 0)
  assert_equals " ${USER}@${HOSTNAME} " "$result"
}
