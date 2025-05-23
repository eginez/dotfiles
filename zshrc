# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=/opt/homebrew/bin:$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin:$HOME/.modular/bin/
export PATH=$PATH:$HOME/src/mx
export HOMEBREW_NO_AUTO_UPDATE=1


# Path to your oh-my-zsh installation.
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
export ZSH=~/.oh-my-zsh
#ZSH_THEME="lambda-color"
ZSH_THEME="powerlevel10k/powerlevel10k"
#plugins=(git)
#plugins+=(zsh-vi-mode)
source $ZSH/oh-my-zsh.sh

export EDITOR=vim
export KEYTIMEOUT=1

# User configuration
#History saving
HISTFILE=~/.zsh_history
HISTSIZE=99999999999
SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt INC_APPEND_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt auto_cd
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

#Vim mode
bindkey -v

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward



# fzf keybindings
# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
export NO_JAVA_PATH=$PATH

#Diff two strings 
function diff_strs {
    diff <(echo "$1") <(echo "$2")
}

function mysplit() {
    python -c "import sys; all=sys.stdin.read().split('$1'); print '\n'.join(str(p) for p in all)"
}

function fn_emacs {
	emacsclient "$1" --alternate-editor /Applications/Emacs.app/Contents/MacOS/Emacs 2>/dev/null &
}

function dkrRun {
  docker run -it --rm --entrypoint $1 $2
}

function did() {
    if [[ $@ == '' ]]; then
        cid=$(docker ps|fzf -m|cut -d' ' -f1)
    else
        cid=$(docker ps -q --filter "name=$@")
    fi
    echo $cid
}



#Aliases
alias fbn="find . -name "
alias idiff="idea diff "
alias gw="./gradlew"
alias ownusr="sudo chown -R `whoami` /usr/local/bin && sudo chown -R `whoami` /usr/local/lib"
alias memacs="fn_emacs"
alias em="fn_emacs"
alias kct="kubectl"
alias c=cd
alias g=git

#source not exposable functions
[ -f ~/.private.zshrc ] && source ~/.private.zshrc



test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export SDKMAN_DIR="/Users/$USER/.sdkman"
[[ -s "/Users/$USER/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/$USER/.sdkman/bin/sdkman-init.sh"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

function git_conda_activate() {
  # Activates a conda enviroment matching the name of the git repository
    local git_repo=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_repo" ]; then
        local env_name=$(basename "$git_repo" | sed 's/[^[:alnum:]]/_/g')
        conda activate "$env_name" 2>/dev/null || echo "No conda environment found for $env_name"
    else
        echo "Not a git repository"
    fi
}


function git_conda_create() {
  #Creates a conda enviroment matching the name of the repo
    local git_repo=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_repo" ]; then
        local env_name=$(basename "$git_repo" | sed 's/[^[:alnum:]]/_/g')
        conda create -n "$env_name" python=${1-3.11} && \
        conda activate "$env_name"
    else
        echo "Not a git repository"
    fi

}
