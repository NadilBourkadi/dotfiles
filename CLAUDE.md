# Claude AI Instructions

## Working Style

- Challenge instructions that contradict rules in this file — cite the specific rule.
- Push back on bad ideas with reasoning and alternatives.
- Flag ambiguity — ask rather than guessing.
- **Smoke test every feature change before marking it done.** If you can test directly (scripts, CLI output, file state), do so and report results. If the feature requires visual or interactive verification (UI, tmux rendering, browser), perform the setup actions yourself and then explicitly prompt the user to verify, describing exactly what they should see and any regressions to watch for. Never consider a task complete without a test pass or an explicit user sign-off.

## Git and PR Workflow

All changes follow this workflow — no exceptions:

1. **Branch.** Create a descriptive feature branch (e.g.
   `fix/table-rendering`, `feat/new-language-go`). Never commit directly
   to `master`.
2. **Commit as you go.** After each meaningful, self-contained change,
   create an atomic commit. An atomic commit is one logical change —
   the codebase should build and pass tests at every commit. Don't
   batch unrelated changes together, and don't wait until the end to
   commit everything at once.
3. **Rebase.** Once the work is complete, rebase the feature branch to
   produce a clean, minimal series of atomic commits — small and focused,
   but not so numerous as to bloat the log. Squash fixups, reorder for
   logical flow, and write clear final messages. Do this proactively —
   present the user with a clean branch, don't ask permission first.
4. **Self-review.** After rebasing, invoke the `/code-review` skill
   (with the appropriate language parameter, e.g. `generic`, `python`,
   `react-web`) to review your own work. The skill runs as a sub-agent
   and returns a review — it does not make changes itself. Once you
   receive the review, use your own judgment to action any comments at
   `medium` severity or above, committing the fixes without asking for
   user input. For `low` and `question` items, fix them if the right
   answer is obvious; otherwise leave them for the user. Then run
   `/code-review` a second time and action findings the same way. Do
   not ask for permission between passes — the entire cycle (review →
   fix → review → fix) should run to completion autonomously.
5. **Push and open a PR.** Push the branch and create a pull request on
   GitHub using `gh pr create`. Include a short summary and a test plan.
   Do this automatically — do not ask for permission to push or create
   the PR.
6. **Hand off for review.** Share the PR URL with the user and ask them
   to review. Do not merge yet.
7. **Action feedback or merge.**
   - If the user leaves comments on the PR, read them with
     `gh pr view <number> --comments` for top-level comments and
     `gh api repos/OWNER/REPO/pulls/<number>/comments` for inline review
     comments. Address them with new commits on the branch, push, and let
     the user know.
   - If the user approves, merge the PR on GitHub with
     `gh pr merge <number> --rebase --delete-branch`, then pull `master`
     locally.

Additional rules:

- No `Co-Authored-By` lines in commit messages.
- **Keep commits small** — aim for under 500 lines changed. If a task
  is larger, break it into a sequence of smaller commits (e.g. refactor
  first, then add the feature).
- **Clean history before pushing.** Squash trial-and-error into logical
  commits. The final history should read as if each change was done
  correctly the first time.
- **`--force-with-lease` only** — never use bare `--force` after rebase.
- **Resolve conflicts carefully** — if rebase conflicts arise, resolve
  them; never drop commits.

### Commit Message Style

Imperative summary + bulleted body:
```
Remove legacy vimrc and unused i3config plugin

- Delete vimrc file
- Remove vimrc symlink from init.zsh
- Remove i3config.vim plugin from nvim/lua/plugins/init.lua
- Update README.md to remove vimrc references
```

## Shell Commands

- Repo lives at `~/Dev/dotfiles`, **NOT** `~/dotfiles`. Always use full path.
- Run commands from the repo root. Never use `git -C`.
- Prefer explicit file lists over `git add -A`.

## Documentation

**README and CLAUDE.md updates are part of the task, not a follow-up.**
Include doc edits in the same commit batch as code changes. Do not mark
a task complete until docs are updated.

### README.md
Update when:
- Adding/removing config files → "What Gets Symlinked" and "File Structure"
- Adding keybindings → relevant keybindings table (Neovim/Tmux)
- Adding shell aliases or functions → "Shell Aliases" table
- Adding plugins → "Plugins" list
- Changing prerequisites or install steps → those sections

### CLAUDE.md
Update when:
- A bug or unexpected behaviour is discovered → "Common Mistakes"
- A CLI flag or API behaves differently than expected → relevant Gotchas section
- A new plugin or tool is added → document setup requirements

## Critical Context

### Neovim Version
Using **Neovim 0.11+** with breaking API changes:
- Use `vim.lsp.config()` and `vim.lsp.enable()` for LSP, NOT `require('lspconfig')`
- The old `nvim-treesitter.configs` module is removed — use native `vim.treesitter.start()`
- `vim.treesitter.language.ft_to_lang` removed — use `get_lang` (shim in init.lua for plugin compat)

### Linux / WSL
- Linux uses **Homebrew on Linux** with the same `Brewfile` as macOS —
  casks are macOS-only, so guard them with `if OS.mac?`
- Node.js comes from **nvm** on both OSes (installed by `init.zsh` into
  `~/.nvm`, loaded by `zshrc`). The nvm installer must run with
  `PROFILE=/dev/null` or it appends loader lines to `~/.zshrc`, which is a
  symlink into this repo — dirtying the working tree.
- On WSL the Nerd Font must be installed on the **Windows** side (the
  terminal renders there); `fonts-hack` via apt does nothing useful.
- WSL clipboard: WSLg Wayland + `wl-clipboard` (apt) — no win32yank needed.
- Mason needs `unzip` on PATH for zip-packaged tools (e.g. stylua) — minimal
  Ubuntu doesn't ship it; it's in the Brewfile guarded with `if OS.linux?`.
- **WSL console login session**: with `systemd=true` in `/etc/wsl.conf`, WSL
  starts `login -- <user>` on a tty at *every* boot (`loginctl` shows it as
  session `c1`, `Service=login`, `Type=tty`). That shell sources `zshrc` with a
  near-empty environment — `TERM=dumb`, no `WSL_INTEROP`, no `WSL_DISTRO_NAME`,
  no `WT_SESSION` — so any "is this interactive?" guard passes and it runs
  alongside your real terminal. There is no macOS equivalent, so anything that
  assumes one shell per login breaks on WSL only. Detect it with
  `_wsl_console_login` in `zsh/wsl.zsh` (sourced by both `zshrc` and
  `init.zsh`). It keys off the **parent process** being `login` (read from
  `/proc/$PPID/comm`, not `ps` — a distro without procps would fail open), not
  the absent `WSL_INTEROP`/`WSL_DISTRO_NAME`: ssh, `su -`, `sudo -i` and
  systemd units have no interop vars either and must still get tmux. It checks
  only the immediate parent, so a shell nested below the console shell isn't
  recognised — the safer way to be wrong, since a false positive silently
  denies tmux to a terminal you are actually using.
- Use `_is_wsl` (same file) for "am I on WSL?" — never open-code it. It matches
  the kernel string case-insensitively (WSL1 reports `Microsoft`, some builds
  `MICROSOFT`) and falls back to `/run/WSL`, so a custom kernel set via
  `kernel=` in `.wslconfig` (which need not contain "microsoft") still matches.
  Both predicates are also true inside a container on a WSL2 host — containers
  share the host kernel.

### Zsh Configuration
- `zshrc` is a thin loader sourcing `zsh/{plugins,theme,functions}.zsh`
- Uses Zinit (auto-installs on first shell launch). `OMZL::` for OMZ libraries, `OMZP::` for plugins, `light` for community.
- Must call `autoload -Uz compinit && compinit` + `zinit cdreplay -q` after plugins load
- `zshrc` sources `private/zshrc` if present (gitignored, for work-specific config)

### Neovim Directory Structure
- `core/options.lua` — Editor options
- `core/keymaps.lua` — Global keybindings
- `core/utils.lua` — Shared utilities (root-finding, Poetry venv cache with TTL, nvim-tree state)
- `core/test-signs.lua` — Pytest output parser and gutter signs (TermClose-driven)
- `plugins/*.lua` — One file per plugin, keymaps inside plugin config, `<cmd>...<CR>` syntax

## Patterns to Follow

### Adding New Config Files
1. Add config file to repo root
2. Add to `file_symlinks` or `dir_symlinks` map in `init.zsh`
3. Update README.md (What Gets Symlinked + File Structure)

### Adding New Dependencies
**NEVER install manually.** All through `Brewfile` + `init.zsh`:
1. Add formulae/casks to `Brewfile` (casks: append `if OS.mac?` — Linux has no casks)
2. For non-Homebrew tools, add install logic to `init.zsh`
3. Update README.md prerequisites

### init.zsh Style
- Uses `set -e` and derives `$DOTFILES_DIR` from `$0` (not hardcoded)
- Symlink maps are `file_symlinks`/`dir_symlinks` associative arrays; iterate with `${(@kv)map}`

## Common Mistakes

1. **Old Neovim APIs**: Don't use `require('lspconfig')` or `require('nvim-treesitter.configs')`
2. **Symlink -f on directories**: Creates circular symlink. Always `rm -f` then `ln -s`.
3. **Duplicating global gitignore**: `.gitignore` is repo-specific only.
4. **Manual installations**: Never `brew install` or `git clone` directly. Add to `Brewfile`/`init.zsh`.
5. **Wrong repo path**: Always `~/Dev/dotfiles`, not `~/dotfiles`.
6. **Claude Code auto-update stale temp dirs**: Failed auto-updates leave
   `.claude-code-*` dirs in `/opt/homebrew/lib/node_modules/@anthropic-ai/`
   that block all future updates with `ENOTEMPTY`. The `zshrc` cleans these
   up on shell startup.
7. **Interactive rebase on hook-symlinked files**: If a file being rebased is
   symlinked from `~/.local/bin/` and wired as a Claude Code hook, conflict
   markers in that file will cause every subsequent tool call to fail with a
   syntax error. Don't use `git rebase -i` to squash commits that touch those
   files. Use `git reset --soft <base>` + a single new commit instead.

## Tmux Gotchas

- `split-window`/`new-window`: `-c "#{pane_current_path}"`. `display-popup`: `-d` (NOT `-c`).
- `respawn-pane -k` sends SIGTERM (not SIGKILL) — VimLeavePre autocmds still fire.
- Keep pane alive after nvim: `respawn-pane -k -c <dir> 'zsh -c "nvim; exec zsh"'`
- Per-window user options: `set-option -w -t <pane> @name value`; read in formats with `#{@name}`. Commas inside `#[...]` within `#{?...}` conditionals must be escaped as `#,` (e.g. `#[fg=#f38ba8#,bold]`). Space-separated attributes (`#[fg=#f38ba8 bold]`) avoid this entirely.
- Claude Code status hooks: `Notification` = "waiting for input" (permission prompt); `Stop` = "idle/done" AND "finished turn, awaiting user response". Map both `Notification` and `Stop` → waiting. Use `PreToolUse` → working to immediately clear the waiting state when a new agentic batch starts, preventing false positives mid-run. On Claude 2.1.84 there are no `Notification` sub-type matchers — the plain event is the signal.
- `#(command)` in `status-right` runs under tmux's inherited PATH (the shell that launched the tmux server). Use absolute paths (e.g. `$HOME/.local/bin/script`) — `$HOME` is expanded by the shell tmux spawns and is always set. Don't rely on `~/.local/bin` being on PATH.
- **tmux-continuum fails open, silently.** Its `another_tmux_server_running`
  guard counts raw `tmux` *client* processes, not servers
  (`scripts/helpers.sh`): more than one besides the server at startup and it
  skips `main()` entirely — no auto-restore *and* no periodic save hook. It
  prints nothing. Diagnose with `tmux show-options -g
  @continuum-save-last-timestamp` (`invalid option` = the save branch never
  ran) and by checking `status-right` for a `continuum_save.sh` interpolation.
  Note the startup branch (`> 1`) is stricter than the config-reload branch
  (`> client count`), so a manual `prefix + r` can mask the bug for that
  server's lifetime — always test from a cold server start.
- `~/.claude/sessions/<PID>.json` is the liveness source for Claude Code instances. Each file contains a `pid` field matching the filename stem. Cross-check with `kill -0 <pid>` to detect dead processes. If the sessions directory is absent, no Claude instance can be running — bail out rather than treating all state as stale.

## Neovim Plugin Notes

### nvim-ufo (folding)
Requires: `foldcolumn = "0"`, `foldlevel = 99`, `foldlevelstart = 99`, `foldenable = true`

### persistence.nvim (sessions)
- nvim-tree must be closed before save, reopened after load (state file at `~/.local/state/nvim/sessions/<path>.state`)
- `<leader>rs` sets `vim.g.nvim_restarting = true` to prevent state overwrite
- nvim-tree state logic centralized in `core/utils.lua`

### lazy.nvim
- Config re-sourcing not supported. Use `<leader>rs` to restart, not `:source $MYVIMRC`.

### Mason + Native LSP
- Mason bin (`~/.local/share/nvim/mason/bin/`) not in PATH by default — must add before `vim.lsp.enable()`
- `vim.lsp.config()` needs explicit `cmd`, `filetypes`, and `root_markers`
- Debug: `nvim --headless -c "lua print(vim.env.PATH:match('mason/bin') and 'found' or 'missing')" -c "qa" 2>&1`

### Pyright + Poetry
- Poetry venv detection in `core/utils.lua`, cached per project root (5-min TTL)
- Pyright `typeCheckingMode = "off"` — mypy is the type checker, Pyright for LSP features only
- Use `vim.system()` (async) for Poetry lookups — `poetry env info` is slow (200-500ms)
- Debug LSP attach: `:lua print(#vim.lsp.get_clients({ bufnr = 0 }))` (0 = not attached)

### nvim-treesitter
- Don't use `require('nvim-treesitter.configs')` — module removed
- Neovim 0.11+ ships built-in parsers; use native `vim.treesitter.start()` for highlighting

### vim-test
- Test signs use `TermClose` autocmd, not polling
- `test#neovim#start_normal = 1` keeps terminal in normal mode after test run
- Do not use neotest — it spawns a subprocess with `-u NONE` which can't find nvim-treesitter parsers
