#! /usr/bin/env bash

segments::conda() {
  if [[ -n $CONDA_DEFAULT_ENV ]]; then
    print_themed_segment 'normal' "$CONDA_DEFAULT_ENV"
  fi
}
