# Hooks

Hooks are executed asynchronously and are meant to provide a way of either
alerting the user, or running other non segment related tasks.

## Creating your own hooks
You can create your own hooks by placing a file in:
```
   ${HOME}/.config/sbp/hooks/${your_hooks_name}.bash
```

You'll also want to add your hooks in the ´SBP_HOOKS´ variable, in the settings.

Your script will be sourced and executed with the following env variables:
```
  - COMMAND_EXIT_CODE, the exit code of the privous shell command
  - COMMAND_DURATION, the duration of the shell command
  - SBP_TMP, a tmp folder which is local to your shell PID and cleaned upon exit
  - SBP_CACHE, a cache folder which is global to all SBP processes
  - SBP_PATH, the path to the SBP diectory
```

These are the provided hooks:
- Alert; Creates a notification if the previous command took longer than x
seconds.
