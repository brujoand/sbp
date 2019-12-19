# Segments

Segments are the parts that make up the prompt. They can be added and removed in
any order. They are executed asynchronously so they cannot be dependent on other
segments.

## Creating your own segments
You can create your own segments by placing a file in:
```
   ${HOME}/.config/sbp/segments/${your_segment_name}.bash
```

Your script will be executed with 4 arguments:
```
  1: The exit code of the previous shell command
  2: The execution time of the previous command
  3: The direction of the current segment (to be passed to the print function)
  4: The maximum length that your segment needs to abide by
```

When you have defined the text you want to use in your segment you need to print
it by issuing the following command:
```
  pretty_print_segment "$segment_color_primary" "$segment_color_secondary" "${segment_value}" "$segment_direction"
```

Your segment should also be executable

- aws; Shows the current active aws profile
- command; shows the time spent on the last command, and turns red if it failed
- exit_code; shows the value of the last exitcode
- git; shows the git branch and current status
- host; shows the ${USER} and maybe ${HOSTNAME} depending on your settings
- openshift; shows the current user/cluster/project
- path; shows the path
- path_ro; shows a if current path is read only
- prompt_ready; Shows a simple character before the end of the prompt
- python_env; shows the virtual env settings for current folder
- rescuetime: Shows Productivity score and logged time for the day. Requires the rescuetime hook to be enabled.
- timestamp; shows a timestamp
