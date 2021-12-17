#! /usr/bin/env bash

segments::direnv() {
  if [[ -v DIRENV_DIR ]]; then
    print_themed_segment 'normal' "direnv"
  fi
}
