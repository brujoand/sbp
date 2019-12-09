# Global settings not related to segments
set_theme 'default'

settings_segment_separator_right=''
settings_segment_separator_left=''
settings_segment_splitter_left=''
settings_segment_splitter_right=''

# Hooks will run once before every prompt
# Run 'sbp hooks' to list all available hooks
settings_hooks=('alert')

# Segments are generated before each prompt and can
# be added, removed and reordered
# Run 'sbp segments' to list all available segments
settings_segments_left=('host' 'path' 'python_env' 'git' )
settings_segments_right=('command' 'timestamp')

# Default segment configuration
settings_command_color_fg=$color08
settings_command_color_fg_error=$color03
settings_command_color_bg_error=$color01
settings_command_color_bg=$color03

settings_git_color_bg=$color10
settings_git_color_fg=$color08
settings_git_icon=''

settings_host_color_bg=$color08
settings_host_color_fg=$color03

settings_path_color_bg=$color14
settings_path_color_fg=$color15
settings_path_splitter_disable=0
settings_path_splitter_color=$color07

settings_path_color_readonly_fg=$color15
settings_path_color_readonly_bg=$color1

settings_prompt_ready_color=$color03
settings_prompt_ready_vi_mode=0
settings_prompt_ready_vi_insert_color=$color03
settings_prompt_ready_vi_command_color=$color14
settings_prompt_ready_icon='➜'

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
settings_rescuetime_splitter_color=$color07
