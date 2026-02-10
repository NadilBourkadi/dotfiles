# Shell functions

# Usage: av dev sts get-caller-identity
function av() {
  command -v aws-vault &>/dev/null || { echo "Error: aws-vault is required."; return 1; }
  local profile=$1; shift
  aws-vault exec "${profile}" -- aws "$@"
}
compdef _aws av   # enables tab-completion like the real aws CLI
