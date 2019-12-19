# SBP - Simple Bash Prompt
[![Build Status](https://travis-ci.org/brujoand/sbp.svg?branch=master)](https://travis-ci.org/brujoand/sbp)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/brujoand/sbp/Bauta Unit Tests)

Simple Bash Prompt (SBP) is a bash prompt, which was simple once.
This started out as a pure ripoff from powerline-shell, which is great, but written in python.
SBP is all bash, which makes it fast and fun.

I've tried making the code as readable and extensible as possible.
If something seems wrong, lacking or bad in some way; feel free to rant, review and create a pull request.

![Screenshot](/resources/sbp_screenshot.png)

## Soft Requirements
If you want the fancy pointy segment separators, you need the powerline fonts _installed_ and _enabled_. Both.
You can get them [here](https://github.com/powerline/fonts).
Then run the install.sh script. Now the hard_to_remember part. Change the settings of your terminal emulator.
Something like "Settings" and then "Fonts" will probably be the right place.
All done?
Great :)

## Installing
There is an install script. It will copy the default
settings to `~/.config/sbp/settings.conf` along with the default color assignments
to `~/.config/sbp/colors.conf` and add two lines to your `$HOME/.bashrc`:
```
  sbp_path=/the/path/to/sbp
  source ${sbp_path}/sbp.bash
```

## Usage
So you're ready to go. Now you do nothing. Just use it. But you could. If you want. Change stuff up a bit.
Edit your config by running `sbp config` and run `sbp reload` if you changed
something substantial. Most changes will be effective immediately.
You can use the `sbp` command for a lot of things:
```
  sbp
  Usage: sbp [command]

  Commands:
  segments  - List all available segments
  hooks     - List all available hooks
  peekaboo  - Toggle visibility of [segment] or [hook]
  color     - Set [color] for the current session
  layout    - Set [layout] for the current session
  themes    - List all available color themes and layouts
  reload    - Reload SBP and user settings
  debug     - Toggle debug mode
  status    - Show the current configuration
  config    - Opens the config in $EDITOR
```

## Features
### Segments
Segments can be configured, moved, and hidden depending on your mood, or
environment. Read more about those and how to make your own in the [Segments
Folder](/segments).

### Hooks
Hooks let's you execute scripts asynchronously to either alert you, populate
data for segments or whatever you want really. Read more about those and how to
make your own in the [Hooks Folder](/hooks).

### Themes
Themes let you decide how the prompt is drawn, both in terms of layout and the
colors used. Read more about those and how to make your own in the [Themes
Folder](/themes).
