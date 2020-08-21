# Based on bira theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_PROMPT PR_HOST

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{green}%n%f'
  PR_USER_OP='%F{green}%#%f'
  PR_PROMPT='%f➤ %f'
else # root
  PR_USER='%F{red}%n%f'
  PR_USER_OP='%F{red}%#%f'
  PR_PROMPT='%F{red}➤ %f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{red}%M%f' # SSH
else
  PR_HOST='%F{green}%M%f' # no SSH
fi


local return_code="%(?..%F{red}%? ↵%f)"

local user_host="${PR_USER}@${PR_HOST}"
local current_dir="%B%F{blue}%~%f%b"
local git_branch='$(git_prompt_info)'
local kube_ps1='$(kube_ps1)'

# PROMPT="╭─${user_host} ${current_dir} \$(ruby_prompt_info) ${git_branch}
# ╰─$PR_PROMPT "

PROMPT="${current_dir} ${git_branch}${kube_ps1} 👻
$PR_PROMPT "
RPROMPT="${return_code} ${user_host}"

ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %f"
ZSH_THEME_RUBY_PROMPT_PREFIX="%F{red}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%f"

}
