# Shell functions

# Usage: av dev sts get-caller-identity
function av() {
  command -v aws-vault &>/dev/null || { echo "Error: aws-vault is required."; return 1; }
  local profile=$1; shift
  aws-vault exec "${profile}" -- aws "$@"
}
compdef _aws av   # enables tab-completion like the real aws CLI

# Kill orphaned nvim processes not attached to any tmux pane
# Usage: kill-orphan-nvims [--dry-run]
function kill-orphan-nvims() {
  local dry_run=false
  [[ "$1" == "--dry-run" ]] && dry_run=true

  # Bail if tmux is not running — avoids killing ALL nvims by mistake
  if ! tmux info &>/dev/null; then
    echo "Error: tmux is not running. Aborting to avoid killing active nvim instances."
    return 1
  fi

  # Collect all PIDs that are descendants of tmux panes
  local -A tmux_tree=()
  local pane_pids=($(tmux list-panes -a -F '#{pane_pid}' 2>/dev/null))

  # Recursive walk: collect all descendants of a PID
  local _walk_descendants
  _walk_descendants() {
    local parent=$1
    tmux_tree[$parent]=1
    local children=($(pgrep -P "$parent" 2>/dev/null))
    for child in "${children[@]}"; do
      [[ -z "${tmux_tree[$child]+x}" ]] && _walk_descendants "$child"
    done
  }

  for pid in "${pane_pids[@]}"; do
    _walk_descendants "$pid"
  done

  # Get all nvim PIDs
  local all_nvim_pids=($(pgrep -x nvim 2>/dev/null))
  if [[ ${#all_nvim_pids[@]} -eq 0 ]]; then
    echo "No nvim processes found."
    return 0
  fi

  # Find orphaned nvims: not in the tmux descendant set
  local orphaned=()
  for pid in "${all_nvim_pids[@]}"; do
    [[ -z "${tmux_tree[$pid]+x}" ]] && orphaned+=("$pid")
  done

  if [[ ${#orphaned[@]} -eq 0 ]]; then
    echo "No orphaned nvim processes found (${#all_nvim_pids[@]} active in tmux)."
    return 0
  fi

  echo "Found ${#orphaned[@]} orphaned nvim process(es) (${#all_nvim_pids[@]} total):"
  printf "  PID %s\n" "${orphaned[@]}"

  if $dry_run; then
    echo "(dry run — no processes killed)"
    return 0
  fi

  kill "${orphaned[@]}" 2>/dev/null
  echo "Sent SIGTERM to ${#orphaned[@]} process(es)."
}
