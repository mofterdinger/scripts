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

# git
alias g='git'
alias ga.='git add .'
alias gpl='git pull'
alias gplp='git pull -p'
alias gph='git push'
alias gcm='git checkout master'
complete -F _complete_alias g
complete -F _complete_alias ga.
complete -F _complete_alias gpl
complete -F _complete_alias gplp
complete -F _complete_alias gph
complete -F _complete_alias gcm

