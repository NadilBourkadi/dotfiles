

export TERM=xterm-256color
export EDITOR='vim'

#
# Kubernetes
#

alias pods='k get pods'
alias p='k get pods'
alias wp='while true; do clear; k get pods; sleep 5; done'
alias k=kubectl
alias n=namespace
alias docker-killall='docker kill $(docker ps -q)'

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


#
# NPM
#

alias start-react='(cd ~/Dev/react-web-app && npm start)'
alias start-bart='(cd ~/Dev/bart && npm run watch)'


#
# Tmux
#

if which tmux >/dev/null 2>&1; then
    #if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi

tmux attach-session



    __kube_ps1() {
      ns=$(cat ~/.kube/config | grep 'namespace:' | cut -d':' -f2)
    case $(echo $ns) in
    dev)
        echo "\033[38;5;254m\]" $ns"\["
    ;;
    staging)
        echo "\033[38;5;062m\]" $ns"\["
    ;;
    prod)
        echo "\033[38;5;196m\]"$ns"\["
    ;;
    *)
        echo $ns
    ;;

    esac
    }

    __git_ps1(){
    case $(if [[ $(ls -a) != *".gitconfig"* && $(ls -a) = *".git"* ]]; then git status -b -s; fi)  in
    *master*)
        echo "\033[38;5;177m|"
    ;;
    *feature/*)
        echo "\033[38;5;121m|/F"
    ;;
    *hotfix/*)
        echo "\033[38;5;162m|/H"
    ;;
    "")
        echo ""
    ;;
    *)
        echo "|/"
    esac

    }
    PROMPT_COMMAND=$"__updatePS1"
    __updatePS1(){
    export PS1="\[\033[01;32m\]\[[K8S:$(__kube_ps1)\033[01;32m\]] $(__git_ps1) ${debian_chroot:+($debian_chroot)}\u:\[\033[38;5;27m\]\w\$\[\033[0m\] "
    }
    __updatePS1


