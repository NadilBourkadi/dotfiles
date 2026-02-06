# Zinit plugin manager setup and plugin loading

# Auto-install zinit if missing
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Oh-My-Zsh snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found
zinit snippet OMZP::last-working-dir

# Community plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# Initialize completion system and replay deferred compdef calls
autoload -Uz compinit && compinit
zinit cdreplay -q
