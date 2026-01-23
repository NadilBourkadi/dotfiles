export TERM=xterm-256color
export EDITOR='nvim'

# Dotfiles bootstrap
alias dotfiles='zsh ~/Dev/dotfiles/init.zsh'
alias reload='source ~/.zshrc && echo "zshrc reloaded"'
alias reload-alacritty='touch ~/.config/alacritty/alacritty.toml'

# Antigen (skip on reload - already loaded)
if [[ -z "$_ANTIGEN_LOADED" ]]; then
  # Set cache dir for oh-my-zsh plugins (required by last-working-dir)
  export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
  [[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

  source ~/.zsh/antigen.zsh
  antigen use oh-my-zsh
  antigen bundle git
  antigen bundle command-not-found
  antigen bundle last-working-dir
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-autosuggestions
  antigen apply
  _ANTIGEN_LOADED=1
fi

# ─────────────────────────────────────────────────────────────
# Catppuccin Mocha Theme
# ─────────────────────────────────────────────────────────────

# Color definitions (for reference)
# Blue: #89b4fa | Green: #a6e3a1 | Mauve: #cba6f7 | Red: #f38ba8
# Yellow: #f9e2af | Teal: #94e2d5 | Pink: #f5c2e7 | Peach: #fab387
# Text: #cdd6f4 | Overlay0: #6c7086 | Surface1: #45475a

# Custom prompt with Catppuccin colors
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{#cba6f7} %b%f'  # mauve git branch
zstyle ':vcs_info:git:*' actionformats '%F{#cba6f7} %b%f %F{#f9e2af}(%a)%f'
setopt PROMPT_SUBST

# Prompt: directory (blue) | git branch (mauve) | symbol (green/red based on exit code)
PROMPT='%F{#89b4fa}%~%f${vcs_info_msg_0_} %(?.%F{#a6e3a1}.%F{#f38ba8})❯%f '

# Right prompt: show time in subtle overlay color
RPROMPT='%F{#6c7086}%T%f'

# Autosuggestions color (subtle overlay)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax highlighting colors
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#89b4fa'           # blue
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'             # green
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#cba6f7'           # mauve
ZSH_HIGHLIGHT_STYLES[function]='fg=#89b4fa'          # blue
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic' # green
ZSH_HIGHLIGHT_STYLES[path]='fg=#94e2d5,underline'    # teal
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f5c2e7'          # pink
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'  # green
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'  # green
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'  # green
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7'       # pink
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'  # pink
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'     # red
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'     # mauve
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'    # overlay0

# Colored man pages (Catppuccin Mocha)
export LESS_TERMCAP_mb=$'\e[1;35m'      # begin blink (mauve)
export LESS_TERMCAP_md=$'\e[1;38;2;137;180;250m'  # begin bold (blue)
export LESS_TERMCAP_me=$'\e[0m'         # end bold/blink
export LESS_TERMCAP_so=$'\e[38;2;49;50;68;48;2;205;214;244m'  # standout (surface0 bg, text fg)
export LESS_TERMCAP_se=$'\e[0m'         # end standout
export LESS_TERMCAP_us=$'\e[4;38;2;166;227;161m'  # begin underline (green)
export LESS_TERMCAP_ue=$'\e[0m'         # end underline

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case insensitive
zstyle ':completion:*' list-colors '=*=38;2;148;226;213'   # teal completion items
zstyle ':completion:*:descriptions' format '%F{#cba6f7}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{#f38ba8}no matches%f'

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

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

#
# Tmux auto-attach (skip in IDE terminals and non-interactive shells)
#
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]]; then
    tmux attach 2>/dev/null || tmux new-session
fi
