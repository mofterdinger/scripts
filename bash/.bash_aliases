mkdir -p ~/.bash_completion.d

curl https://raw.githubusercontent.com/cykerway/complete-alias/1.6.0/bash_completion.sh \
     > ~/.bash_completion.d/complete_alias

source ~/.bash_completion.d/complete_alias

# docker containers
alias dps='docker ps'
alias dpsa='docker ps -a'

# docker remove
alias drm='docker rm'
alias drmf='docker rm -f'
complete -F _complete_alias drm
complete -F _complete_alias drmf

# docker images
alias di='docker image'
alias dis='docker images'
