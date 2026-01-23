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

echo -n "Configuring git autocrlf... "
git config --global core.autocrlf false
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

# Starship prompt config
echo -n "Symlinking starship config... "
ln -sf ~/Dev/dotfiles/starship.toml ~/.config/starship.toml
echo "${GREEN}Done${NC}"

# Install dependencies (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew &> /dev/null; then
    # Nerd Font for Neovim icons
    if ! brew list --cask font-hack-nerd-font &> /dev/null; then
      echo -n "Installing Nerd Font for Neovim icons... "
      brew install --cask font-hack-nerd-font
      echo "${GREEN}Done${NC}"
      echo "Note: Set your terminal font to 'Hack Nerd Font' in preferences"
    else
      echo "Nerd Font already installed, ${GREEN}skipping${NC}"
    fi

    # tree-sitter CLI (required by nvim-treesitter for compiling parsers)
    if ! command -v tree-sitter &> /dev/null; then
      echo -n "Installing tree-sitter CLI... "
      brew install tree-sitter-cli
      echo "${GREEN}Done${NC}"
    else
      echo "tree-sitter CLI already installed, ${GREEN}skipping${NC}"
    fi

    # Starship prompt
    if ! command -v starship &> /dev/null; then
      echo -n "Installing Starship prompt... "
      brew install starship
      echo "${GREEN}Done${NC}"
    else
      echo "Starship already installed, ${GREEN}skipping${NC}"
    fi
  else
    echo "Homebrew not found, skipping dependency installation"
  fi
fi

# Install TPM (Tmux Plugin Manager)
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo -n "Installing TPM (Tmux Plugin Manager)... "
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null
  echo "${GREEN}Done${NC}"
  echo "Note: Press prefix + I in tmux to install plugins"
else
  echo "TPM already installed, ${GREEN}skipping${NC}"
fi

# Install Neovim plugins
if command -v nvim &> /dev/null; then
  echo -n "Installing Neovim plugins (lazy.nvim)... "
  nvim --headless "+Lazy! sync" +qa 2>/dev/null
  echo "${GREEN}Done${NC}"
else
  echo "Neovim not found, skipping plugin installation"
fi

echo "${GREEN}Done.${NC} Restart your terminal or run: source ~/.zshrc"
