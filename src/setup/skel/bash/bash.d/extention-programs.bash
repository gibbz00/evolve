# using z 
. /usr/share/z/z.sh 

# autocompletions
. /usr/share/bash-completion/bash_completion

# Use GNU readline for command input handling
bind -f "$XDG_CONFIG_HOME/readline/inputrc"

## Fuzzy finding in shell
# alt+c fuzzy change directory
# ctrl+t fuzzy list and select files in current directory
# ctrl+r fuzzy list and select commands from history
. /usr/share/fzf/key-bindings.bash
. /usr/share/fzf/completion.bash
# shows hidden files and follows symbolic links in fzf
# using fd instead of find due to it being a lot more performant
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
