#! /usr/bin/env bash

segments::nix() {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    print_themed_segment 'normal' "nix-shell"
  fi
}
