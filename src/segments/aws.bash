#! /usr/bin/env bash

segments::aws() {
  if [[ -n "$AWS_DEFAULT_PROFILE" ]]; then
    print_themed_segment 'normal' "$AWS_DEFAULT_PROFILE"
  fi
}
