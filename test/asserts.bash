#! /usr/bin/env bash

assert_equal() {
  if [[ $1 != "$2" ]]; then
    echo "expected: '$2'"
    echo "actual: '$1'"
    false
  fi
}
