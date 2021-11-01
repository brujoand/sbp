#! /usr/bin/env bash

segments::nix() {
  # lorri also sets IN_NIX_SHELL but a real nix-shell sets bunch more variables we can use to differentiate the two
  # and only display the segment when we are in a real nix-shell which opens a nested bash which can be closed
  if [[ -n $IN_NIX_SHELL && -v name && -v system ]]; then
    print_themed_segment 'normal' "nix-shell"
  fi
}
