# Shell functions

# Usage: av dev sts get-caller-identity
function av() {
  local profile=$1; shift
  aws-vault exec "${profile}" -- aws "$@"
}
compdef _aws av   # enables tab-completion like the real aws CLI

# Claude AI helpers
# Usage: ask "question" or pipe: cat file | ask "explain this"
function ask() {
  if [ -t 0 ]; then
    claude --print "$*"
  else
    local input=$(cat)
    claude --print "$input

$*"
  fi
}

# Quick code explanation
# Usage: explain file.py
function explain() {
  if [ -n "$1" ]; then
    claude --print "Explain this code concisely:" < "$1"
  elif [ ! -t 0 ]; then
    cat | claude --print "Explain this code concisely:"
  else
    echo "Usage: explain <file> OR cat file | explain"
  fi
}
