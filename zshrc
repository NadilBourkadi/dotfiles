# Assert 256 colours everywhere except on terminals that genuinely can't render
# them — WSL's console login session, emacs shell-mode, serial consoles are all
# TERM=dumb. Clobbering that loses the only portable "not a real terminal" signal.
[[ "$TERM" == dumb ]] || export TERM=xterm-256color
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
# Fix missing execute bit on claude.exe — the auto-updater's local download path bypasses
# install.cjs's chmodSync(dest, 0o755), leaving the binary non-executable after some updates.
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
for f in ~/Dev/dotfiles/zsh/{wsl,plugins,theme,functions}.zsh; do
  [[ -f "$f" ]] && source "$f"
done

# The tmux guard below calls _wsl_console_login. Sourcing is best-effort, so
# define a fallback if zsh/wsl.zsh is missing (a partial checkout, or mid-rebase
# while ~/.zshrc is symlinked into the repo) — otherwise every prompt errors.
(( $+functions[_wsl_console_login] )) || _wsl_console_login() { return 1 }
(( $+functions[_is_wsl] )) || _is_wsl() { return 1 }

# Starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Private extensions (gitignored)
[[ -f ~/Dev/dotfiles/private/zshrc ]] && source ~/Dev/dotfiles/private/zshrc

# Keep the Windows Alacritty config in step with this repo. The Windows side
# cannot symlink into WSL (see the script's header), so a `git pull` lands on
# the next shell rather than instantly. Cheap: the script stamp-checks and
# returns before any Windows interop when nothing has changed.
# _is_wsl gates it: the script is symlinked on every OS but can only ever
# no-op off WSL, and without this every macOS shell and tmux pane forks bash
# for nothing.
if [[ -o interactive ]] && _is_wsl && [ -x ~/.local/bin/alacritty-windows-sync ] && ! _wsl_console_login; then
  ~/.local/bin/alacritty-windows-sync --quiet
fi

# Tmux auto-attach. Skipped in IDE terminals, non-interactive shells, and WSL's
# console login session (see zsh/wsl.zsh for why that one matters).
if command -v tmux &>/dev/null && [[ -o interactive ]] && [ -t 0 ] && [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] && [ -z "$CURSOR_TRACE_ID" ] && [[ ! "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]] && ! _wsl_console_login; then
  tmux attach 2>/dev/null || tmux new-session
fi
