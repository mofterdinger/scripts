# source this file from ~/.bashrc:
#if [ -f ~/workspaces/git/scripts/bash/.bash_aliases ]; then
#      . ~/workspaces/git/scripts/bash/.bash_aliases
#fi

mkdir -p ~/.bash_completion.d

curl https://raw.githubusercontent.com/cykerway/complete-alias/1.6.0/bash_completion.sh \
     > ~/.bash_completion.d/complete_alias

source ~/.bash_completion.d/complete_alias

# docker containers
alias d='docker'
alias di='docker inspect'
alias dps='docker ps'
alias dpsa='docker ps -a'
complete -F _complete_alias d
complete -F _complete_alias di

# docker remove
alias drm='docker rm'
alias drmf='docker rm -f'
complete -F _complete_alias drm
complete -F _complete_alias drmf

# docker images
alias dim='docker image'
alias dims='docker images'
complete -F _complete_alias dim
complete -F _complete_alias dims

#######################
# Git
#######################
alias g='git'
complete -F _complete_alias g
alias gb='git branch'
complete -F _complete_alias gb
alias gba='git branch --all'
complete -F _complete_alias gba
alias gbd='git branch -D'
complete -F _complete_alias gbd
alias ga.='git add .'
complete -F _complete_alias ga.
alias gcom='git commit'
complete -F _complete_alias gcom
alias gp='git pull'
complete -F _complete_alias gp
alias gpp='git pull -p'
complete -F _complete_alias gpp
alias gpush='git push'
complete -F _complete_alias gpush
alias gc='git checkout'
complete -F _complete_alias gc
alias gcb='git checkout -b'
complete -F _complete_alias gcb
alias gcm='git checkout master'
complete -F _complete_alias gcm
alias gcr='git checkout release'
complete -F _complete_alias gcr

#######################
# Maven
#######################
alias mci='mvn clean install'
alias mciu='mci -U'
alias mciust='mciu -DskipTests'
alias mcist='mci -DskipTests'
alias mcit='mci -T 1C'
alias mciut='mciu -T 1C'
alias mcitst='mcit -DskipTests'
alias mciutst='mciut -DskipTests'

alias mvddu='mvn versions:display-dependency-updates'
alias mvdpu='mvn versions:display-plugin-updates'
