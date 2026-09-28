# Dotfiles Configuration

Personal dotfiles for a development environment.

## Installation

One-time setup for a new machine:

1. On Linux/WSL only — install git, zsh, and the Homebrew build prerequisites
   (macOS already ships git/zsh and is expected to have Homebrew installed):
```bash
sudo apt-get install -y zsh git build-essential curl file procps
```

2. Clone this repository:
```bash
git clone <repository-url> ~/Dev/dotfiles
```

3. Run the bootstrap script:
```bash
cd ~/Dev/dotfiles
zsh init.zsh
```

The script will:
- Create symbolic links for all config files
- Configure git to use the global gitignore
- Install Homebrew itself on Linux, then dependencies via `brew bundle` on both OSes
- Install nvm + Node.js LTS (needed by copilot.vim and Mason's npm-based servers)
- Install Alacritty from GitHub releases (macOS)
- Change the login shell to zsh (Linux)

## What Gets Symlinked

| Source | Target |
|--------|--------|
| `zshrc` | `~/.zshrc` |
| `tmux.conf` | `~/.tmux.conf` |
| `gitignore_global` | `~/.gitignore_global` |
| `nvim/` | `~/.config/nvim` |
| `alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| `alacritty/theme.toml` | `~/.config/alacritty/theme.toml` |
| `starship.toml` | `~/.config/starship.toml` |
| `bin/claude-statusbar-hook` | `~/.local/bin/claude-statusbar-hook` |
| `bin/claude-statusbar-status` | `~/.local/bin/claude-statusbar-status` |
| `bin/alacritty-windows-sync` | `~/.local/bin/alacritty-windows-sync` |

`alacritty.toml` imports `theme.toml` through its symlink, so the repo can be
cloned anywhere — but that means **pulling a change to the Alacritty config
needs one `dotfiles` (init.zsh) run** before the palette applies; until then
Alacritty falls back to its defaults. Requires Alacritty 0.14+ (`[general]
import`); `init.zsh` warns if it finds an older one, so re-run it after
installing Alacritty on Linux. On WSL the Windows config is **generated**
rather than symlinked — see [WSL](#wsl-windows-subsystem-for-linux).

Files under `private/` (gitignored) are symlinked separately if the directory exists:

| Source | Target |
|--------|--------|
| `private/believ/claude-settings.json` | `~/.claude/settings.json` |

## Prerequisites

### Required
- **Zsh** - Primary shell (`sudo apt-get install zsh` on Linux; macOS ships it)
- **Git** - Version control
- **Homebrew** - macOS: install manually first; Linux: init.zsh installs it automatically

### Optional
- **aws-vault** - For AWS credential management (`av` shell function)
### Auto-installed by init.zsh (both macOS and Linux)
- **Alacritty** - Terminal emulator (macOS only)
- **Tmux** - Terminal multiplexer
- **OpenSSH server** - Remote access to the tmux session (native Linux only, via apt; see [Remote access](#remote-access-ssh-into-tmux))
- **Neovim** (0.11+) - Primary editor
- **tree-sitter-cli** - Required by nvim-treesitter
- **ripgrep** - Fast searching for Telescope
- **fd** - Fast file finder for Telescope
- **jq** - JSON processor (used by Claude Code status bar scripts)
- **Pandoc** - Document conversion (markdown to HTML export)
- **Starship** - Cross-shell prompt
- **Lazygit** - Terminal UI for git
- **Harlequin** - Terminal SQL IDE (PostgreSQL, MySQL, SQLite, DuckDB)
- **Hack Nerd Font** - Icons in Neovim (macOS: Homebrew cask; native Linux: downloaded to `~/.local/share/fonts` by `init.zsh`; WSL: install it on Windows, see below)
- **nvm + Node.js LTS** - Via the nvm installer script, not Homebrew (needed by copilot.vim and Mason's npm-based servers)
- **Zinit** - Zsh plugin manager (auto-installs on first shell launch)
- **TPM** - Tmux Plugin Manager (press `prefix + I` to install plugins)

## WSL (Windows Subsystem for Linux)

The bootstrap works unchanged inside a WSL Ubuntu distro. Windows-side specifics:

- **Nerd Font**: the terminal renders on Windows, so install
  [Hack Nerd Font](https://www.nerdfonts.com/font-downloads) *on Windows*
  (unzip, select the `.ttf` files, right-click → Install), then set
  `Hack Nerd Font` as the font face in your Windows Terminal profile.
- **Clipboard**: WSLg's Wayland clipboard bridges to Windows automatically;
  `wl-clipboard` (installed via apt by init.zsh) makes nvim's `"+y` and
  tmux-yank use it.
- **Alacritty**: `init.zsh` installs the *Windows* build via winget and
  configures it to launch straight into WSL. The config is **generated**, not
  symlinked:

  | | |
  |---|---|
  | Source of truth | `alacritty/theme.toml` (shared colours) + `alacritty/windows.toml` (Windows overrides) |
  | Generated to | `%APPDATA%\alacritty\alacritty.toml` |
  | By | `bin/alacritty-windows-sync`, run from `init.zsh` and on interactive shell startup |

  A symlink is not possible: one created from WSL onto `/mnt/c` is an LX
  reparse point that native Windows apps cannot follow, and a Windows-native
  symlink into `\\wsl.localhost` needs admin *and* makes Alacritty's config
  read depend on the WSL VM already running — at cold boot that risks losing
  `[terminal.shell]` and dropping you into `cmd.exe`.

  The practical consequence: after a `git pull`, the Windows config updates on
  your **next shell**, not instantly as on macOS. Run
  `alacritty-windows-sync --force` to apply it immediately.

  An existing hand-written `%APPDATA%\alacritty\alacritty.toml` is copied to
  `alacritty.toml.pre-dotfiles.bak` before being replaced.
- **OOM protection**: a runaway process can exhaust the VM's RAM and swap
  faster than the kernel OOM killer reacts, livelocking WSL until a
  `wsl --shutdown`. Two guards, both set up by `init.zsh`:
  - `earlyoom` (apt) kills the largest process while there is still ~10%
    memory/swap headroom, before the thrash starts.
  - `wslconfig` is **copied** (same symlink caveat as Alacritty) to
    `%USERPROFILE%\.wslconfig` — larger swap plus `autoMemoryReclaim`. A
    pre-existing hand-written `.wslconfig` is backed up once to
    `.wslconfig.pre-dotfiles.bak`. Unlike the Alacritty config there is no
    shell-startup sync: after editing `wslconfig`, re-run `init.zsh`, then
    `wsl --shutdown` to apply.
- **Icons must stay out of the Plane-15 private use area.**
  Alacritty allocates two cells for U+F0000+ codepoints while tmux and Neovim
  both count one. There is no standard to appeal to — UAX #11 calls that range
  *Ambiguous*, exactly like the basic-plane PUA that Alacritty draws in one
  cell — so the behaviour is Alacritty's own, established here by a CSI 6n
  probe. The font variant is not the lever either (Alacritty decides width from
  the codepoint, so `Hack Nerd Font Mono` does not help); use basic-plane
  equivalents (U+E000-U+F8FF) instead. Windows Terminal hides the mismatch by
  clamping glyphs to the cell grid, which is why this only shows up in
  Alacritty. It bites in two places:
  - **tmux status line** — right-aligned, so it renders wider than reserved,
    spills past the right edge and wraps, leaving a copy behind on every
    refresh.
  - **Neovim** — every such glyph pushes the rest of its line a column right,
    so markdown table borders stop lining up with their header and file-tree
    names sit at ragged columns. `nvim/lua/core/icons.lua` holds the helpers.
    mini.icons and render-markdown have their defaults swept through it, so
    glyphs upstream adds later are caught; which-key is part swept (its icon
    rules and plugin specs) and part hand-written (the 24 key labels), and
    nvim-tree's two offenders are hand-overridden in `plugins/nvim-tree.lua`.
    The hand-written parts are *not* future-proof — which-key at least warns
    at startup if a Plane-15 key glyph reappears. See the module header for
    why `ambiwidth` and `setcellwidths()` are both the wrong lever.
- **Console login session**: WSL runs systemd (`systemd=true` in
  `/etc/wsl.conf`), which logs you into a console tty on every boot in
  addition to your terminal. That extra shell sources `zshrc`, so tmux
  auto-attach skips it — otherwise it would race your terminal to start tmux,
  and tmux-continuum (which counts raw `tmux` *client* processes to decide
  whether another server is running) would silently disable session
  save/restore.

## Shell Aliases

| Alias | Action |
|-------|--------|
| `dotfiles` | Re-run the bootstrap script |
| `reload` | Reload zshrc |
| `reload-alacritty` | Reload Alacritty config |
| `av <profile> <cmd>` | Run AWS CLI with aws-vault |
| `kill-orphan-nvims` | Kill nvim processes not attached to any tmux pane (`--dry-run` to preview) |

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
- **diffview.nvim** - Side-by-side branch diff and file history
- **open-on-github** (custom) - Open file/line on GitHub
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
- **render-markdown.nvim** - In-buffer markdown rendering

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
| `,cp` | Copy absolute file path to clipboard |
| `,cP` | Copy relative file path to clipboard |
| `,pi` | Open Lazy plugin manager |
| `gx` | Open URL under cursor in browser |
| `j/k` | Move by visual line (screen line) |

#### File Navigation

| Binding | Action |
|---------|--------|
| `Ctrl+p` | Find files |
| `Ctrl+n` | Toggle file tree |
| `,n` | Find current file in tree |
| `,sa` | Live grep (search all, smart-case) |
| `,sg` | Live grep with glob filter (e.g. `!*.test.js` to exclude, `*.py` to include only) |
| `,sw` | Grep word under cursor |
| `,fb` | Find buffers |
| `,fh` | Find help tags |
| `,fr` | Find recent files |
| `,gf` | Find git files |
| `,sp` | Resume last search |

#### File Tree (nvim-tree)

These work when focused in the tree:

| Binding | Action |
|---------|--------|
| `Enter` | Open file |
| `Ctrl+v` | Open in vsplit |
| `Ctrl+x` | Open in split |
| `Ctrl+t` | Open in new tab |
| `a` | Create file (add `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `y` | Copy name |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |
| `g?` | Toggle help (show all keybindings) |

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

#### Git (diffview)

| Binding | Action |
|---------|--------|
| `,gv` | Diff working tree |
| `,gm` | Diff branch (vs master) |
| `,gh` | Current file history |
| `,gH` | Full branch history |
| `,gc` | Close diffview |

#### Git (open-on-github)

| Binding | Action |
|---------|--------|
| `,go` | Open line/selection on GitHub (default branch) |
| `,gO` | Open line/selection on GitHub (current commit) |

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
| `,af` | Generate function docstring |
| `,ac` | Generate class docstring |

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

#### Markdown

| Binding | Action |
|---------|--------|
| `,mp` | Toggle markdown preview |
| `,mh` | Preview markdown as HTML in browser |

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
| `Ctrl+a Ctrl+s` | Save session (tmux-resurrect) |
| `Ctrl+a Ctrl+r` | Restore session (tmux-resurrect) |

Sessions auto-save every 10 minutes via tmux-continuum and auto-restore when tmux starts. Nvim sessions are restored via persistence.nvim.

### Remote access (SSH into tmux)

On native Linux `init.zsh` installs `openssh-server`. An interactive login
lands in the running tmux session (the `zshrc` auto-attach), mirrored with the
local terminal; `scp`/`rsync`/`ssh host cmd` have no tty and skip it.

1. Run `init.zsh` on the server. While `~/.ssh/authorized_keys` is empty,
   password login stays on — it is needed to bootstrap the first key.
2. From the machine you connect from: `ssh-copy-id <user>@<hostname>.local`
   (mDNS name via avahi; use the IP if `.local` does not resolve).
3. Rerun `init.zsh`. With a key present it copies `sshd-hardening.conf` to
   `/etc/ssh/sshd_config.d/01-dotfiles.conf` (key-only, no root login).

If the connection times out on Wi-Fi, check for AP/client isolation on the
router. For a stable address, give the machine a DHCP reservation — it has a
different IP on wired and wireless.


### Claude Code status indicators

Two indicators surface the state of running Claude Code CLI instances:

- **Global count** (status-right): ` N waiting · M working` — turns red when any instance is waiting for input (permission prompt or idle). Refreshes every 5 seconds.
- **Per-window highlight**: the window name turns red+bold the instant a Claude instance in that window is waiting for input (pushed directly by the hook, no polling delay).

Both are driven by Claude Code hooks configured in `~/.claude/settings.json`. The hooks invoke `claude-statusbar-hook` on each event; tmux reads state from `~/.claude/statusbar/` via `claude-statusbar-status`.

Three things must all be true, and **each fails silently**:

1. **`jq` installed** — `claude-statusbar-hook` exits 0 without it (`brew bundle`).
2. **`~/.local/bin/claude-statusbar-{hook,status}` symlinked** — `init.zsh` does
   this; a missing script makes tmux's `#()` render as empty rather than error.
3. **Hooks present in `~/.claude/settings.json`** — on work machines these come
   from `private/believ/claude-settings.json`; without a `private/` directory
   add them directly. Events: `PreToolUse` (async), `Notification`, `Stop`,
   `SessionStart`, `UserPromptSubmit`, `SessionEnd`, each running
   `$HOME/.local/bin/claude-statusbar-hook <EventName>`.

Hooks load at session start, so a newly added hook needs `/hooks` or a restart.
Verify with `ls ~/.claude/statusbar/` — one JSON file per live session.

## File Structure

```
dotfiles/
├── README.md           # This file
├── CLAUDE.md           # Instructions for AI assistants
├── Brewfile            # Homebrew dependencies
├── init.zsh            # Bootstrap script (macOS + Linux)
├── zshrc               # Zsh configuration (sources zsh/*.zsh)
├── zsh/                # Modular Zsh config
│   ├── plugins.zsh        # Zinit setup + plugin loading
│   ├── theme.zsh          # Catppuccin Mocha colors + completion styling
│   ├── functions.zsh      # Shell functions (av, kill-orphan-nvims)
│   └── wsl.zsh            # WSL predicates (_is_wsl, _wsl_console_login)
├── tmux.conf           # Tmux configuration
├── bin/                # Helper scripts (symlinked to ~/.local/bin)
│   ├── claude-statusbar-hook    # Claude Code hook writer
│   ├── claude-statusbar-status  # Tmux status-right reader
│   └── alacritty-windows-sync   # Generates the Windows Alacritty config (WSL)
├── alacritty.toml      # Alacritty config for macOS / native Linux
├── wslconfig           # WSL2 VM settings, copied to %USERPROFILE%\.wslconfig
├── sshd-hardening.conf # Key-only sshd drop-in, copied to /etc/ssh/sshd_config.d/ (native Linux)
├── alacritty/
│   ├── theme.toml         # Catppuccin palette, shared by all platforms
│   └── windows.toml       # Windows overrides (WSL shell, decorations, size)
├── starship.toml       # Starship prompt config
├── gitignore_global    # Global git ignore patterns
├── .gitignore          # Repo-specific ignores
└── nvim/               # Neovim configuration
    ├── init.lua
    └── lua/
        ├── core/           # Core configuration
        │   ├── options.lua     # Editor options
        │   ├── keymaps.lua     # Global keybindings
        │   ├── utils.lua       # Shared utilities (root-finding, Poetry venv, nvim-tree state)
        │   ├── icons.lua       # Keeps icon glyphs out of the Plane-15 private use area
        │   └── test-signs.lua  # Pytest output parser and gutter signs
        └── plugins/        # Plugin configurations
            ├── init.lua
            ├── bufferline.lua
            ├── catppuccin.lua
            ├── completion.lua
            ├── telescope.lua
            ├── nvim-tree.lua
            ├── lsp.lua
            ├── formatting.lua
            ├── treesitter.lua
            ├── gitsigns.lua
            ├── diffview.lua
            ├── open-on-github.lua
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
            └── render-markdown.lua
```

## Private Extensions

Work-specific config (credentials, aliases) lives in the gitignored `private/` directory.

**Setup:**
1. Create `private/zshrc` with your functions and env vars:
   ```bash
   mkdir -p ~/Dev/dotfiles/private
   ```
2. The public `zshrc` sources `private/zshrc` if it exists. Silently skipped when absent.

## Notes

- Neovim opens nvim-tree automatically when opening a directory
- Tmux auto-attach skips VS Code and Cursor terminals, and WSL's console login session
- Run `:Lazy` in Neovim to manage plugins
- Run `:Mason` in Neovim to install LSP servers
