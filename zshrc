export TERM=xterm-256color
export EDITOR='nvim'

# Dotfiles bootstrap
alias dotfiles='zsh ~/Dev/dotfiles/init.zsh'
alias reload='source ~/.zshrc && echo "zshrc reloaded"'
alias reload-alacritty='touch ~/.config/alacritty/alacritty.toml'

# Antigen (skip on reload - already loaded)
if [[ -z "$_ANTIGEN_LOADED" ]]; then
  source ~/.zsh/antigen.zsh
  antigen use oh-my-zsh
  antigen bundle git
  antigen bundle command-not-found
  antigen bundle last-working-dir
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen theme robbyrussell
  antigen apply
  _ANTIGEN_LOADED=1
fi

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

# Claude AI helpers
# Usage: ask "question" or pipe: cat file | ask "explain this"
function ask() {
  if [ -t 0 ]; then
    claude --print "$*"
  else
    local input=$(cat)
    claude --print "$input

$*"
  fi
}

# Quick code explanation
# Usage: explain file.py
function explain() {
  if [ -n "$1" ]; then
    cat "$1" | claude --print "Explain this code concisely:"
  elif [ ! -t 0 ]; then
    cat | claude --print "Explain this code concisely:"
  else
    echo "Usage: explain <file> OR cat file | explain"
  fi
}

git config --global core.autocrlf false

# opencode
export PATH=/Users/nadil.bourkadi/.opencode/bin:$PATH

#
# Tmux auto-attach (skip in IDE terminals and non-interactive shells)
#
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]]; then
    tmux attach 2>/dev/null || tmux new-session
fi
