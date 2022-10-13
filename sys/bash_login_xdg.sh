
# Appended by the Evolve project: https://github.com/gibbz00/evolve
# Forces bash to be more compliant to the XDG base directory specification. 
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)
config_directory=${XDG_CONFIG_HOME:-$HOME/.config}/bash
test -f "$config_directory/bash_profile" && . "$config_directory/bash_profile"
unset config_directory
