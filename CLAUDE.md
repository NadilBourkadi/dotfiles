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
4. **Self-review.** After rebasing, review your own work with the
   **built-in `/code-review` skill at `medium` effort**. There is no
   language parameter any more — that was the old custom skill.

   **Invoke it as a skill, never via the `Workflow` tool.** The
   code-review *workflow* only defines `high`/`xhigh`/`max`: passing it
   `medium` or `low` does not lower the effort, it silently falls back
   to `high` **and** re-reads your argument as a free-form review
   target, so you get the full agent fan-out plus a junk instruction in
   every prompt. `medium` and `low` exist only on the inline path, which
   runs in-context without that fan-out. Call the skill and let it route.

   `medium` is the standing level for *every* change here. Only go to
   `high` if the user asks explicitly — it burns far more tokens without
   finding more of what actually breaks this repo.

   **Loop, terminating on severity — cap two passes.** This repo's
   changes are small; the loop exists because fix code is the
   least-reviewed code there is, not to grind:

   ```
   pass 1:  review the whole change   ->  apply  ->  commit
   pass 2:  review the FIX COMMITS only (/code-review medium <sha>)
   STOP when a pass returns no high and no medium findings.
   CAP: two passes. Going further needs a reason said out loud.
   ```

   **Terminate on severity, never on emptiness.** A review always finds
   something, so "loop until it comes back clean" never terminates.
   `low` and `question` findings do **not** re-trigger a pass — batch
   them into one sweep after the loop ends, and prefer the minimal edit
   (a comment over a rename, a docstring over a refactor).

   Action `medium` and above without asking. For `low`/`question`, fix
   them if the right answer is obvious; otherwise leave them for the
   user. **The condition decides — do not ask whether to run the next
   pass.** The whole cycle runs to completion autonomously.
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
Currently on **Neovim 0.12.4**; config targets **0.11+** with breaking API changes:
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
- **Windows-side config cannot be symlinked from WSL.** `ln -s` onto `/mnt/c`
  appears to succeed and looks like a symlink to `ls`, but it creates an
  `IO_REPARSE_TAG_LX_SYMLINK` reparse point that only WSL understands — a
  native Windows app reading it gets an `IOException`. The reverse (a Windows
  symlink into `\\wsl.localhost`) is readable but needs admin, since Developer
  Mode is off, and makes the app depend on the WSL VM being up. So anything
  Windows needs from this repo has to be **generated/copied** across, as
  `bin/alacritty-windows-sync` does. Note the cost: resolving `%APPDATA%` via
  `cmd.exe` is a ~200ms interop launch, which is why that script stamp-checks
  before doing anything on a shell-startup call.
- `winget` works over interop via `powershell.exe -NoProfile -Command "winget
  ..."`, but **must** be given `--source winget` — the default includes
  `msstore`, which aborts with "source agreements were not agreed to".
- `cmd.exe` warns when its cwd is a WSL path; run it from `/mnt/c` (`cd /mnt/c
  && cmd.exe /c ...`) and strip `\r` from its output.
- Alacritty for Windows is a GUI-subsystem binary: `--help` and config errors
  do **not** reach a redirected stdout/stderr from WSL. Use
  `Start-Process -RedirectStandardOutput` to capture output, and validate
  config files with a TOML parser rather than by running it.
- **"WSL crashed" is usually an OOM livelock, not a crash.** A runaway process
  (seen: a 14GB python3, a 14GB Claude Code worker) exhausts RAM + the default
  4GB swap and the VM thrashes until `wsl --shutdown`. Diagnose with
  `journalctl -b -1 | grep -i "out of memory"` — a journal "corrupted or
  uncleanly shut down" message on the next boot is the tell that the VM died
  hard. Guards: `earlyoom` (apt, via init.zsh) and repo-root `wslconfig`
  copied to `%USERPROFILE%\.wslconfig` by init.zsh (applies only after
  `wsl --shutdown`).
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
- **Don't test interactivity with `[ -n "$PS1" ]`** — that's a bash idiom. zsh
  gives `PS1` a default and starship sets it unconditionally, so it is always
  true. Use `[[ -o interactive ]]`, and add `[ -t 0 ]` when the code needs a
  real terminal: `zsh -ic '<cmd>'` is interactive but may have no tty, and
  anything that talks to a terminal (e.g. tmux) will fail there.

### Neovim Directory Structure
- `core/options.lua` — Editor options
- `core/keymaps.lua` — Global keybindings
- `core/utils.lua` — Shared utilities (root-finding, Poetry venv cache with TTL, nvim-tree state)
- `core/icons.lua` — Demotes icon glyphs to the basic multilingual plane
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
7. **Claude Code auto-update strips execute bit**: Some auto-update paths
   leave `claude.exe` non-executable — symptom is `zsh: permission denied:
   claude`. The `zshrc` detects and fixes this at shell startup with
   `chmod +x`. If the binary ends up owned by `macadmin` after a `sudo npm`
   accident, `chmod` will fail and a warning is printed to stderr.
8. **Interactive rebase on hook-symlinked files**: If a file being rebased is
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
- **Claude Code runs hook commands through a shell**, so `$PPID` inside a hook
  script is that shell (observed: `sh` -> `bash` -> `claude`), *not* Claude.
  `claude-statusbar-hook` walks up the process tree until a pid has a matching
  `~/.claude/sessions/<PID>.json`. Recording the wrong pid fails silently and
  confusingly: the hook writes its state file fine, then
  `claude-statusbar-status` sees a pid with no live session, treats it as
  stale, and deletes it within one `status-interval` — so the indicator never
  appears and the state dir looks empty every time you check.
- Adding hooks to `settings.json` does not affect a running session — they load
  at session start. To prove a hook fires, prefix its command with a sentinel
  (`echo fired >> /tmp/x; ...`) and trigger the event; if the sentinel does not
  appear the config is not loaded, and if it does the script itself is at fault.
- `~/.claude/sessions/<PID>.json` is the liveness source for Claude Code instances. Each file contains a `pid` field matching the filename stem. Cross-check with `kill -0 <pid>` to detect dead processes. If the sessions directory is absent, no Claude instance can be running — bail out rather than treating all state as stale.

## Neovim Plugin Notes

### catppuccin
Upstream made several breaking renames that **fail silently** — nothing errors,
the highlights just stop being applied. Symptoms show up as "the colours look
slightly off", so check these first after a catppuccin bump:

- The lualine (and barbecue) theme module is named **`catppuccin-nvim`**, not
  `catppuccin` (upstream #979). The old name makes lualine fall back to its
  `auto` theme. The explanatory message goes to lualine's notices buffer
  (`:LualineNotices`); `:messages` only gets a generic "there are some issues
  with your config" warning, and only via a `defer_fn` ~2s after startup that
  fires at most once — so an early `:messages` check looks clean.
- The **colorscheme** is also `catppuccin-nvim` (upstream #977, done because
  Neovim 0.12 ships a builtin `colors/catppuccin.vim`). The plugin still has a
  `colors/catppuccin.lua`, so today the old name works only because the lazy
  plugin dir precedes `$VIMRUNTIME` on the runtimepath. Use the new name.
- `bufferline` is no longer an `integrations` key — it moved to
  `require("catppuccin.special.bufferline").get_theme()`, passed as bufferline's
  `highlights` option.
- `native_lsp` is gone; diagnostic underline/virtual-text styling is now the
  **top-level `lsp_styles`** option. Its `underlines` default to `underline`,
  so `undercurl` must be set there explicitly.
- `treesitter` and `dressing` integration modules were removed outright — those
  keys are now dead. Anything under `integrations` with no matching module in
  `lua/catppuccin/groups/integrations/` is skipped by a bare `pcall` in
  `lib/mapper.lua`, with no warning. That directory is the source of truth for
  which keys are still real.
- `default_integrations` was removed (#1019). `auto_integrations` replaces it,
  but the default shown in the README is a trap: `init.lua` tests
  `user_conf.auto_integrations == true` on the **raw user table, before**
  defaults are merged, so it does nothing unless you pass it explicitly. Do not
  assume detection is on and delete the `integrations` block — pass
  `auto_integrations = true` yourself.
- We pass `auto_integrations = true` rather than hand-maintaining the list,
  which is why cmp, dap, dap_ui, diffview, mason, mini, render_markdown, ufo,
  which_key and copilot_vim are now themed too — the old hand-written list
  had drifted and covered none of them. The trade-off is that catppuccin
  writes those plugins' highlight groups, so if a plugin config ever sets its
  own colours, expect a last-writer-wins clash and pin that one key to
  `false`. Dump `require("catppuccin").options.integrations` to see the live
  set.

### Icon widths (mini.icons, render-markdown, which-key, nvim-tree)
These ship icon sets largely in the **Plane-15 private use area** (U+F0000+),
which Alacritty renders two cells wide while Neovim and tmux count one — so
every icon pushes the rest of its line a column right. `core/icons.lua` holds
the rule and the helpers. mini.icons and render-markdown are swept wholesale;
which-key is part swept, part hand-written (with a startup assertion covering
the hand-written half); nvim-tree's two glyphs are hand-overridden. Points that
cost time:

- **UAX #11 does not say Plane-15 is Wide.** It classes U+F0000+ as
  *Ambiguous*, the same as the basic-plane PUA that Alacritty draws in one
  cell, so the two-cell behaviour is Alacritty's own choice. Don't repeat the
  "it's East Asian Wide" explanation — the authority is the CSI 6n measurement
  in commit `5b34a5c`, not the standard.
- **Neither `ambiwidth` nor `setcellwidths()` is the lever.** `ambiwidth=double`
  looks right *because* the range is Ambiguous, but it applies to every
  ambiguous codepoint, so box drawing, bullets and em dashes go to two cells
  while Alacritty still draws them in one — worse than the original bug.
  `setcellwidths({{0xF0000,0xFFFFD,2}})` makes Neovim agree with Alacritty but
  *disagree with tmux*, which is Neovim's actual terminal. The mismatch is at
  the tmux↔Alacritty boundary, so the only cure is to not emit those
  codepoints.
- **Sweep sections, not whole default tables.** A plugin's `setup()` merges
  user config over its defaults, so passing back a full swept copy pins
  today's value for every unrelated option — upstream can never change one
  again. `icons.demoted_sections()` returns only the top-level sections that
  actually held an out-of-plane glyph.
- **Verify icon changes under a real pty, never headless.** `nvim --headless`
  does not drain `vim.schedule` before `qa!`, so anything a plugin defers to
  `VimEnter`/`schedule_wrap` never runs — a headless probe then reads the
  pre-deferred state and reports a fix that does not exist. which-key was
  measured "clean" headlessly while a real session still had
  `icons.keys.Space = U+F1050`. Use
  `script -qec "nvim -c 'source probe.lua' file" /dev/null` with the probe
  behind a `vim.defer_fn`. A `loaded = false` reading is the tell.
- **which-key needs a single `setup()` call.** Its deferred `load()` closes
  over the opts of the call that scheduled it, and the first one to run
  rebuilds options as `defaults + preset + its own opts`, then sets
  `M.loaded` so later loads return early — so a second `setup()` is silently
  discarded. Opts are merged last, so one call's overrides do survive.
  Separately, `icons.get()` always falls back to the built-in
  `which-key.icons.rules`; passing `icons.rules` only adds a table consulted
  *first*, so those glyphs must be demoted in place (or the whole feature
  turned off with `icons.rules = false`). And the built-in plugin specs
  (`which-key/plugins/marks.lua`, `registers.lua`) set `mapping.icon`
  directly, which bypasses the rules entirely — mutate those modules too, or
  `'` and `"` still pop up a two-cell glyph.
- **`render-markdown`'s heading `signs` are the worst offender**, because they
  sit in the two-cell `signcolumn`: the overflow shifts the entire line, which
  is what makes a markdown table's header stop lining up with its body.
- Write glyphs as `\u{XXXX}` escapes. The codepoint is the constrained thing,
  and literal private-use bytes get silently stripped by some tooling — a
  stripped glyph becomes `""`, which fails as an empty icon, not an error.
- **Verify a replacement codepoint is in the font before using it.** Several
  obvious geometric candidates (U+2610/2611 ballot boxes, U+2726-2738 stars)
  are *absent* from Hack Nerd Font; a missing glyph falls back to another font
  whose metrics reintroduce the overlap. Check with `fontTools`:
  `TTFont(<HackNerdFont-Regular.ttf>).getBestCmap()` — on WSL the font that
  matters is the Windows-side one under `%LOCALAPPDATA%\Microsoft\Windows\Fonts`.
- **`mini.icons` overrides are keyed per category, and the category is not the
  one you expect.** `md`/`lua`/`py` are *not* in `MiniIcons.list("extension")` —
  they resolve through the `filetype` table — so a loop that only overrides
  names returned by `list()` silently misses them. Overrides for names absent
  from `list()` do register, so apply curated entries unconditionally.
- **`MiniIcons.list("default")` returns the other *category names***
  (`directory`, `lsp`, `os`, …), not icon names, and its entries are each
  category's fallback icon. A sweep that keys the replacement off the category
  being iterated gives all seven the same glyph — which silently makes every
  unknown directory render as a file, so files and folders stop being
  distinguishable in the tree.
- There is no accessor for mini.icons' defaults, so reading them means
  `setup()` → inspect → `setup(overrides)`. Re-setup is supported and the
  whole sweep costs ~1.5 ms.

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
