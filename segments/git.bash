#! /usr/bin/env bash

segment_direction=$3

path=${PWD}
is_git=false
while [[ $path ]]; do
  if [[ -d "${path}/.git" ]]; then
    is_git=true
    break
  fi
  path=${path%/*}
done

[[ "$is_git" == "false" ]] && exit 0

git_head=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
git_state=" $(git status --porcelain | sed -Ee 's/^(.M|M.|.R|R.) .*/\*/' -e 's/^(.A|A.) .*/\+/' -e 's/^(.D|D.) .*/\-/' | grep -oE '^(\*|\+|\?|\-)' | sort -u | tr -d '\n')"
git_left_right=$(git rev-list --count --left-right '@{upstream}'...HEAD 2> /dev/null)
git_left=$(sed -n -E 's/^([0-9]+).*[0-9]/\1/p' <<< "$git_left_right")
git_right=$(sed -n -E 's/^[0-9]+.*([0-9])/\1/p' <<< "$git_left_right")

if [[ "$git_left" -gt 0 ]]; then
  git_state="${git_state} <${git_left}"
fi
if [[ "$git_right" -gt 0 ]]; then
  git_state="${git_state} >${git_right}"
fi

if [[ $(( ${#git_head} + ${#git_state} )) -gt "$settings_git_max_length" ]]; then
  git_head_room=$(( settings_git_max_length - ${#git_state} - 2))
  git_head="${git_head:0:$git_head_room}.."
fi
segment_value=" ${git_head}${git_state} "
pretty_print_segment "$settings_git_color_fg" "$settings_git_color_bg" "${segment_value//  / }" "$segment_direction"
