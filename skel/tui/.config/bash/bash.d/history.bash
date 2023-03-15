#!/bin/bash
export HISTFILE="$XDG_STATE_HOME"/bash/history
export HISTSIZE=20000
export HISTCONTROL=ignoredups:erasedups
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
