#!/bin/bash

# IMPROVEMENT: change flags to long versions for improved readablity

## Coreutils ##
alias ls='ls -1Ah --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias cp='cp -iv'
alias grep='grep --color=auto'
alias tree='tree -a'
alias dd="dd status=progress"
alias rsync='rsync -v --progress'
alias less='less --use-color'

## Extened utilities ##
alias timer='time read -p "Press enter to stop"'
alias links='find . -maxdepth 1 -type l -ls'
alias calc='python -qi -c "from math import *"'

# Cargo 
alias cf='cargo fmt'
alias cr='cargo run'
alias ct='cargo test'
alias cy='cargo clippy'

# Git
alias ga='git add'
alias gaa='git add -A'
alias gb='git branch'
alias gc='git clone'
alias gd='git diff'
alias gds='git diff --staged'
alias gdss='git diff --staged --stat'
alias gf='git fetch'
alias gp='git pull'
alias gi="git commit"
alias gk='git checkout'
alias gl='git log'
alias gm='git merge'
alias gs='git stash'
alias gt='git status'
alias gu='git push'
alias gw='git whatchanged -p --abbrev-commit --pretty=medium'

## Package management ##
alias update='sudo pacman -Syyu --noconfirm'
alias install='yay -S --noconfirm --needed'
alias remove='yay -Rs'
alias removeOrphans='pacman -Rns $(pacman -Qtdq)'
