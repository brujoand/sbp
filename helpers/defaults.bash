# Global settings not related to segments
settings_color_blue=31
settings_color_red=196
settings_color_white=15
settings_color_grey=244
settings_color_dgrey=238
settings_color_dorange=172
settings_color_lgrey=250
settings_color_green=148
settings_color_dgreen=22
settings_color_empty=-1
color_reset='\[\e[00m\]'

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

# Segments are generated bofere each prompt and can
# be added, removed and reordered
# Run 'sbp segments' to list all available segments
settings_segments_left=('host' 'path' 'python_env' 'git' 'filler')
settings_segments_right=('command' 'timestamp')
settings_segment_line_two=('prompt_ready')

# Default segment configuration
settings_command_color_fg=$settings_color_dgrey
settings_command_color_fg_error=-$settings_color_lgrey
settings_command_color_bg_error=$settings_color_red
settings_command_color_bg=$settings_color_lgrey

settings_filler_color_bg=$settings_color_empty
settings_filler_color_fg=$settings_color_empty

settings_git_color_bg=$settings_color_green
settings_git_color_fg=$settings_color_dgrey
settings_git_max_length=20

settings_host_color_bg=$settings_color_dgrey
settings_host_color_fg=$settings_color_lgrey

settings_path_color_bg=$settings_color_blue
settings_path_color_fg=$settings_color_white
settings_path_color_sep=$settings_color_grey
settings_path_disable_sep=0
settings_path_max_length=30

settings_path_color_readonly_fg=$settings_color_white
settings_path_color_readonly_bg=$settings_color_red

settings_prompt_ready_color=238

settings_python_virtual_env_bg=$settings_color_dgreen
settings_python_virtual_env_fg=$settings_color_white

settings_return_code_bg=$settings_color_red
settings_return_code_fg=$settings_color_white

settings_timestamp_color_bg=$settings_color_dgrey
settings_timestamp_color_fg=$settings_color_lgrey
settings_timestamp_format="%H:%M:%S"

settings_aws_color_bg=$settings_color_dgrey
settings_aws_color_fg=$settings_color_dorange

settings_openshift_color_bg=$settings_color_dgrey
settings_openshift_color_fg=$settings_color_dorange
settings_openshift_default_user="$USER"
