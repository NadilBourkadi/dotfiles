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
| `starship.toml` | `~/.config/starship.toml` |

## Prerequisites

### Required
- **Zsh** - Primary shell
- **Neovim** (0.11+) - Primary editor with Lua configuration
- **Tmux** - Terminal multiplexer
- **Git** - Version control
- **Alacritty** - Terminal emulator

### Optional but Recommended
- **Homebrew** - For automatic dependency installation
- **Antigen** - Zsh plugin manager (install to `~/.zsh/antigen.zsh`)
- **aws-vault** - For AWS credential management
- **ripgrep** - For fast searching in Neovim
- **Claude CLI** - For shell `ask`/`explain` functions (uses OAuth, no API key needed)

### Auto-installed by init.zsh (macOS with Homebrew)
- **Hack Nerd Font** - Icons in Neovim
- **tree-sitter-cli** - Required by nvim-treesitter for compiling parsers
- **Starship** - Cross-shell prompt
- **TPM** - Tmux Plugin Manager (press `prefix + I` in tmux to install plugins)

## Shell Aliases

| Alias | Action |
|-------|--------|
| `dotfiles` | Re-run the bootstrap script |
| `reload` | Reload zshrc |
| `reload-alacritty` | Reload Alacritty config |
| `av <profile> <cmd>` | Run AWS CLI with aws-vault |
| `ask "question"` | Ask Claude a question (supports piped input) |
| `explain <file>` | Get Claude to explain code (supports piped input) |

## Neovim

Modern Lua-based config using lazy.nvim for plugin management.

### Plugins
- **telescope.nvim** - Fuzzy finder
- **nvim-tree.lua** - File explorer
- **Native LSP** - Language server support (Neovim 0.11+ API)
- **nvim-treesitter** - Syntax highlighting
- **gitsigns.nvim** - Git gutter signs
- **lualine.nvim** - Status line
- **vim-test** - Test runner with gutter indicators
- **conform.nvim** - Code formatting
- **nvim-cmp** - Autocompletion
- **catppuccin** - Colorscheme
- **bufferline.nvim** - Prominent tab display
- **mini.icons** - File icons
- **vim-fugitive** - Git commands
- **nvim-ufo** - Better folding with preview
- **persistence.nvim** - Session management
- **copilot.vim** - GitHub Copilot AI autocomplete
- **todo-comments.nvim** - Highlight and search TODO/FIXME comments
- **indent-blankline.nvim** - Vertical indent guides
- **dressing.nvim** - Improved vim.ui interfaces
- **nvim-dap** - Debug Adapter Protocol with Python support
- **nvim-lint** - Async linting (mypy, flake8)
- **LuaSnip** - Snippet engine with custom Python snippets
- **neogen** - Google-style docstring generation
- **nvim-coverage** - Test coverage display in gutter
- **lsp_signature.nvim** - Function signature help
- **other.nvim** - Source/test file switching

### Key Bindings

Leader key is `,`

#### General

| Binding | Action |
|---------|--------|
| `,w` | Save file |
| `,qq` | Save all and quit |
| `,rs` | Restart Neovim (preserves session, tmux only) |
| `,se` | Edit init.lua config |
| `,dw` | Delete trailing whitespace |
| `,y` | Yank to system clipboard (visual mode) |
| `,pi` | Open Lazy plugin manager |
| `Ctrl+m` | Insert newline without entering insert mode |
| `j/k` | Move by visual line (screen line) |

#### File Navigation

| Binding | Action |
|---------|--------|
| `Ctrl+p` | Find files |
| `Ctrl+n` | Toggle file tree |
| `,n` | Find current file in tree |
| `,sa` | Live grep (search all) |
| `,sw` | Grep word under cursor |
| `,fb` | Find buffers |
| `,fh` | Find help tags |
| `,fr` | Find recent files |
| `,gf` | Find git files |
| `,sp` | Resume last search |

#### Tab Navigation

| Binding | Action |
|---------|--------|
| `Ctrl+h` | Previous tab |
| `Ctrl+l` | Next tab |
| `Shift+Left` | Move tab left |
| `Shift+Right` | Move tab right |
| `,<Tab>` | Last active tab |

#### LSP

| Binding | Action |
|---------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `,rn` | Rename symbol |
| `,ca` | Code action |
| `,ll` | Show line diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `,pp` | Format file |
| `,ih` | Toggle inlay hints |

#### Git (gitsigns)

| Binding | Action |
|---------|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `,hs` | Stage hunk |
| `,hr` | Reset hunk |
| `,hS` | Stage buffer |
| `,hu` | Undo stage hunk |
| `,hR` | Reset buffer |
| `,hp` | Preview hunk |
| `,hb` | Blame line (full) |
| `,hd` | Diff this |
| `,hD` | Diff this ~ |
| `,tb` | Toggle line blame (enabled by default) |
| `,td` | Toggle deleted |

#### TODOs (todo-comments)

| Binding | Action |
|---------|--------|
| `]t` | Next TODO |
| `[t` | Previous TODO |
| `,ft` | Find all TODOs |

#### Git (vim-fugitive)

| Binding | Action |
|---------|--------|
| `,gs` | Git status |
| `,gd` | Git diff |
| `,gb` | Git blame |
| `,gl` | Git log |

#### Testing (vim-test)

| Binding | Action |
|---------|--------|
| `,tn` | Run nearest test |
| `,tt` | Run test file |
| `,ts` | Run test suite |
| `,tl` | Run last test |
| `,tv` | Visit test file |
| `,tr` | Refresh test gutter signs |
| `,tc` | Close test pane and clear signs |

#### Sessions (persistence)

| Binding | Action |
|---------|--------|
| `,sr` | Restore session (current directory) |
| `,sl` | Restore last session |
| `,sd` | Don't save current session |

#### Folding (nvim-ufo)

| Binding | Action |
|---------|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek folded lines |

#### Quickfix

| Binding | Action |
|---------|--------|
| `,cv` | Open quickfix vertically |
| `,co` | Open quickfix horizontally |
| `,cc` | Close quickfix |

#### Debug (nvim-dap)

| Binding | Action |
|---------|--------|
| `,db` | Toggle breakpoint |
| `,dB` | Conditional breakpoint |
| `,dc` | Continue |
| `,di` | Step into |
| `,do` | Step over |
| `,dO` | Step out |
| `,dr` | Open REPL |
| `,dl` | Run last |
| `,du` | Toggle DAP UI |
| `,dt` | Terminate |
| `,dq` | Quit and reset (terminate + close UI + clear breakpoints) |
| `,de` | Evaluate expression |

#### Docstrings (neogen)

| Binding | Action |
|---------|--------|
| `,nf` | Generate function docstring |
| `,nc` | Generate class docstring |

#### Coverage

| Binding | Action |
|---------|--------|
| `,Tc` | Toggle coverage |
| `,Ts` | Coverage summary |
| `,Tl` | Load coverage |

#### Diagnostics (telescope)

| Binding | Action |
|---------|--------|
| `,xd` | All diagnostics |
| `,xD` | Buffer diagnostics |

#### Symbols (telescope)

| Binding | Action |
|---------|--------|
| `,fs` | Workspace symbols |
| `,fd` | Document symbols |
| `,ci` | Incoming calls |
| `,cr` | Outgoing calls |

#### Source/Test Switching

| Binding | Action |
|---------|--------|
| `,oo` | Switch to other file |
| `,os` | Other in split |
| `,ov` | Other in vsplit |

#### Snippets (LuaSnip)

| Binding | Action |
|---------|--------|
| `Ctrl+k` | Jump to next placeholder |
| `Ctrl+j` | Jump to previous placeholder |

Custom Python snippets: `docg` (Google docstring), `testfn` (pytest test), `faroute` (FastAPI route), `fixture` (pytest fixture).

### First Launch
Run `nvim` after setup - lazy.nvim will automatically install all plugins.

## Tmux

- **Prefix**: `Ctrl+a` (not `Ctrl+b`)
- **Mouse**: Enabled
- **Copy mode**: Vi keybindings

| Binding | Action |
|---------|--------|
| `Ctrl+a "` | Split pane vertically (same directory) |
| `Ctrl+a %` | Split pane horizontally (same directory) |
| `Ctrl+a c` | New window (same directory) |
| `Ctrl+a r` | Reload tmux config |

## File Structure

```
dotfiles/
├── README.md           # This file
├── CLAUDE.md           # Instructions for AI assistants
├── init.zsh            # Bootstrap script
├── zshrc               # Zsh configuration
├── tmux.conf           # Tmux configuration
├── alacritty.toml      # Alacritty terminal config
├── starship.toml       # Starship prompt config
├── gitignore_global    # Global git ignore patterns
├── .gitignore          # Repo-specific ignores
└── nvim/               # Neovim configuration
    ├── init.lua
    └── lua/
        ├── core/           # Core configuration
        │   ├── options.lua     # Editor options
        │   ├── keymaps.lua     # Global keybindings
        │   └── utils.lua       # Shared utilities
        └── plugins/        # Plugin configurations
            ├── init.lua
            ├── bufferline.lua
            ├── catppuccin.lua
            ├── telescope.lua
            ├── nvim-tree.lua
            ├── lsp.lua
            ├── treesitter.lua
            ├── gitsigns.lua
            ├── lualine.lua
            ├── vim-test.lua
            ├── ufo.lua
            ├── persistence.lua
            ├── copilot.lua
            ├── todo-comments.lua
            ├── indent-blankline.lua
            ├── dressing.lua
            ├── dap.lua
            ├── neogen.lua
            ├── lint.lua
            ├── luasnip.lua
            ├── coverage.lua
            ├── signature.lua
            └── other.lua
```

## Notes

- Neovim opens nvim-tree automatically when opening a directory
- Tmux auto-attach skips VS Code and Cursor terminals
- Run `:Lazy` in Neovim to manage plugins
- Run `:Mason` in Neovim to install LSP servers
