#!/bin/bash

# TODO: change flags to long versions for improved readablity

## Coreutils ##
alias ls='ls -1Ah --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias cp='cp -iv'
alias grep='grep --color=auto'
alias tree='tree -a'
alias dd="dd status=progress"
alias curl='curl --continue-at - --location --remote-name --remote-time'
alias rsync='rsync -v --progress'
alias less='less --use-color'

## Extened utilities ##
alias timer='time read -p "Press enter to stop"'
alias links='find . -maxdepth 1 -type l -ls'
alias calc='python -qi -c "from math import *"'
alias batstat="upower -i $(upower -e | grep 'BAT')"

# Git
alias gp='git pull'
alias gf='git fetch'
alias gc='git clone'
alias gs='git stash'
alias gb='git branch'
alias gm='git merge'
alias gk='git checkout'
alias go='git commit -m'
alias gl='git log --stat'
alias gu='git push origin HEAD'
alias gw='git whatchanged -p --abbrev-commit --pretty=medium'

## Package management ##
alias update='sudo pacman -Syyu --noconfirm'
alias install='yay -S --noconfirm --needed'
alias remove='yay -Rs'
alias removeOrphans='pacman -Rns $(pacman -Qtdq)'
