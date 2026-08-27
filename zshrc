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
# Fix missing execute bit on claude.exe — the auto-updater can leave the binary non-executable
# after some updates, causing "zsh: permission denied: claude". macOS Homebrew path only;
# safely a no-op on Linux (different Homebrew prefix) via the -f guard.
_cc_exe=/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe
[[ -f "$_cc_exe" && ! -x "$_cc_exe" ]] && { chmod +x "$_cc_exe" || echo "[zshrc] warning: could not restore +x on $_cc_exe — check ownership (run: ls -l $_cc_exe)" >&2; }
unset _cc_exe

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

# Private extensions (gitignored)
[[ -f ~/Dev/dotfiles/private/zshrc ]] && source ~/Dev/dotfiles/private/zshrc

# Tmux auto-attach (skip in IDE terminals and non-interactive shells)
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]]; then
  tmux attach 2>/dev/null || tmux new-session
fi
