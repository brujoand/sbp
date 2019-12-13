#! /usr/bin/env bash

segment_direction=$3
settings_git_max_length=$4

incoming_icon="$settings_git_incoming_icon"
outgoing_icon="$settings_git_outgoing_icon"

path=${PWD}
while [[ $path ]]; do
  if [[ -d "${path}/.git" ]]; then
    git_folder="${path}/.git"
    break
  fi
  path=${path%/*}
done

[[ -z "$git_folder" ]] && exit 0
type git &>/dev/null || exit 0


git_status="$(git status --porcelain --branch 2>/dev/null)"

additions=0
modifications=0
deletions=0
untracked=0

while read -r line; do
  compacted=${line// }
  action=${compacted:0:1}
  case $action in
    A)
      additions_icon=' +'
      additions=$(( additions + 1 ))
      ;;
    M|R)
      modifications_icon=' ~'
      modifications=$(( modifications + 1 ))
      ;;
    D)
      deletions_icon=' -'
      deletions=$(( deletions + 1 ))
      ;;
    \?)
      untracked_icon=' ?'
      untracked=$(( untracked + 1 ))
      ;;
    \#)
      branch_line=${line/\#\# /}
      branch_data=${branch_line/% *}
      branch="${branch_data/...*/}"
      upstream_data="${branch_line#* }"
      upstream_stripped="${upstream_data//[\[|\]]}"
      if [[ "$upstream_data" != "$upstream_stripped" ]]; then
        outgoing_filled="${upstream_stripped/ahead /${outgoing_icon}}"
        upstream_status="${outgoing_filled/behind /${incoming_icon}}"
      fi
  esac
done <<< "$git_status"

git_state="${additions_icon}${additions/#0/}${modifications_icon}${modifications/#0/}${deletions_icon}${deletions/#0/}${untracked_icon}${untracked/#0/}"

# git status does not support detached head
if [[ "$branch" != 'HEAD' ]]; then
  git_head="$branch"
else
  git_head=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
fi

if [[ $(( ${#git_head} + ${#git_state} )) -gt "$settings_git_max_length" ]]; then
  git_head="${git_head:0:10}.."
fi

git_state="${git_state} ${settings_git_icon} ${git_head}"

git_state="${git_state} ${upstream_status}"


segment_value=" ${git_state} "
pretty_print_segment "$settings_git_color_fg" "$settings_git_color_bg" "${segment_value//  / }" "$segment_direction"
