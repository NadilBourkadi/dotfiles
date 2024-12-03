alias python=python3
alias vim=/usr/local/bin/vim

export TERM=xterm-256color
export EDITOR='vim'

#
# Kubernetes
#

alias k=kubectl
alias n=namespace

export KUBE_EDITOR='vim'

source ~/.zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git
antigen bundle command-not-found
antigen bundle last-working-dir
antigen bundle kube-ps1

antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

ZSH_AUTOSUGGEST_STRATEGY=completion
