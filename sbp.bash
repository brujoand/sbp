#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################

# Check the Bash version.
if [ -z "${BASH_VERSION-}" ]; then
  printf 'sbp: This is not a Bash session. Bash 4.3 or higher is required by sbp.\n' >&2
  return 1 2>/dev/null
elif [ -z "${BASH_VERSINFO-}" ] || ((BASH_VERSINFO[0] < 4 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3)); then
  printf 'sbp: This is Bash %s. Bash 4.3 or higher is required by sbp.\n' "$BASH_VERSION" >&2
  return 1 2>/dev/null
fi

# Do not set up prompts when it is not an interactive session.
if [[ $- != *i* ]] && ! return 0 2>/dev/null; then
  printf 'sbp: This is not an interactive session of Bash.\n' >&2
  exit 1
fi

# shellcheck source=src/interact.bash
source "${SBP_PATH}/src/interact.bash"
# shellcheck source=src/debug.bash
source "${SBP_PATH}/src/debug.bash"

if [[ -w "/run/user/${UID}" ]]; then
  SBP_TMP=$(mktemp -d --tmpdir="/run/user/${UID}") && trap 'command rm -rf "$SBP_TMP"' EXIT
else
  SBP_TMP=$(mktemp -d) && trap 'command rm -rf "$SBP_TMP"' EXIT
fi

export SBP_TMP
export SBP_PATH
export COLUMNS

_sbp_get_current_time() {
  if [[ ${EPOCHSECONDS-} ]]; then
    printf -v "$1" %s "$EPOCHSECONDS"
  else
    printf -v "$1" '%(%s)T' -1
  fi
}
export -f _sbp_get_current_time

_sbp_set_prompt() {
  local command_status=$?
  local command_status current_time command_start command_duration
  [[ -n ${SBP_DEBUG-} ]] && debug::start_timer
  _sbp_get_current_time current_time
  if [[ -f "${SBP_TMP}/execution" ]]; then
    command_start=$(<"${SBP_TMP}/execution")
    command_duration=$((current_time - command_start))
    command rm "${SBP_TMP}/execution"
  else
    command_duration=0
    command_status=0
  fi

  # TODO move this somewhere else
  title="${PWD##*/}"
  if [[ -n $SSH_CLIENT ]]; then
    title="${HOSTNAME:-ssh}:${title}"
  fi
  printf '\e]2;%s\007' "$title"

  # gitstatus.plugin.sh requires an interactive shell
  PS1=$(HISTFILE=/dev/null bash --noediting --noprofile --norc "${SBP_PATH}/src/main.bash" "$command_status" "$command_duration" "$GITSTATUS_DIR" "$GITSTATUS_DAEMON_PID" "$_GITSTATUS_REQ_FD" "$_GITSTATUS_RESP_FD")
  [[ -n ${SBP_DEBUG-} ]] && debug::tick_timer "Done"
}

_sbp_pre_exec() {
  local time
  _sbp_get_current_time time
  echo "$time" >"${SBP_TMP}/execution"
}

# shellcheck disable=SC2034,SC2016
PS0='$(_sbp_pre_exec)'

[[ $PROMPT_COMMAND =~ _sbp_set_prompt ]] || PROMPT_COMMAND="_sbp_set_prompt${PROMPT_COMMAND:+;}$PROMPT_COMMAND"
SBP_SOURCED=1
