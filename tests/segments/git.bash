TMP_FOLDER="/tmp/bauta.$RANDOM"

function setup() {
  mkdir -p "$TMP_FOLDER"
  cd "$TMP_FOLDER" || exit 1
  git init
  touch test
  git add test
  git config user.email "you@example.com"
  git config user.name "Your Name"
  git commit -am "Testing"
}

function cleanup() {
  rm -rf $TMP_FOLDER
}

function test_that_we_get_master_branch() {
  result=$("${sbp_path}/segments/git.bash" 0 0 '' 50)
  assert_equals '  master ' "$result"
}

function test_that_we_see_dirty_dir() {
  touch "${TMP_FOLDER}/dirty"
  result=$("${sbp_path}/segments/git.bash" 0 0 '' 50)
  assert_equals ' ?1 master ' "$result"
}
