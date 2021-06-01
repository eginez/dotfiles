# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/src/mx
export HOMEBREW_NO_AUTO_UPDATE=1


# Path to your oh-my-zsh installation.
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
export ZSH=~/.oh-my-zsh
ZSH_THEME="lambda-color"
plugins=(git)
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

#Vim mode
bindkey -v

## Start command prompt in normal mode
zle-line-init() {
    zle -K vicmd;
}
zle -N zle-line-init

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward



# fzf keybindings
# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
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
        cid=$(docker ps|fzf|cut -d' ' -f1)
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

#source not exposable functions
[ -f ~/.private.zshrc ] && source ~/.private.zshrc



test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"



