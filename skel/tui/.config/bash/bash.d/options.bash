# See set options with $ set -o 
# set descriptions:
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

# See set shell options with $ shopt
# shtop descriptions:
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html 

# Set 
set -o notify

# Shopt
shopt -s cdable_vars 
shopt -s checkhash
shopt -s cmdhist 
shopt -s direxpand
shopt -s extglob 
shopt -s dotglob
shopt -s histappend 

# Shopt GNU Readline specific integration
shopt -s histverify
shopt -s no_empty_cmd_completion
