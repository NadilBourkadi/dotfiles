#!/usr/bin/env zsh
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Derive dotfiles directory from script location
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Prerequisite checks
for cmd in git zsh; do
  command -v "$cmd" &>/dev/null || { echo "Error: $cmd is required but not found"; exit 1; }
done

# ─────────────────────────────────────────────────────────────
# Symlinks
# ─────────────────────────────────────────────────────────────

# File symlinks (ln -sf is safe for files)
typeset -A file_symlinks=(
  [zshrc]=~/.zshrc
  [tmux.conf]=~/.tmux.conf
  [gitignore_global]=~/.gitignore_global
  [starship.toml]=~/.config/starship.toml
  [alacritty.toml]=~/.config/alacritty/alacritty.toml
)

for src dest in "${(@kv)file_symlinks}"; do
  echo -n "Symlinking $src... "
  mkdir -p "$(dirname "$dest")"
  ln -sf "$DOTFILES_DIR/$src" "$dest"
  echo "${GREEN}Done${NC}"
done

# Directory symlinks (must rm -f first to avoid circular symlink)
typeset -A dir_symlinks=(
  [nvim]=~/.config/nvim
)

for src dest in "${(@kv)dir_symlinks}"; do
  echo -n "Symlinking $src/ ... "
  mkdir -p "$(dirname "$dest")"
  rm -f "$dest"
  ln -s "$DOTFILES_DIR/$src" "$dest"
  echo "${GREEN}Done${NC}"
done

# ─────────────────────────────────────────────────────────────
# Git config
# ─────────────────────────────────────────────────────────────

echo -n "Configuring git global settings... "
git config --global core.excludesfile ~/.gitignore_global
git config --global core.autocrlf false
echo "${GREEN}Done${NC}"

# ─────────────────────────────────────────────────────────────
# Package installation
# ─────────────────────────────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew &>/dev/null; then
    echo -n "Installing Homebrew dependencies... "
    brew bundle --file="$DOTFILES_DIR/Brewfile" --quiet || { echo "brew bundle failed"; exit 1; }
    echo "${GREEN}Done${NC}"
    echo "Note: Set your terminal font to 'Hack Nerd Font' in preferences"
  else
    echo "Homebrew not found, skipping dependency installation"
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  if command -v apt &>/dev/null; then
    echo -n "Installing packages via apt... "
    sudo apt install -y tmux neovim ripgrep fd-find fonts-hack 2>/dev/null
    echo "${GREEN}Done${NC}"
  elif command -v dnf &>/dev/null; then
    echo -n "Installing packages via dnf... "
    sudo dnf install -y tmux neovim ripgrep fd-find 2>/dev/null
    echo "${GREEN}Done${NC}"
  else
    echo "No supported package manager found (apt/dnf), skipping dependency installation"
  fi
fi

# ─────────────────────────────────────────────────────────────
# Alacritty (GitHub release, macOS only)
# ─────────────────────────────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -d /Applications/Alacritty.app ]]; then
    echo "Alacritty already installed, ${GREEN}skipping${NC}"
  else
    echo -n "Installing Alacritty from GitHub... "
    ALACRITTY_TAG=$(curl -sL https://api.github.com/repos/alacritty/alacritty/releases/latest | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
    ALACRITTY_DMG="Alacritty-${ALACRITTY_TAG}.dmg"
    curl -sL "https://github.com/alacritty/alacritty/releases/download/${ALACRITTY_TAG}/${ALACRITTY_DMG}" -o "/tmp/${ALACRITTY_DMG}"
    hdiutil attach "/tmp/${ALACRITTY_DMG}" -quiet -nobrowse -mountpoint /tmp/alacritty-mnt
    cp -R /tmp/alacritty-mnt/Alacritty.app /Applications/
    hdiutil detach /tmp/alacritty-mnt -quiet
    rm -f "/tmp/${ALACRITTY_DMG}"
    echo "${GREEN}Done${NC}"
  fi
fi

# ─────────────────────────────────────────────────────────────
# Plugin managers
# ─────────────────────────────────────────────────────────────

echo "Zinit (Zsh plugin manager) will auto-install on first shell launch"

# Install TPM (Tmux Plugin Manager)
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo -n "Installing TPM (Tmux Plugin Manager)... "
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || { echo "TPM clone failed"; exit 1; }
  echo "${GREEN}Done${NC}"
  echo "Note: Press prefix + I in tmux to install plugins"
else
  echo "TPM already installed, ${GREEN}skipping${NC}"
fi

# Install Neovim plugins
if command -v nvim &>/dev/null; then
  echo -n "Installing Neovim plugins (lazy.nvim)... "
  nvim --headless "+Lazy! sync" +qa 2>/dev/null
  echo "${GREEN}Done${NC}"
else
  echo "Neovim not found, skipping plugin installation"
fi

echo "${GREEN}Done.${NC} Restart your terminal or run: source ~/.zshrc"
