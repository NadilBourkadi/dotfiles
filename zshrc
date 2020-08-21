zsh ~/init.zsh

alias python=python3
alias vim=/usr/local/bin/vim

__kube_ps1() {
    CONTEXT=$(cat ~/.kube/config | grep 'namespace:' | cut -d':' -f2)
    echo "[k8s$CONTEXT]"
}

export TERM=xterm-256color
export EDITOR='vim'

#
# Kubernetes
#

alias pods='k get pods'
alias p='k get pods'
alias wp='while true; do clear; k get pods; sleep 5; done'
alias wt='while true; do clear; k top pods; sleep 5; done'
alias k=kubectl
alias n=namespace
alias docker-killall='docker kill $(docker ps -q)'
alias g=grep

export KOPS_STATE_STORE=s3://lantum-kops
export NAME=k.lantum.com

export KUBE_EDITOR='vim'

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
    service=$(kubectl get pods | grep $1 | grep Running | head -1 | cut -d ' ' -f1)
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

function kimage {
    for service in $*
    do
        k describe deploy $service | grep Image | sed "1q;d"
    done
}

#
# Docker Compose
#

alias dc='docker-compose'

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

alias ng-res='sudo service nginx restart'
alias ng-rel='sudo service nginx rel'

alias vimrc='vim ~/.vimrc'

#
# NPM
#

alias start-react='(cd ~/Dev/react-web-app && npm start)'
alias start-bart='(cd ~/Dev/bart && npm run watch)'

#
# Tmux
#

# Grep for tmux session
tmux-ls(){
    if [ -z "$1" ]; then
        tmux ls
    else
        tmux ls | grep -i $1 | sed 's/:.*//';
    fi
}

tmux-a(){
   tmux-ls $1 | xargs tmux switch -t
}

fab-bd(){
    environment=$1
    service=$2
    (cd ~/Dev/stack && fab $environment build_and_deploy:$service)
}

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

context ()
{
    if [ -z "$1" ]; then
        kubectl config current-context;
        return 0;
    fi;
    kubectl config use-context $1
}

source ~/.zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git
antigen bundle heroku
antigen bundle command-not-found
antigen bundle last-working-dir
antigen bundle kube-ps1

antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

source ~/dotfiles/dil.zsh-theme
ZSH_AUTOSUGGEST_STRATEGY=completion
