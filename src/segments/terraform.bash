#! /usr/bin/env bash

tf_icon="${SEGMENTS_TF_ICON:-}"
tf_extenstion="${TF_FILE_EXTENCION:-tf}"
scanned_dirs="${SEGMENTS_TF_SCANNED_DIRS:-$PWD}"
declare tf_version=

_get_terraform_version() {
  # when version managers are available, parse their
  # config files first before calling 'terraform version'

  # check for version files created by 'tfenv'
  if [[ -n $(command -v tfenv) ]] && [[ -f $PWD/.terraform-version ]]; then
    tf_version="$(tr -d '\n' <.terraform-version)"

  # check for version files created by 'asdf'
  elif [[ $(command -v asdf) ]] && [[ -f $PWD/.tool-versions ]] && [[ "$(<.tool-versions)" =~ terraform.([0-9.]+) ]]; then
    tf_version="${BASH_REMATCH[1]}"

  # get version from terraform directly (slowest)
  elif [[ -n $(command -v terraform) ]] && [[ "$(terraform -v)" =~ v([0-9.]+) ]]; then
    tf_version="${BASH_REMATCH[1]}"
  fi
}

segments::terraform() {
  if [[ -n $(find "$scanned_dirs" -maxdepth 1 -name "*.${tf_extenstion}" -print -quit 2>/dev/null) ]]; then
    _get_terraform_version
    segment="$tf_icon $tf_version"
    print_themed_segment 'normal' "$segment"
  fi
}
