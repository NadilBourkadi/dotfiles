# Dotfiles Configuration

Personal dotfiles for a development environment.

## Installation

One-time setup for a new machine:

1. Clone this repository:
```bash
git clone <repository-url> ~/Dev/dotfiles
```

2. Run the bootstrap script:
```bash
cd ~/Dev/dotfiles
zsh init.zsh
```

The script will:
- Create symbolic links for all config files
- Configure git to use the global gitignore
- Install Nerd Font for Neovim icons (macOS with Homebrew)

## What Gets Symlinked

| Source | Target |
|--------|--------|
| `zshrc` | `~/.zshrc` |
| `tmux.conf` | `~/.tmux.conf` |
| `gitignore_global` | `~/.gitignore_global` |
| `nvim/` | `~/.config/nvim` |
| `alacritty.toml` | `~/.config/alacritty/alacritty.toml` |

## Prerequisites

### Required
- **Zsh** - Primary shell
- **Neovim** (0.11+) - Primary editor with Lua configuration
- **Tmux** - Terminal multiplexer
- **Git** - Version control
- **Alacritty** - Terminal emulator

### Optional but Recommended
- **Homebrew** - For automatic font installation
- **Antigen** - Zsh plugin manager (install to `~/.zsh/antigen.zsh`)
- **aws-vault** - For AWS credential management
- **ripgrep** - For fast searching in Neovim

## Shell Aliases

| Alias | Action |
|-------|--------|
| `dotfiles` | Re-run the bootstrap script |
| `reload-alacritty` | Reload Alacritty config |
| `av <profile> <cmd>` | Run AWS CLI with aws-vault |

## Neovim

Modern Lua-based config using lazy.nvim for plugin management.

### Plugins
- **telescope.nvim** - Fuzzy finder
- **nvim-tree.lua** - File explorer
- **Native LSP** - Language server support (Neovim 0.11+ API)
- **nvim-treesitter** - Syntax highlighting
- **gitsigns.nvim** - Git gutter signs
- **lualine.nvim** - Status line
- **vim-test** - Test runner
- **conform.nvim** - Code formatting
- **nvim-cmp** - Autocompletion
- **catppuccin** - Colorscheme
- **mini.icons** - File icons
- **vim-fugitive** - Git commands

### Key Bindings

Leader key is `,`

| Binding | Action |
|---------|--------|
| `,w` | Save file |
| `,n` | Find current file in tree |
| `,sa` | Live grep |
| `,tn` | Run nearest test |
| `,tt` | Run test file |
| `,pp` | Format file |
| `Ctrl+n` | Toggle file tree |
| `Ctrl+p` | Find files |
| `gd` | Go to definition |
| `K` | Hover documentation |

### First Launch
Run `nvim` after setup - lazy.nvim will automatically install all plugins.

## Tmux

- **Prefix**: `Ctrl+a` (not `Ctrl+b`)
- **Mouse**: Enabled
- **Copy mode**: Vi keybindings

## File Structure

```
dotfiles/
├── README.md           # This file
├── CLAUDE.md           # Instructions for AI assistants
├── init.zsh            # Bootstrap script
├── zshrc               # Zsh configuration
├── tmux.conf           # Tmux configuration
├── alacritty.toml      # Alacritty terminal config
├── gitignore_global    # Global git ignore patterns
├── .gitignore          # Repo-specific ignores
└── nvim/               # Neovim configuration
    ├── init.lua
    └── lua/
        ├── options.lua
        ├── keymaps.lua
        └── plugins/
            ├── init.lua
            ├── catppuccin.lua
            ├── telescope.lua
            ├── nvim-tree.lua
            ├── lsp.lua
            ├── treesitter.lua
            ├── gitsigns.lua
            ├── lualine.lua
            └── neotest.lua
```

## Notes

- Neovim opens nvim-tree automatically when opening a directory
- Tmux auto-attach skips VS Code and Cursor terminals
- Run `:Lazy` in Neovim to manage plugins
- Run `:Mason` in Neovim to install LSP servers
