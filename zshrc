export TERM=xterm-256color
export EDITOR='nvim'

# Dotfiles bootstrap
alias dotfiles='zsh ~/Dev/dotfiles/init.zsh'
alias reload-alacritty='touch ~/.config/alacritty/alacritty.toml'

source ~/.zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git
antigen bundle command-not-found
antigen bundle last-working-dir
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme robbyrussell

antigen apply

ZSH_AUTOSUGGEST_STRATEGY=completion

# Created by `pipx` on 2025-07-29 16:52:59
export PATH="$PATH:/Users/nadil.bourkadi/.local/bin"

export PATH="$HOME/.local/bin:$PATH"

# Usage: av dev sts get-caller-identity
function av() { 
  local profile=$1; shift
  aws-vault exec "${profile}" -- aws "$@"
}
compdef _aws av   # enables tab-completion like the real aws CLI

git config --global core.autocrlf false

# opencode
export PATH=/Users/nadil.bourkadi/.opencode/bin:$PATH

#
# Tmux auto-attach (skip in IDE terminals and non-interactive shells)
#
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]]; then
    tmux attach 2>/dev/null || tmux new-session
fi
