# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export TERM=xterm-256color
# Path to your oh-my-zsh installation.
export ZSH="/home/dil/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bureau"

# ZSH_THEME="wezm"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

get-image() {
    k describe deploy $1 | grep Image
}

function forward {
    port=$2
    service=$(k get pods | grep $1 | head -1 | cut -d ' ' -f1)
    echo "Forwarding pod $service on port $port"
    kubectl port-forward "$service" $port
}

function delete {
 service=$(k get -n staging pods | grep $1 | head -1 | cut -d ' ' -f1)
    echo "Deleting pod on staging $service"
    kubectl delete pod "$service"
}

function logs {
    service=$1
    shift
    kubectl logs --tail=100 -f "deployment/$service" $@
}

function kbash {
    service=$(k get pods | grep $1 | grep Running | head -1 | cut -d ' ' -f1)
    echo "Executing bash on $service"
    shift
    kubectl exec "$service" -it bash $@
}

function ksh {
    service=$(k get pods | grep $1 | grep Running | head -1 | cut -d ' ' -f1)
    echo "Executing bash on $service"
    shift
    kubectl exec "$service" -it sh $@
}
function describe {
    service=$(k get pods | grep $1 | head -1 | cut -d ' ' -f1)
    echo "Executing describe on $service"
    k describe pod "$service"
}
function namespace {
    echo "Setting namespace $1"
    kubectl config set-context $(kubectl config current-context) --namespace=$1
}

function dc-test {
    (cd ~/Dev/stack && docker-compose run $1 python manage.py test $2)
}

function dc-up-d {
    (cd ~/Dev/stack && docker-compose up -d $1)
}

function dc-up {
    (cd ~/Dev/stack && docker-compose up $1)
}

function dc-man {
    service=$1
    shift
    (cd ~/Dev/stack && docker-compose run "$service" python manage.py "$@")
}

build-dh ()
{
  project=$1;
  cd $project;
  version=`git log -1 --pretty=oneline | cut -d' ' -f1`;
  docker build -t networklocum/$project:$version .;
  docker push networklocum/$project:$version;
  cd ..;
}

alias start-react='(cd ~/Dev/react-web-app && npm start)'
alias start-bart='(cd ~/Dev/bart && npm run watch)'

# TMUX
# if which tmux >/dev/null 2>&1; then
#     #if not inside a tmux session, and if no session is started, start a new session
#    # test -z "$TMUX" && (tmux attach || tmux new-session)
#   tmux new-session -s bart -A -d 
#  tmux new-session -s react -A -d
# fi

tmux