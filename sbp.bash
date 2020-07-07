#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################

# shellcheck source=src/interact.bash
source "${SBP_PATH}/src/interact.bash"
# shellcheck source=src/debug.bash
source "${SBP_PATH}/src/debug.bash"

# For catching legacy installs
if [[ -z "$SBP_PATH" && -n "$sbp_path" ]]; then
  debug::alert_user "Unfortunatly your current configuration is incompatible with the latest version of SBP"
  debug::alert_user "Two changes are required:"
  debug::alert_user "1. Please backup and remove your configuration ${HOME}/.config/sbp"
  debug::alert_user "2. Please change the casing of the 'sbp_path' variable to 'SBP_PATH' in your '$HOME/.bashrc'"
  debug::alert_user "In the mean time, your prompt has ben set to '\h@\h:\w'"
  PS1='\u@\h:\w '
  return 1
fi

if [[ -d "/run/user/${UID}" ]]; then
  SBP_TMP=$(mktemp -d --tmpdir="/run/user/${UID}") && trap 'rm -rf "$SBP_TMP"' EXIT;
else
  SBP_TMP=$(mktemp -d) && trap 'rm -rf "$SBP_TMP"' EXIT;
fi

export SBP_TMP
export SBP_PATH
export COLUMNS

_sbp_set_prompt() {
  local command_status=$?
  local command_status current_time command_start command_duration
  [[ -n "$SBP_DEBUG" ]] && debug::start_timer
  current_time=$(date +%s)
  if [[ -f "${SBP_TMP}/execution" ]]; then
    command_start=$(< "${SBP_TMP}/execution")
    command_duration=$(( current_time - command_start ))
    rm "${SBP_TMP}/execution"
  else
    command_duration=0
    command_status=0
  fi

  # TODO move this somewhere else
  title="${PWD##*/}"
  if [[ -n "$SSH_CLIENT" ]]; then
    title="${HOSTNAME:-ssh}:${title}"
  fi
  printf '\e]2;%s\007' "$title"

  PS1=$(bash "${SBP_PATH}/src/main.bash" "$command_status" "$command_duration")
  [[ -n "$SBP_DEBUG" ]] && debug::tick_timer "Done"

}

_sbp_pre_exec() {
  date +%s > "${SBP_TMP}/execution"
}

# shellcheck disable=SC2034
PS0="\[\$(_sbp_pre_exec)\]"

[[ "$PROMPT_COMMAND" =~ _sbp_set_prompt ]] || PROMPT_COMMAND="_sbp_set_prompt;$PROMPT_COMMAND"
