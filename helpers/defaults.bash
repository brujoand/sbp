# Global settings not related to segments
source "${sbp_path}/themes/default.bash"
settings_color_empty=-1
color_reset='\[\e[0m\]'

# Comment the follwing 4 lines to disable powerline characters
  settings_char_segment=''
  settings_char_path=''
  settings_char_ready='➜'
  settings_char_segrev=''
# Uncomment the following 4 lines to disable powerline characters
#  settings_char_segment=" "
#  settings_char_path="/"
#  settings_char_ready=">"
#  settings_char_segrev=" "

# Hooks will run once before every prompt
# Run 'sbp hooks' to list all available hooks
settings_hooks=('alert')

# Segments are generated before each prompt and can
# be added, removed and reordered
# Run 'sbp segments' to list all available segments
settings_segments_left=('host' 'path' 'python_env' 'git' )
settings_segments_right=('command' 'timestamp')
settings_segment_line_two=('prompt_ready')

# Default segment configuration
settings_command_color_fg=$color08
settings_command_color_fg_error=$color03
settings_command_color_bg_error=$color1
settings_command_color_bg=$color03

settings_git_color_bg=$color10
settings_git_color_fg=$color08

settings_host_color_bg=$color08
settings_host_color_fg=$color03

settings_path_color_bg=$color14
settings_path_color_fg=$color15
settings_path_color_sep=$color07
settings_path_disable_sep=0

settings_path_color_readonly_fg=$color15
settings_path_color_readonly_bg=$color1

settings_prompt_ready_color=$color03

settings_python_virtual_env_bg=$color02
settings_python_virtual_env_fg=$color15

settings_return_code_bg=$color1
settings_return_code_fg=$color15

settings_timestamp_color_bg=$color08
settings_timestamp_color_fg=$color03
settings_timestamp_format="%H:%M:%S"

settings_aws_color_bg=$color08
settings_aws_color_fg=$color09

settings_openshift_color_bg=$color08
settings_openshift_color_fg=$color09
settings_openshift_default_user="$USER"

settings_rescuetime_bg=$color02
settings_rescuetime_fg=$color15
settings_rescuetime_sep_fg=$color07
