#!/usr/bin/env zsh
set -e

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  cat <<'USAGE'
Usage: zsh init.zsh [--help]

Bootstrap dotfiles: symlinks configs, installs packages, sets up plugin managers.
USAGE
  exit 0
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Derive dotfiles directory from script location
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Shared WSL predicates (_is_wsl, _wsl_console_login) — also sourced by zshrc.
# Guarded: set -e would otherwise abort the whole bootstrap before any symlink
# is created if the module were missing.
if [[ -f "$DOTFILES_DIR/zsh/wsl.zsh" ]]; then
  source "$DOTFILES_DIR/zsh/wsl.zsh"
else
  _is_wsl() { return 1 }   # degrade to "not WSL" rather than killing the run
fi

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Prerequisite checks
for cmd in git zsh; do
  command -v "$cmd" &>/dev/null || { echo "Error: $cmd is required but not found"; exit 1; }
done

# ─────────────────────────────────────────────────────────────
# Symlinks
# ─────────────────────────────────────────────────────────────

# File symlinks (ln -sf is safe for files)
typeset -A file_symlinks=(
  [zshrc]=~/.zshrc
  [tmux.conf]=~/.tmux.conf
  [gitignore_global]=~/.gitignore_global
  [starship.toml]=~/.config/starship.toml
  [alacritty.toml]=~/.config/alacritty/alacritty.toml
  [alacritty/theme.toml]=~/.config/alacritty/theme.toml
  [bin/claude-statusbar-hook]=~/.local/bin/claude-statusbar-hook
  [bin/claude-statusbar-status]=~/.local/bin/claude-statusbar-status
  [bin/alacritty-windows-sync]=~/.local/bin/alacritty-windows-sync
)

for src dest in "${(@kv)file_symlinks}"; do
  echo -n "Symlinking $src... "
  mkdir -p "$(dirname "$dest")"
  ln -sf "$DOTFILES_DIR/$src" "$dest"
  echo "${GREEN}Done${NC}"
done
# One chmod per file, each guarded: zsh aborts the *whole* command when any
# glob matches nothing, so combining these would let a missing sync script
# silently skip chmod'ing the statusbar hooks — which Claude Code then cannot
# execute, and the tmux indicator never appears.
for f in claude-statusbar-hook claude-statusbar-status alacritty-windows-sync; do
  [[ -f "$DOTFILES_DIR/bin/$f" ]] && chmod +x "$DOTFILES_DIR/bin/$f"
done

# Directory symlinks (must rm -f first to avoid circular symlink)
typeset -A dir_symlinks=(
  [nvim]=~/.config/nvim
)

for src dest in "${(@kv)dir_symlinks}"; do
  echo -n "Symlinking $src/ ... "
  mkdir -p "$(dirname "$dest")"
  rm -f "$dest"
  ln -s "$DOTFILES_DIR/$src" "$dest"
  echo "${GREEN}Done${NC}"
done

# Private symlinks (gitignored; only applied when private/ is present)
# Keys are relative to private/, values are the symlink destinations.
# Add entries here for any private-repo files that need symlinking.
if [[ -d "$DOTFILES_DIR/private" ]]; then
  typeset -A private_symlinks=(
    [believ/claude-settings.json]=~/.claude/settings.json
  )
  for src dest in "${(@kv)private_symlinks}"; do
    if [[ -f "$DOTFILES_DIR/private/$src" ]]; then
      echo -n "Symlinking private/$src... "
      mkdir -p "$(dirname "$dest")"
      ln -sf "$DOTFILES_DIR/private/$src" "$dest"
      echo "${GREEN}Done${NC}"
    fi
  done
fi

# ─────────────────────────────────────────────────────────────
# Git config
# ─────────────────────────────────────────────────────────────

echo -n "Configuring git global settings... "
git config --global core.excludesfile ~/.gitignore_global
git config --global core.autocrlf false
echo "${GREEN}Done${NC}"

# alacritty.toml uses `[general] import`, added in Alacritty 0.14. Neither OS
# branch upgrades an existing install (macOS skips when the app is present,
# Linux never installs it at all), and an unsupported import fails silently —
# the terminal just comes up with the default palette. So warn instead.
check_alacritty_import_support() {
  local bin="$1" ver
  [[ -x "$bin" ]] || return 0
  ver="$("$bin" --version 2>/dev/null | awk '{print $2}')"
  [[ -n "$ver" ]] || return 0
  if ! printf '0.14.0\n%s\n' "$ver" | sort -V -C; then
    echo "  Warning: Alacritty $ver is older than 0.14 — '[general] import' is unsupported,"
    echo "  so the Catppuccin colours in alacritty/theme.toml will not load. Upgrade Alacritty."
  fi
}

# ─────────────────────────────────────────────────────────────
# Package installation
# ─────────────────────────────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew &>/dev/null; then
    echo -n "Installing Homebrew dependencies... "
    brew bundle --file="$DOTFILES_DIR/Brewfile" --quiet || { echo "brew bundle failed"; exit 1; }
    echo "${GREEN}Done${NC}"
    echo "Note: Set your terminal font to 'Hack Nerd Font' in preferences"
  else
    echo "Homebrew not found, skipping dependency installation"
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  # System packages Homebrew on Linux needs (bubblewrap is recommended by
  # the Homebrew installer for sandboxed source builds), plus wl-clipboard
  # for WSLg/Wayland clipboard integration
  apt_pkgs=(build-essential bubblewrap curl file procps wl-clipboard)
  # earlyoom: userspace OOM killer — the kernel one fires too late under
  # WSL2 and the VM livelocks first (Ubuntu enables the service on install).
  # WSL-only: native Linux already runs systemd-oomd and would not want
  # surprise SIGTERMs during a big build.
  if _is_wsl; then
    apt_pkgs+=(earlyoom)
  fi
  if command -v apt-get &>/dev/null; then
    apt_missing=()
    for pkg in "${apt_pkgs[@]}"; do
      # dpkg-query status check: `dpkg -s` wrongly passes for removed-but-
      # not-purged (rc state) packages
      dpkg-query -W -f='${db:Status-Status}' "$pkg" 2>/dev/null | grep -qx installed || apt_missing+=("$pkg")
    done
    if (( ${#apt_missing[@]} )); then
      echo "Installing apt prerequisites: ${apt_missing[*]}"
      sudo apt-get update -qq
      sudo apt-get install -y "${apt_missing[@]}"
    fi
  else
    echo "apt-get not found — install Homebrew prerequisites manually: ${apt_pkgs[*]}"
  fi

  # Homebrew on Linux — same Brewfile as macOS (casks are guarded with OS.mac?)
  if ! command -v brew &>/dev/null && [[ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo "Installing Homebrew..."
    # The NONINTERACTIVE installer uses `sudo -n`, so cache credentials
    # first (|| true: sudo may be absent, e.g. when the prefix is pre-owned)
    sudo -v || true
    # || true: failures are caught below with a clear message — without it
    # set -e would abort before reaching the check
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
  fi
  [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  if command -v brew &>/dev/null; then
    echo -n "Installing Homebrew dependencies... "
    brew bundle --file="$DOTFILES_DIR/Brewfile" --quiet || { echo "brew bundle failed"; exit 1; }
    echo "${GREEN}Done${NC}"
  else
    echo "Homebrew installation failed"
    exit 1
  fi

  if _is_wsl; then
    echo "Note: WSL — install 'Hack Nerd Font' on Windows and select it in your terminal profile (see README)"
    # Installs Alacritty on the Windows side and writes its config. The script
    # always exits 0 internally, but that only helps once it runs — guard the
    # invocation too, so a missing or non-executable file cannot abort the
    # bootstrap under set -e before the remaining setup steps.
    if [[ -x "$DOTFILES_DIR/bin/alacritty-windows-sync" ]]; then
      "$DOTFILES_DIR/bin/alacritty-windows-sync" --install --force || true
    else
      echo "  bin/alacritty-windows-sync missing or not executable, skipping"
    fi

    # Copy wslconfig to %USERPROFILE%\.wslconfig — swap size and memory
    # reclaim for the WSL2 VM. Copied, not symlinked: Windows cannot read
    # WSL symlinks (see CLAUDE.md). Rerunning init.zsh IS the sync
    # mechanism — nothing refreshes the Windows copy on shell startup.
    # cmd.exe: from PATH like alacritty-windows-sync (interop may be off),
    # run from a Windows path, </dev/null so it cannot swallow queued
    # terminal input, output carries \r. || true: set -e must not abort
    # the bootstrap when interop is unavailable (e.g. container on WSL).
    win_profile=""
    if command -v cmd.exe &>/dev/null; then
      win_profile=$(cd /mnt/c && cmd.exe /c "echo %USERPROFILE%" </dev/null 2>/dev/null | tr -d '\r') || true
    fi
    if [[ "$win_profile" == [A-Za-z]:\\* ]] && win_profile_wsl=$(wslpath "$win_profile" 2>/dev/null) && [[ -d "$win_profile_wsl" ]]; then
      wslconfig_dest="$win_profile_wsl/.wslconfig"
      if ! cmp -s "$DOTFILES_DIR/wslconfig" "$wslconfig_dest" 2>/dev/null; then
        # Preserve a hand-written .wslconfig once, like alacritty-windows-sync
        if [[ -f "$wslconfig_dest" && ! -f "$wslconfig_dest.pre-dotfiles.bak" ]] && \
           ! grep -q "copied (not symlinked" "$wslconfig_dest" 2>/dev/null; then
          cp "$wslconfig_dest" "$wslconfig_dest.pre-dotfiles.bak" || true
        fi
        if cp "$DOTFILES_DIR/wslconfig" "$wslconfig_dest" 2>/dev/null; then
          print -r -- "  Updated $wslconfig_dest — run 'wsl --shutdown' from Windows to apply"
        else
          print -r -- "  Copy to $wslconfig_dest failed — copy wslconfig there manually"
        fi
      fi
    else
      echo "  Could not resolve %USERPROFILE% — copy wslconfig to it manually as .wslconfig"
    fi
  else
    # Native Linux: Alacritty is never installed here, but alacritty.toml is
    # still symlinked, so a distro package predating 0.14 loses the palette.
    check_alacritty_import_support "$(command -v alacritty 2>/dev/null)"

    # Hack Nerd Font: the macOS cask has no Linux equivalent, and without it
    # fontconfig silently substitutes a proportional font, which a terminal
    # then draws on a fixed cell grid ("Cl aude"). Per-user install, keyed
    # off fc-list so reruns are no-ops.
    if ! command -v fc-cache &>/dev/null; then
      echo "fontconfig not found — skipping Hack Nerd Font install"
    elif ! fc-list 2>/dev/null | grep -q "Hack Nerd Font"; then
      echo -n "Installing Hack Nerd Font... "
      font_dir="$HOME/.local/share/fonts/HackNerdFont"
      font_tmp="$(mktemp -d)"
      if curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz -o "$font_tmp/Hack.tar.xz" \
         && mkdir -p "$font_dir" \
         && tar -xJf "$font_tmp/Hack.tar.xz" -C "$font_dir" --wildcards 'HackNerdFont-*.ttf'; then
        fc-cache -f "$font_dir" || echo "fc-cache failed — run it manually"
        echo "${GREEN}Done${NC}"
      else
        echo "failed — install Hack Nerd Font manually from https://www.nerdfonts.com/font-downloads"
      fi
      rm -rf "$font_tmp"
    fi
  fi

  # Make zsh the login shell (macOS already defaults to zsh).
  # Check getent, not $SHELL — $SHELL is stale until re-login.
  login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [[ "$login_shell" != */zsh ]]; then
    zsh_path="$(command -v zsh)"
    echo "Changing default shell to ${zsh_path}..."
    chsh -s "$zsh_path" || echo "chsh failed — run manually: chsh -s $zsh_path"
  fi
fi

# ─────────────────────────────────────────────────────────────
# Alacritty (GitHub release, macOS only)
# ─────────────────────────────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -d /Applications/Alacritty.app ]]; then
    echo "Alacritty already installed, ${GREEN}skipping${NC}"
    check_alacritty_import_support /Applications/Alacritty.app/Contents/MacOS/alacritty
  else
    ALACRITTY_JSON=$(curl -sL https://api.github.com/repos/alacritty/alacritty/releases/latest)
    if command -v jq &>/dev/null; then
      ALACRITTY_TAG=$(echo "$ALACRITTY_JSON" | jq -r '.tag_name')
    else
      ALACRITTY_TAG=$(echo "$ALACRITTY_JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
    fi
    echo "Installing Alacritty ${ALACRITTY_TAG} from GitHub... "
    ALACRITTY_DMG="Alacritty-${ALACRITTY_TAG}.dmg"
    curl -sL "https://github.com/alacritty/alacritty/releases/download/${ALACRITTY_TAG}/${ALACRITTY_DMG}" -o "/tmp/${ALACRITTY_DMG}"
    # Best-effort SHA256 checksum verification
    ALACRITTY_SHA="Alacritty-${ALACRITTY_TAG}.dmg.sha256"
    if curl -sfL "https://github.com/alacritty/alacritty/releases/download/${ALACRITTY_TAG}/${ALACRITTY_SHA}" -o "/tmp/${ALACRITTY_SHA}" 2>/dev/null; then
      (cd /tmp && shasum -a 256 -c "${ALACRITTY_SHA}") || { echo "Checksum verification failed!"; rm -f "/tmp/${ALACRITTY_DMG}" "/tmp/${ALACRITTY_SHA}"; exit 1; }
      rm -f "/tmp/${ALACRITTY_SHA}"
    else
      echo "Note: Checksum file not available, skipping verification"
    fi
    hdiutil attach "/tmp/${ALACRITTY_DMG}" -quiet -nobrowse -mountpoint /tmp/alacritty-mnt
    cp -R /tmp/alacritty-mnt/Alacritty.app /Applications/
    hdiutil detach /tmp/alacritty-mnt -quiet
    rm -f "/tmp/${ALACRITTY_DMG}"
    echo "${GREEN}Done${NC}"
  fi
fi

# ─────────────────────────────────────────────────────────────
# Node.js via nvm (copilot.vim + Mason's npm-based servers)
# ─────────────────────────────────────────────────────────────

NVM_VERSION="v0.40.3"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo -n "Installing nvm ${NVM_VERSION}... "
  # PROFILE=/dev/null stops the installer appending loader lines to the
  # symlinked ~/.zshrc — zshrc already sources nvm itself
  PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh)" >/dev/null || true
  # bash -c "$(curl ...)" exits 0 on a failed download (empty script), so
  # verify the result instead of trusting the exit code
  [[ -s "$NVM_DIR/nvm.sh" ]] || { echo "nvm install failed"; exit 1; }
  echo "${GREEN}Done${NC}"
fi
# nvm is incompatible with errexit (its README lists `set -e` as a known
# issue) — run it relaxed and verify the outcome instead
source "$NVM_DIR/nvm.sh" || true
if ! command -v node &>/dev/null; then
  echo "Installing Node.js LTS via nvm..."
  nvm install --lts || true
  command -v node &>/dev/null || { echo "Node.js install via nvm failed"; exit 1; }
fi

# ─────────────────────────────────────────────────────────────
# Plugin managers
# ─────────────────────────────────────────────────────────────

echo "Zinit (Zsh plugin manager) will auto-install on first shell launch"

# Install TPM (Tmux Plugin Manager)
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo -n "Installing TPM (Tmux Plugin Manager)... "
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || { echo "TPM clone failed"; exit 1; }
  echo "${GREEN}Done${NC}"
else
  echo "TPM already installed, ${GREEN}skipping${NC}"
fi

if command -v tmux &>/dev/null; then
  echo -n "Installing tmux plugins (TPM)... "
  ~/.tmux/plugins/tpm/bin/install_plugins >/dev/null
  echo "${GREEN}Done${NC}"
else
  echo "tmux not found, skipping plugin installation"
fi

# Install Neovim plugins
if command -v nvim &>/dev/null; then
  echo -n "Installing Neovim plugins (lazy.nvim)... "
  nvim --headless "+Lazy! sync" +qa 2>/dev/null
  echo "${GREEN}Done${NC}"
else
  echo "Neovim not found, skipping plugin installation"
fi

echo "${GREEN}Done.${NC} Restart your terminal or run: source ~/.zshrc"
