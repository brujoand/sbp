#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################

export SBP_PATH
# shellcheck source=functions/interact.bash
source "${SBP_PATH}/functions/interact.bash"

if [[ -d "/run/user/${UID}" ]]; then
  _SBP_CACHE=$(mktemp -d --tmpdir="/run/user/${UID}") && trap 'rm -rf "$tempdir"' EXIT;
else
  _SBP_CACHE=$(mktemp -d) && trap 'rm -rf "$tempdir"' EXIT;
fi

export _SBP_CACHE

if [[ "$OSTYPE" == "darwin"* ]]; then
  export date_cmd='gdate'
else
  export date_cmd='date'
fi

_sbp_timer_start() {
  timer_start=$("$date_cmd" +'%s%3N')
}

_sbp_timer_tick() {
  timer_stop=$("$date_cmd" +'%s%3N')
  timer_spent=$(( timer_stop - timer_start))
  >&2 echo "${timer_spent}ms: $1"
  timer_start=$("$date_cmd" +'%s%3N')
}

options_file=$(sbp extra_options)
if [[ -f "$options_file" ]]; then
  source "$options_file"
fi

_sbp_set_prompt() {
  local command_status=$?
  local command_status current_time command_start command_duration
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_start
  current_time=$(date +%s)
  if [[ -f "${_SBP_CACHE}/execution" ]]; then
    command_start=$(< "${_SBP_CACHE}/execution")
    command_duration=$(( current_time - command_start ))
    rm "${_SBP_CACHE}/execution"
  else
    command_duration=0
  fi

  # TODO move this somewhere else
  title="${PWD##*/}"
  if [[ -n "$SSH_CLIENT" ]]; then
    title="${HOSTNAME:-ssh}:${title}"
  fi
  printf '\e]2;%s\007' "$title"

  PS1=$(bash "${SBP_PATH}/functions/main.bash" "$command_status" "$command_duration")
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_tick "Done"

}

_sbp_pre_exec() {
  date +%s > "${_SBP_CACHE}/execution"
}

PS0="\$(_sbp_pre_exec)"

[[ "$PROMPT_COMMAND" =~ _sbp_set_prompt ]] || PROMPT_COMMAND="_sbp_set_prompt;$PROMPT_COMMAND"
