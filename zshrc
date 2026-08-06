export TERM=xterm-256color
export EDITOR='nvim'
bindkey -e  # Use emacs keybindings for line editing (zsh defaults to vi when EDITOR=nvim)
export PATH="$HOME/.local/bin:$PATH"

# Homebrew on Linux (no-op on macOS, where brew is already on PATH)
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# nvm (Node version manager) — installed by init.zsh
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Clean up stale temp dirs left by failed Claude Code auto-updates (causes ENOTEMPTY on next attempt)
[[ -d /opt/homebrew/lib/node_modules/@anthropic-ai ]] && rm -rf /opt/homebrew/lib/node_modules/@anthropic-ai/.claude-code-* 2>/dev/null

# Dotfiles bootstrap
alias dotfiles='zsh ~/Dev/dotfiles/init.zsh'
alias reload='source ~/.zshrc && echo "zshrc reloaded"'
alias reload-alacritty='touch ~/.config/alacritty/alacritty.toml'

# ZSH_CACHE_DIR needed by last-working-dir plugin
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# Source modular config
for f in ~/Dev/dotfiles/zsh/{wsl,plugins,theme,functions}.zsh; do
  [[ -f "$f" ]] && source "$f"
done

# The tmux guard below calls _wsl_console_login. Sourcing is best-effort, so
# define a fallback if zsh/wsl.zsh is missing (a partial checkout, or mid-rebase
# while ~/.zshrc is symlinked into the repo) — otherwise every prompt errors.
(( $+functions[_wsl_console_login] )) || _wsl_console_login() { return 1 }

# Starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Private extensions (gitignored)
[[ -f ~/Dev/dotfiles/private/zshrc ]] && source ~/Dev/dotfiles/private/zshrc

# Tmux auto-attach. Skipped in IDE terminals, non-interactive shells, and WSL's
# console login session (see zsh/wsl.zsh for why that one matters).
if command -v tmux &>/dev/null && [[ -o interactive ]] && [ -t 0 ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]] && ! _wsl_console_login; then
  tmux attach 2>/dev/null || tmux new-session
fi
