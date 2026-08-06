# WSL detection helpers.
#
# Lives in its own file rather than functions.zsh because init.zsh sources it
# too, and functions.zsh calls compdef — which needs compinit and so only
# works in an interactive shell.

# True on WSL. The kernel string is the primary signal, matched
# case-insensitively (WSL1 builds report "Microsoft", repackaged ones
# "MICROSOFT"). /run/WSL — created by WSL's init for interop — covers a custom
# kernel set via `kernel=` in .wslconfig, which need not contain "microsoft".
_is_wsl() {
  local rel=""
  [[ -r /proc/sys/kernel/osrelease ]] && rel="$(</proc/sys/kernel/osrelease)"
  [[ "${rel:l}" == *microsoft* ]] && return 0
  [[ -e /run/WSL ]]
}

# True when this shell is WSL's console login session rather than a terminal.
#
# With systemd=true, WSL runs `login -- <user>` on a tty at every boot. That
# shell sources zshrc, so without this guard it races the real terminal to
# start tmux — and tmux-continuum counts the extra client process as "another
# tmux server", silently disabling session save/restore.
#
# The parent process is the signal. Absent WSL_INTEROP/WSL_DISTRO_NAME is not:
# ssh, `su -`, `sudo -i` and systemd units lack those too and must still get
# tmux. Read via procfs rather than `ps`, so a distro without procps installed
# doesn't silently fail open.
#
# Only the immediate parent is checked, so a shell nested below the console
# shell is not recognised. That false negative is the safer way to be wrong: a
# false positive silently denies tmux to a terminal you are actually using.
_wsl_console_login() {
  _is_wsl || return 1
  [[ -r /proc/${PPID:-0}/comm ]] || return 1
  [[ "$(</proc/${PPID:-0}/comm)" == login ]]
}
