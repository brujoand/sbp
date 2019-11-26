#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################
_sbp_previous_history_id=
export sbp_path
#shellcheck source=helpers/cli.bash
source "${sbp_path}/helpers/cli.bash"

if [[ "$OSTYPE" == "darwin"* ]]; then
  export date_cmd='gdate'
else
  export date_cmd='date'
fi

function _sbp_timer_start() {
  timer_start=$("$date_cmd" +'%s%3N')
}

function _sbp_timer_tick() {
  timer_stop=$("$date_cmd" +'%s%3N')
  timer_spent=$(( timer_stop - timer_start))
  >&2 echo "${timer_spent}ms: $1"
  timer_start=$("$date_cmd" +'%s%3N')
}

export -f _sbp_timer_start
export -f _sbp_timer_tick

function _sbp_set_prompt {
  local command_exit_code=$?
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_start
  local last_history command_started command_ended command_time last_history_id
  last_history=$(HISTTIMEFORMAT='%s ' history 1)

  if [[ -z "$_sbp_previous_history_id" || "$_sbp_previous_history_id" -eq "$last_history_id" ]]; then
    command_exit_code=-1
    command_time=-1
  else
    command_ended=$(date +'%s')
    command_started=$(cut -d ' ' -f 4 <<< "$last_history")
    command_time=$(( command_ended - command_started ))
    last_history_id=$(cut -d ' ' -f 2 <<< "$last_history")
  fi
  unset last_history

  _sbp_previous_history_id=$last_history_id

  PS1=$(bash "${sbp_path}/helpers/prompt.bash" "$COLUMNS" "$command_exit_code" "$command_time")
  [[ -n "$SBP_DEBUG" ]] &&_sbp_timer_tick "Done"
}

[[ "$PROMPT_COMMAND" =~ _sbp_set_prompt ]] || export PROMPT_COMMAND="_sbp_set_prompt;$PROMPT_COMMAND"
