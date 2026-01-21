#!/usr/bin/env zsh

echo "Setting up dotfiles..."

ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/vimrc ~/.vimrc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/gitignore ~/.gitignore

echo "Done. Restart your terminal or run: source ~/.zshrc"
