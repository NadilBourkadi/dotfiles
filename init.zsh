#!/usr/bin/env zsh

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Setting up dotfiles..."

# Symlinks
echo -n "Symlinking zshrc... "
ln -sf ~/Dev/dotfiles/zshrc ~/.zshrc
echo "${GREEN}Done${NC}"

echo -n "Symlinking tmux.conf... "
ln -sf ~/Dev/dotfiles/tmux.conf ~/.tmux.conf
echo "${GREEN}Done${NC}"

echo -n "Symlinking gitignore_global... "
ln -sf ~/Dev/dotfiles/gitignore_global ~/.gitignore_global
echo "${GREEN}Done${NC}"

echo -n "Configuring git to use global gitignore... "
git config --global core.excludesfile ~/.gitignore_global
echo "${GREEN}Done${NC}"

# Neovim config (directory symlink)
echo -n "Symlinking nvim config... "
mkdir -p ~/.config
rm -f ~/.config/nvim
ln -s ~/Dev/dotfiles/nvim ~/.config/nvim
echo "${GREEN}Done${NC}"

# Alacritty config
echo -n "Symlinking alacritty config... "
mkdir -p ~/.config/alacritty
ln -sf ~/Dev/dotfiles/alacritty.toml ~/.config/alacritty/alacritty.toml
echo "${GREEN}Done${NC}"

# Install Nerd Font for Neovim icons (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew &> /dev/null; then
    if ! brew list --cask font-hack-nerd-font &> /dev/null; then
      echo -n "Installing Nerd Font for Neovim icons... "
      brew install --cask font-hack-nerd-font
      echo "${GREEN}Done${NC}"
      echo "Note: Set your terminal font to 'Hack Nerd Font' in preferences"
    else
      echo "Nerd Font already installed, ${GREEN}skipping${NC}"
    fi
  else
    echo "Homebrew not found, skipping font installation"
  fi
fi

echo "${GREEN}Done.${NC} Restart your terminal or run: source ~/.zshrc"
