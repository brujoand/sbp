# Segments

Segments are the parts that make up the prompt. They can be added and removed in
any order. They are executed asynchronously so they cannot be dependent on other
segments.

## Creating your own segments
You can create your own segments by placing a file in:
```
   ${HOME}/.config/sbp/segments/${your_segment_name}.bash
```

This script should contain at least a function called
`segments::${your_segment_name}` and it will have the following variables
available:
```
  - COMMAND_EXIT_CODE, the exit code of the privous shell command
  - COMMAND_DURATION, the duration of the shell command
  - SBP_TMP, a tmp folder which is local to your shell PID and cleaned upon exit
  - SBP_CACHE, a cache folder which is global to all SBP processes
  - SBP_PATH, the path to the SBP diectory
```

When you have defined the parts you want to use in your segment you need to
theme the parts by issuing the following command:
```
  print_themed_segment 'normal/higlight' "${segment_pars[@]}"
```

- aws; Shows the current active aws profile
- command; shows the time spent on the last command, and turns red if it failed
- exit_code; shows the value of the last exitcode
- git; shows the git branch and current status
- host; shows the ${USER} and maybe ${HOSTNAME} depending on your settings
- k8s; shows the current user/cluster/project
- path; shows the path
- path_ro; shows a if current path is read only
- prompt_ready; Shows a simple character before the end of the prompt
- python_env; shows the virtual env settings for current folder
- rescuetime: Shows Productivity score and logged time for the day. Requires the rescuetime hook to be enabled.
- timestamp; shows a timestamp
