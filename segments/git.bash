#! /usr/bin/env bash

segment_direction=$3
settings_git_max_length=$4

path=${PWD}
is_git=false
while [[ $path ]]; do
  if [[ -d "${path}/.git" ]]; then
    git_folder="${path}/.git"
    break
  fi
  path=${path%/*}
done

[[ -z "$git_folder" ]] && exit 0
type git &>/dev/null || exit 0

git_head=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

git_status="$(git status --porcelain 2>/dev/null)"
git_status_additions=$(grep -Ec '^[ ]?A' <<< "${git_status}")
git_status_modifications=$(grep -Ec '^[ ]?[MR]' <<< "${git_status}")
git_status_deletions=$(grep -Ec '^[ ]?D' <<< "${git_status}")
git_status_untracked=$(grep -Ec '^[ ]?\?' <<< "${git_status}")

if [[ "$git_status_additions" -gt 0 ]]; then
  git_state="${git_state}+${git_status_additions} "
fi

if [[ "$git_status_modifications" -gt 0 ]]; then
  git_state="${git_state}~${git_status_modifications} "
fi

if [[ "$git_status_deletions" -gt 0 ]]; then
  git_state="${git_state}-${git_status_deletions} "
fi

if [[ "$git_status_untracked" -gt 0 ]]; then
  git_state="${git_state}?${git_status_untracked} "
fi

if [[ $(( ${#git_head} + ${#git_state} )) -gt "$settings_git_max_length" ]]; then
  git_head="${git_head:0:10}.."
fi

git_state="${git_state} ${git_head}"

git_status_upstream="$(git rev-list --left-right "@{upstream}"...HEAD 2>/dev/null)"
git_incoming_commits="$(grep -c '<' <<< "${git_status_upstream}")"
git_outgoing_commits="$(grep -c '>' <<< "${git_status_upstream}")"

if [[ "$git_incoming_commits" -gt 0 ]]; then
  git_state="${git_state} ↓${git_incoming_commits}"
fi
if [[ "$git_outgoing_commits" -gt 0 ]]; then
  git_state="${git_state} ↑${git_outgoing_commits}"
fi

segment_value=" ${git_state} "
pretty_print_segment "$settings_git_color_fg" "$settings_git_color_bg" "${segment_value//  / }" "$segment_direction"
