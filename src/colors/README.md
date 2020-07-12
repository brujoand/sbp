# Colors

## Creating your own theme colors
You can create your own theme layout by placing a file in:
```
   ${HOME}/.config/sbp/themes/colors/${your_color_theme_name}.bash
```

Theme colors are basically 16 RGB values. And I've added a template
`template.ejs` that can be used with [Base16 Builder](https://github.com/base16-builder/base16-builder) to generate a colors
file from your favorite color scheme. For instance like so:
```
   base16-builder --scheme 3024 --template themes/template.ejs  --brightness dark > themes/colors/3024.bash
```
You can also set the colors to be `xresources` which will use whatever theme is
set in your terminal/xresources config.

