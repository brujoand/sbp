#! /usr/bin/env bash

if [[ ${SEGMENTS_USE_NERDFONTS} == 1 ]]; then
  # use Terraform icon from Nerdfonts
  tf_icon=""
else
  tf_icon="${SEGMENTS_TF_ICON:-⊤}"
fi

tf_extension="${TF_FILE_EXTENSION:-tf}"
declare tf_version=""
declare -a scanned_dirs=()

# To configure more than one dir to be scanned
# an array is necessary so we get values expanded
# to real arguments when calling find later
if [[ -n ${SEGMENTS_TF_SCANNED_DIRS} ]]; then
  scanned_dirs=("${SEGMENTS_TF_SCANNED_DIRS[@]}")
else
  scanned_dirs=("$PWD")
fi

_tf_available() {
  command -v terraform
}

_get_terraform_version() {
  # when version managers are available, parse their
  # config files first before calling 'terraform version'

  # check for version files created by 'tfenv'
  if [[ $(command -v tfenv) ]] && [[ -f $PWD/.terraform-version ]]; then
    tf_version="$(tr -d '\n' <.terraform-version)"

  # check for version files created by 'asdf'
  elif [[ $(command -v asdf) ]] && [[ -f $PWD/.tool-versions ]] && [[ "$(<.tool-versions)" =~ terraform.([0-9.]+) ]]; then
    tf_version="${BASH_REMATCH[1]}"

  # get version from terraform directly (slowest)
  elif [[ $(_tf_available) ]] && [[ "$(terraform -v)" =~ v([0-9.]+) ]]; then
    tf_version="${BASH_REMATCH[1]}"
  fi
}

segments::terraform() {
  if [[ $(_tf_available) ]] && [[ -n $(find "${scanned_dirs[@]}" -maxdepth 1 -name "*.${tf_extension}" -print -quit 2>/dev/null) ]]; then
    _get_terraform_version
    segment="$tf_icon $tf_version"
    print_themed_segment 'normal' "$segment"
  fi
}
