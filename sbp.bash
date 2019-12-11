#! /usr/bin/env bash

#################################
#   Simple Bash Prompt (SBP)    #
#################################

export sbp_path
# shellcheck source=helpers/cli.bash
source "${sbp_path}/helpers/cli.bash"

_sbp_previous_history=

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

options_file=$(sbp extra_options)
if [[ -f "$options_file" ]]; then
  source "$options_file"
fi

#trap 'printf "\e[0n"' WINCH

function _sbp_set_prompt {
  local command_exit_code=$?
  [[ -n "$SBP_DEBUG" ]] && _sbp_timer_start
  local last_history command_started command_ended command_time
  last_history=$(HISTTIMEFORMAT='%s ' history 1)

  if [[ -z "$_sbp_previous_history" || "$last_history" == "$_sbp_previous_history" ]]; then
    command_exit_code=
    command_time=
  else
    command_ended=$(date +'%s')
    command_started=$(awk '{print $2}' <<< "$last_history")
    last_command=$(awk '{print $3}' <<< "$last_history")
    command_time=$(( command_ended - command_started ))
  fi

  _sbp_previous_history=$last_history
  unset last_history
  printf '\e]2;%s\007' "${PWD##*/}"

  PS1=$(bash "${sbp_path}/helpers/generator.bash" 'generate_prompt' "$COLUMNS" "$command_exit_code" "$command_time")
  [[ -n "$SBP_DEBUG" ]] &&_sbp_timer_tick "Done"
}

[[ "$PROMPT_COMMAND" =~ _sbp_set_prompt ]] || PROMPT_COMMAND="_sbp_set_prompt;$PROMPT_COMMAND"
