# Dotfiles Configuration

Personal dotfiles for a development environment.

## Installation

One-time setup for a new machine:

1. Clone this repository to your home directory:
```bash
git clone <repository-url> ~/dotfiles
```

2. Run the bootstrap script to create symbolic links:
```bash
cd ~/dotfiles
zsh init.zsh
```

This will create symbolic links for:
- `~/.zshrc` → `~/dotfiles/zshrc`
- `~/.vimrc` → `~/dotfiles/vimrc`
- `~/.tmux.conf` → `~/dotfiles/tmux.conf`
- `~/.gitignore` → `~/dotfiles/gitignore`

## Prerequisites

### Required
- **Zsh** - Primary shell configuration
- **Vim** - Text editor with extensive plugin setup
- **Tmux** - Terminal multiplexer
- **Git** - Version control (for git-completion.bash)

### Optional but Recommended
- **Antigen** - Zsh plugin manager (install to `~/.zsh/antigen.zsh`)
- **aws-vault** - For AWS credential management (used in zshrc)

## Features

### Shell Configuration (Zsh)
- **Antigen plugin manager** with oh-my-zsh integration
- **Plugins**: git, command-not-found, last-working-dir, zsh-syntax-highlighting
- **Theme**: robbyrussell
- **AWS Vault integration**: `av` function for AWS profile management
- **Tmux auto-attach**: Automatically connects to existing tmux sessions (skips IDE terminals)

### Vim Configuration
- **16 plugins** managed by vim-plug including:
  - Syntax checking (Syntastic)
  - File navigation (NERDTree, CtrlP)
  - Git integration (Fugitive, GitGutter)
  - Testing framework integration (vim-test)
  - Code formatting (autopep8)
- **Custom keybindings**: Leader-based workflow with comma as leader
- **Project-specific settings**: Auto-configuration for React and React Native projects
- **Visual enhancements**: Custom colors, transparent background, status line

### Tmux Configuration
- **Custom prefix**: Ctrl+a instead of Ctrl+b
- **Mouse support**: Enabled for scrolling and selection
- **Vim keybindings**: Vi-mode for copy/paste operations
- **Custom status bar**: Pink background styling
- **Plugin support**: tmux-yank for system clipboard integration

## Key Aliases & Functions

### AWS
```bash
av <profile> <cmd>  # run AWS CLI command with aws-vault profile
```

## Vim Keybindings

### Leader Commands (`,` = leader)
```vim
,w             # Save file
,n             # Open NERDTree for current file
,sa            # Search with ripgrep
,aa            # Search with Ack
,tn            # Run nearest test
,tt            # Run current test file
,pp            # Auto-format with autopep8
,se            # Edit .vimrc
,ss            # Reload .vimrc
```

### Navigation
```vim
Ctrl+h/l       # Switch between tabs
Ctrl+n         # Toggle NERDTree
```

## Customization

### Adding New Aliases
Add shell aliases to `zshrc`.

### Vim Plugins
Add new plugins to the vim-plug section in `vimrc`:
```vim
Plug 'author/plugin-name'
```
Then run `:PlugInstall` in Vim.

### Tmux Plugins
Add plugins to `tmux.conf`:
```bash
set -g @plugin 'author/plugin-name'
```

## File Structure
```
dotfiles/
├── README.md          # This file
├── init.zsh          # Installation script
├── zshrc             # Zsh configuration
├── vimrc             # Vim configuration
├── tmux.conf         # Tmux configuration
└── gitignore         # Global git ignore patterns
```

## Notes

- Vim automatically opens NERDTree on startup
- Tmux auto-attach skips VS Code and Cursor integrated terminals
