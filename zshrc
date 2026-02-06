export TERM=xterm-256color
export EDITOR='nvim'
export PATH="$HOME/.local/bin:$PATH"

# Dotfiles bootstrap
alias dotfiles='zsh ~/Dev/dotfiles/init.zsh'
alias reload='source ~/.zshrc && echo "zshrc reloaded"'
alias reload-alacritty='touch ~/.config/alacritty/alacritty.toml'

# ZSH_CACHE_DIR needed by last-working-dir plugin
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# Source modular config
for f in ~/Dev/dotfiles/zsh/{plugins,theme,functions}.zsh; do
  [[ -f "$f" ]] && source "$f"
done

# Starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Tmux auto-attach (skip in IDE terminals and non-interactive shells)
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]]; then
  tmux attach 2>/dev/null || tmux new-session
fi
