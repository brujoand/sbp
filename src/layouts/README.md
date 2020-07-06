# Layouts

Layouts are the last step to handle the segments before they are concatenated
into the PS1 prompt variable.

Layouts will receive a ´segment_type´ as the first argument, this can be:
  - normal; a regular segment
  - highlight; a segment that will use the highlighted colors
  - filler; The segment separating left from right side of the prompt
  - prompt_ready; The segment printed immediately before the cursor

Each layout is responsible for applying colors, spacing and other formatting
and it should be completely detached from the main logic so a layout change
should never break a working prompt.

## Creating your own layout
You can create your own hooks by placing a file in:
```
   ${HOME}/.config/sbp/layouts/${your_layouts_name}.bash
```

Your script will be sourced and executed with the following env variables:
```
  - PRIMARY_COLOR
  - SECONDARY_COLOR
  - PRIMARY_COLOR_HIGHLIGHT
  - SECONDARY_COLOR_HIGHLIGHT
  - SPLITTER_COLOR
```
