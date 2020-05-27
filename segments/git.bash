#! /usr/bin/env bash

segment_generate_git() {
  local segment_max_length=$3

  local incoming_icon="$settings_git_incoming_icon"
  local outgoing_icon="$settings_git_outgoing_icon"

  local path=${PWD}
  while [[ $path ]]; do
    if [[ -d "${path}/.git" ]]; then
      local git_folder="${path}/.git"
      break
    fi
    path=${path%/*}
  done

  [[ -z "$git_folder" ]] && exit 0
  type git &>/dev/null || exit 0

  local git_status="$(git status --porcelain --branch 2>/dev/null)"

  local additions=0
  local modifications=0
  local deletions=0
  local untracked=0

  while read -r line; do
    local compacted=${line// }
    local action=${compacted:0:1}
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
          outgoing_filled="${upstream_stripped/ahead / ${outgoing_icon}}"
          upstream_status="${outgoing_filled/behind / ${incoming_icon}}"
        fi
    esac
  done <<< "$git_status"

  local git_state="${additions_icon}${additions/#0/}${modifications_icon}${modifications/#0/}${deletions_icon}${deletions/#0/}${untracked_icon}${untracked/#0/}"

  # git status does not support detached head
  if [[ "$branch" != 'HEAD' ]]; then
    git_head="$branch"
  else
    git_head=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  fi

  git_size=$(( ${#git_state} + ${#settings_git_icon} + ${#git_head} + ${#upstream_status} ))

  if [[ "$git_size" -gt "$segment_max_length" ]]; then
    available_space=$(( segment_max_length - ${#git_state} - ${#settings_git_icon} + ${#upstream_status} ))
    if [[ "$available_space" -gt 0 ]]; then
      git_head="${git_head:0:$available_space}.."
    else
      git_head=""
    fi
  fi

  segment_value="${git_state/ /}${settings_git_icon}${git_head}${upstream_status}"

  printf '%s' "$segment_value"
}
