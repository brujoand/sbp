# Hooks

Hooks are executed asynchronously and are meant to provide a way of either
alerting the user, or fetching data from APIs to be used by segments. See the
[rescuetime.bash](/rescuetime.bash) script for en example.

## Creating your own hooks
You can create your own hooks by placing a file in:
```
   ${HOME}/.config/sbp/hooks/${your_hooks_name}.bash
```

Your script will be executed with 2 arguments:
```
  1: The exit code of the previous shell command
  2: The execution time of the previous command
```
Your hook should also be executable

These are the provided hooks:
- Alert; Creates a notification if the previous command took longer than x
seconds.
- rescuetime: Fetches the rescuetime stats for your account, given that the
`RESCUETIME_API_KEY` is defined in your environment.
