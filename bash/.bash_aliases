# source this file from ~/.bashrc:
#if [ -f ~/workspaces/git/scripts/bash/.bash_aliases ]; then
#      . ~/workspaces/git/scripts/bash/.bash_aliases
#fi

if [ ! -f ~/.bash_completion.d/complete_alias ]; then
  up_bash_completion
fi

source ~/.bash_completion.d/complete_alias

#######################
# Maintainance
#######################
up_bash_aliases() {
  curl https://raw.githubusercontent.com/mofterdinger/scripts/master/bash/.bash_aliases > ~/.bash_aliases
  source ~/.bash_aliases
}
up_bash_completion() {
  mkdir -p ~/.bash_completion.d
  curl https://raw.githubusercontent.com/cykerway/complete-alias/1.6.0/bash_completion.sh \
     > ~/.bash_completion.d/complete_alias
}

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
alias ga.='git add .'
complete -F _complete_alias ga.
alias gb='git branch'
complete -F _complete_alias gb
alias gba='git branch --all'
complete -F _complete_alias gba
alias gbd='git branch -D'
complete -F _complete_alias gbd
alias gc='git checkout'
complete -F _complete_alias gc
alias gcm='git checkout master'
complete -F _complete_alias gcm
alias gcr='git checkout release'
complete -F _complete_alias gcr
alias gd='git diff'
complete -F _complete_alias gd
alias gcb='git checkout -b'
complete -F _complete_alias gcb
alias gcom='git commit'
complete -F _complete_alias gcom
alias gm='git merge'
complete -F _complete_alias gm
alias gmm='git merge master'
complete -F _complete_alias gmm
alias gp='git pull'
complete -F _complete_alias gp
alias gpp='git pull -p'
complete -F _complete_alias gpp
alias gpush='git push'
complete -F _complete_alias gpush

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

# mvn version ...
mvs() {
  mvn versions:set -DnewVersion=$1
}
mtvs() {
  mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$1 -DupdateVersionRangeMatchingBounds=true
}
alias mvddu='mvn versions:display-dependency-updates'
alias mvdpu='mvn versions:display-plugin-updates'

# mvn dependency ...
alias mda='mvn dependency:analyze'
alias mdadup='mvn dependency:analyze-duplicate'
alias mdadm='mvn dependency:analyze-dep-mgt'
alias mdar='mvn dependency:analyze-report'

alias jcli='java -jar ~/jenkins-cli.jar'

alias srghnas='ssh admin@nas-rgh.synology.me -p 322'
