#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################

export sbp_path
# shellcheck source=functions/log.bash
source "${sbp_path}/functions/log.bash"
# shellcheck source=functions/interact.bash
source "${sbp_path}/functions/interact.bash"

_sbp_previous_history=

if [[ "$OSTYPE" == "darwin"* ]]; then
  export date_cmd='gdate'
else
  export date_cmd='date'
fi

SHELL_BIRTH=$(( $(date +'%s') - SECONDS ))
export SHELL_BIRTH

_sbp_timer_start() {
  timer_start=$("$date_cmd" +'%s%3N')
}

_sbp_timer_tick() {
  timer_stop=$("$date_cmd" +'%s%3N')
  timer_spent=$(( timer_stop - timer_start))
  >&2 echo "${timer_spent}ms: $1"
  timer_start=$("$date_cmd" +'%s%3N')
}

export -f _sbp_timer_start
export -f _sbp_timer_tick

options_file=$(sbp extra_options)
if [[ -f "$options_file" ]]; then
  source "$options_file"
fi

#trap 'printf "\e[0n"' WINCH

_sbp_set_prompt() {
  local command_exit_code=$?
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_start
  local last_history command_started command_ended command_time
  last_history=$(HISTTIMEFORMAT='%s ' history 1)
  last_history=${last_history##*  }

  if [[ -z "$_sbp_previous_history" || "$last_history" == "$_sbp_previous_history" ]]; then
    command_exit_code=
    command_time=
  else
    command_ended=$(( SHELL_BIRTH + SECONDS ))
    command_started=${last_history/ *}
    command_time=$(( command_ended - command_started ))
  fi

  _sbp_previous_history=$last_history
  unset last_history

  title="${PWD##*/}"

  # TODO move this somewhere else
  if [[ -n "$SSH_CLIENT" ]]; then
    title="${HOSTNAME:-ssh}:${title}"
  fi
  printf '\e]2;%s\007' "$title"

  PS1=$(bash "${sbp_path}/functions/generate.bash" "$COLUMNS" "$command_exit_code" "$command_time")
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_tick "Done"
}

[[ "$PROMPT_COMMAND" =~ _sbp_set_prompt ]] || PROMPT_COMMAND="_sbp_set_prompt;$PROMPT_COMMAND"
