# SBP - Simple Bash Prompt
[![Build Status](https://travis-ci.org/brujoand/sbp.svg?branch=master)](https://travis-ci.org/brujoand/sbp)

Simple Bash Prompt (SBP) is a bash prompt, which was simple once.
This started out as a pure ripoff from powerline-shell, which is great, but written in python.
SBP is all bash, which makes it fast and fun.

I've tried making the code as readable and extensible as possible.
If something seems wrong, lacking or bad in some way; feel free to rant, review and create a pull request.

![Screenshot](/resources/sbp_screenshot.png)

For a live demo of this magic [head over
here](https://asciinema.org/a/0efgJrqQJY2vH1XguXjX3xV1c)

## A note on the recent changes
I wanted to add support for trueculors instead of relying on "just" 256 colors.
To do this I had to break the configuration, and when the flood gates had been
opened, a lot of things started changing. Suddenly layout changes was pretty
easy too. After a while speed became and issue, and I had to reduce the number
of subshells. This led to return by reference which is now the standard way of
returning results in the code base. So if you're upgrading from an older version
it's probably a good idea to make a copy of your sbp config and start fresh.

## Soft Requirements
If you want the fancy pointy segment separators, you need the powerline fonts _installed_ and _enabled_. Both.
You can get them [here](https://github.com/powerline/fonts).
Then run the ´./bin/install´ script. Now the hard_to_remember part. Change the settings of your terminal emulator.
Something like "Settings" and then "Fonts" will probably be the right place.
If you don't like powerline then use the 'plain' or 'lines' theme or create your
own. If you are using Kitty as a terminal then everything should work out of the
box.

## Installing
There is an install script. It will copy the default
settings to `~/.config/sbp/settings.conf` along with the default color assignments
to `~/.config/sbp/colors.conf` and add two lines to your `$HOME/.bashrc`:
```
  SBP_PATH=/the/path/to/sbp/
  source ${SBP_PATH}/sbp.bash
```

## Usage
So you're ready to go. Now you do nothing. Just use it. But you could. If you want. Change stuff up a bit.
Edit your config by running `sbp edit config` and run `sbp reload` if you changed
something substantial. Most changes will be effective immediately.
You can use the `sbp` command for a lot of things:
```
  Usage: sbp [command]

  Commands:
  reload            - Reload SBP and user settings
  status            - Show the current configuration
  help              - Show this help text
  list
    segments        - List all available segments
    hooks           - List all available hooks
    themes          - List all available color themes and layouts
  edit
    config          - Opens the sbp config in \$EDITOR (${EDITOR:-'not set'})
    colors          - Opens the colors config in \$EDITOR (${EDITOR:-'not set'})
  set
    color           - Set [color] for the current session
    layout          - Set [layout] for the current session
  toggle
    peekaboo        - Toggle execution of [segment] or [hook]
    debug           - Toggle debug mode
  sbp
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

### Colors and Layouts
Colors and layouts let you decide how the prompt is drawn. Read more about those
and how to make your own in the [Colors](/config/colors) and
[Layouts](/src/layouts). SBP supports both truecolors through RGB values and 256 colors
by using ansi codes. Many will probably just want to rely on the configuration
set in Xresources, by using the xresources color setting.

#### Beta - VI mode
~~The setting `settings_prompt_ready_vi_mode=1` will use the `prompt_ready` icon
with the configured colors and change it's color depending on the current VI
mode if enabled. The cursor will also change from blinking to solid block if
your terminal supports it.~~
The VI mode support has been removed as it is not possible to predictably place
the VI mode indicator on a multiline prompt.

### FAQ

#### Is this really just bash?
Yes, but actually no. At the time of writing the main implementation has
just a few calls do date, while some segments touch grep and sed but these
are being removed.

#### My prompt doesn't show any colors, whats wrong?
You are using a terminal that doesn't support truecolors. You can write your own
ansi theme, or use one of the two provided ones, default-256 or xresources.

#### I don't want to install any fancy fonts, can I still have nice things?
Why yes! Simply use the 'plain' layout. No fonts needed. Or use the Kitty
terminal.
