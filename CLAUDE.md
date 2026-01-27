# Claude AI Instructions

> **This file is local-only (gitignored) and exists to help AI assistants work effectively on this repo.**
>
> **YOU MUST keep this file updated.** When you learn something new, encounter a gotcha, or establish a pattern - add it here immediately. Future Claude agents depend on this being accurate and comprehensive.

## File Maintenance

**Keep this file lean and useful.** When adding or reviewing content:

- **Be concise**: Bullet points, not paragraphs. One line per gotcha when possible.
- **Remove stale info**: If a plugin/tool is removed, delete its notes. If a gotcha is fixed upstream, remove it.
- **Consolidate duplicates**: Merge related items rather than adding new sections.
- **Prune periodically**: If a section grows beyond ~10 items, review and trim the obvious/outdated ones.
- **No tutorials**: Document gotchas and exceptions, not standard usage. Assume the reader knows the tools.

**When in doubt, ask:** "Would a competent developer working on this repo need to know this?" If not, don't add it.

## Critical Context

### Repository Location
The repo lives at `~/Dev/dotfiles`, **NOT** `~/dotfiles`. Always use the full path in scripts and symlinks.

### Neovim Version
Using **Neovim 0.11+** which has breaking API changes:
- Use `vim.lsp.config()` and `vim.lsp.enable()` for LSP, NOT `require('lspconfig')`
- The old `nvim-treesitter.configs` module is deprecated
- Use native `vim.treesitter.start()` for highlighting
- `vim.treesitter.language.ft_to_lang` removed → use `get_lang` (shim in init.lua for plugin compat)

### Neovim Directory Structure
Core config lives in `nvim/lua/core/`, plugins in `nvim/lua/plugins/`:
- `core/options.lua` - Editor options (tabs, line numbers, etc.)
- `core/keymaps.lua` - Global keybindings
- `core/utils.lua` - Shared utility functions (state file helpers, nvim-tree state)
- `plugins/*.lua` - One file per plugin

### Symlink Gotchas
When symlinking directories, always `rm -f` before `ln -s`:
```bash
rm -f ~/.config/nvim
ln -s ~/Dev/dotfiles/nvim ~/.config/nvim
```
Using `ln -sf` on an existing symlink creates a circular symlink inside the target directory (e.g., `nvim/nvim`).

### File Naming Conventions
- `gitignore_global` → Global gitignore (symlinked to `~/.gitignore_global`)
- `.gitignore` → Repo-specific ignores only (not duplicating global patterns)
- `CLAUDE.md` → This file, gitignored globally, local-only

## Patterns to Follow

### Adding New Config Files
1. Add the config file to the repo root (e.g., `alacritty.toml`)
2. Update `init.zsh` to symlink it with an echo statement and green "Done" output
3. Update README.md with the new file in the structure and any relevant documentation

### Adding New Dependencies
**NEVER install manually.** All installations must go through `init.zsh` for repeatability:
1. Add installation logic to `init.zsh` (with idempotent check, e.g., `if ! command -v foo`)
2. Run `dotfiles` alias to install
3. Update README.md prerequisites section

### init.zsh Style
- Echo what's happening at each step
- Use green "Done" output: `echo "${GREEN}Done${NC}"`
- Use `echo -n` for the action, then echo Done after

### Commit Message Style
- Use a concise summary line in imperative mood (e.g., "Remove legacy vimrc")
- Include a bulleted list of changes in the body
- Example:
  ```
  Remove legacy vimrc and unused i3config plugin

  - Delete vimrc file
  - Remove vimrc symlink from init.zsh
  - Remove i3config.vim plugin from nvim/lua/plugins/init.lua
  - Update README.md to remove vimrc references
  ```

### Neovim Plugin Config Style
- Each plugin gets its own file in `nvim/lua/plugins/`
- Use `lazy = false` for plugins that need to load immediately
- Define keymaps inside the plugin's config function
- Use `<cmd>...<CR>` syntax for command mappings

## Common Mistakes to Avoid

1. **Wrong repo path**: Always `~/Dev/dotfiles`, never `~/dotfiles`
2. **Old Neovim APIs**: Don't use `require('lspconfig')` or `require('nvim-treesitter.configs')`
3. **Symlink -f flag on directories**: Causes circular symlinks
4. **Duplicating global gitignore**: Keep `.gitignore` repo-specific only
5. **Co-author lines in commits**: Do NOT add `Co-Authored-By` lines to commit messages
6. **Forgetting README updates**: When adding keybindings, aliases, plugins, or features - update README.md immediately as part of the same task, not as a follow-up
7. **Manual installations**: NEVER run installation commands directly (e.g., `git clone`, `brew install`). Always add to `init.zsh` and run `dotfiles` alias. This keeps setup repeatable across machines.

## Documentation Maintenance

### Enforcement Rule
**When making code changes, include README/CLAUDE.md edits in the SAME tool call batch** - not in a follow-up message. This ensures documentation is never forgotten.

### Pre-completion Checklist
Before marking any task complete, verify:
- [ ] README updated (if adding keybindings, plugins, aliases, or config files)
- [ ] CLAUDE.md updated (if learned a gotcha, quirk, or new pattern)

### README.md (tracked in git)
**CRITICAL: README updates are MANDATORY, not optional.** When you make any of the following changes, you MUST update README.md in the same task - do not wait to be asked:
- Adding/removing config files → Update "What Gets Symlinked" and "File Structure"
- Adding keybindings → Update the relevant keybindings table (Neovim/Tmux)
- Adding shell aliases or functions → Update "Shell Aliases" table
- Adding plugins → Update "Plugins" list
- Changing prerequisites → Update "Prerequisites" section
- Changing installation steps → Update "Installation" section

**This is not a separate follow-up task.** Include README updates as part of implementing any feature.

### CLAUDE.md (this file, local-only)
**⚠️ MANDATORY: Update this file DURING the task, not after.**

After completing ANY of these, IMMEDIATELY add to CLAUDE.md before moving on:
- Fixed a bug or unexpected behavior → Add to "Common Mistakes to Avoid"
- Discovered a CLI flag or API quirk → Add to "Gotchas" section
- Added a new plugin or tool → Document any setup requirements
- Found that something works differently than expected → Document it

**Concrete examples of when to update:**
- "I had to use `-d` instead of `-c` for tmux popups" → Add to Gotchas
- "nvim-ufo requires specific fold options" → Document in Patterns
- "This API changed in version X" → Add to version-specific notes

**This is NOT optional.** Treat CLAUDE.md updates like README updates - they are part of the task, not a follow-up.

## Tmux Gotchas

### Directory flags differ by command
- `split-window` / `new-window`: Use `-c "#{pane_current_path}"`
- `display-popup`: Use `-d "#{pane_current_path}"` (NOT `-c`)

### respawn-pane behavior
- `respawn-pane -k` sends SIGTERM (not SIGKILL), so VimLeavePre autocmds still fire
- To keep pane alive after nvim exits: `respawn-pane -k -c <dir> 'zsh -c "nvim; exec zsh"'`

## Neovim Plugin Notes

### nvim-ufo (folding)
Requires these options to be set in the plugin config:
```lua
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
```

### persistence.nvim (sessions)
- **nvim-tree doesn't restore well from sessions** - must be closed before saving and reopened after loading via separate state file
- State file stored at `~/.local/state/nvim/sessions/<path>.state`
- `<leader>rs` restart sets `vim.g.nvim_restarting = true` flag so VimLeavePre doesn't overwrite the state file
- nvim-tree state logic is centralized in `core/utils.lua` - both persistence.lua and keymaps.lua use it

### lazy.nvim
- **Config re-sourcing not supported** - `:source $MYVIMRC` doesn't work; use `<leader>rs` to restart instead
- Don't add `<leader>ss` style source mappings - they'll error

### Mason + Native LSP
- Mason installs servers to `~/.local/share/nvim/mason/bin/` which is NOT in PATH by default
- Must add Mason bin to PATH before calling `vim.lsp.enable()` or servers won't be found
- `vim.lsp.config()` needs explicit `cmd`, `filetypes`, and `root_markers` for servers to attach
- The check `vim.lsp.get_clients({ bufnr = 0 })` returning empty means LSP didn't attach

### Pyright + Poetry
- Pyright auto-detects Poetry venvs via async `on_init` callback in lsp.lua
- Checks for `[tool.poetry]` in pyproject.toml, then runs `poetry env info --path` via `vim.system()` (async)
- Sets `python.pythonPath` to the venv's Python executable
- No need for `pyrightconfig.json` in each project
- **Poetry venv paths are cached per project root** in both lsp.lua and lint.lua to avoid repeated shell calls
- Use `vim.system()` (async) instead of `vim.fn.system()` (blocking) for Poetry lookups — `poetry env info` is slow (200-500ms)

## Debugging Neovim Config

### Prefer headless mode for faster iteration
Use `nvim --headless` to test config without opening a full editor:

```bash
# Check if a value is set correctly
nvim --headless -c "lua print(vim.env.PATH:match('mason/bin') and 'found' or 'missing')" -c "qa" 2>&1

# Check if an executable is found
nvim --headless -c "lua print(vim.fn.exepath('pyright-langserver'))" -c "qa" 2>&1

# Test that config loads without errors
nvim --headless -c "echo 'Config loaded'" -c "qa" 2>&1

# Run Lazy sync
nvim --headless "+Lazy! sync" +qa 2>/dev/null
```

### Interactive debugging (when headless isn't enough)
```vim
:lua print(#vim.lsp.get_clients({ bufnr = 0 }))   " Check LSP attached
:lua vim.print(vim.lsp.get_clients())             " Full LSP client info
:checkhealth lsp                                   " LSP health check
```

### vim-test
- `test#neovim#term_position` controls terminal size: `"botright " .. math.floor(vim.o.lines / 3)` for 1/3 height
- `test#neovim#start_normal = 1` keeps terminal in normal mode after test (allows scrolling)

### neotest (avoided)
**Do not use neotest** - it has fundamental architecture issues:
- Spawns a subprocess with `-u NONE` (no user config) for treesitter parsing
- That subprocess can't find parsers installed by nvim-treesitter (wrong runtimepath)
- Causes "No parser for language X" errors that can't be fixed without hacking the plugin
- The `nvim-treesitter.configs` module is removed in newer nvim-treesitter versions
- vim-test is simpler and more reliable for running tests

### nvim-treesitter
- **Don't use `require('nvim-treesitter.configs')`** - module removed in newer versions
- Neovim 0.11+ ships with built-in parsers (lua, vim, vimdoc, markdown, c, query) in `/opt/homebrew/Cellar/neovim/*/lib/nvim/parser/`
- Additional parsers from nvim-treesitter go elsewhere and may not be found by other tools
- For highlighting, use native `vim.treesitter.start()` not nvim-treesitter's highlight module
