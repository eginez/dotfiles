# If you come from bash you might have to change your $PATH.
export GOPATH=/Users/eginez/repos/goland
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/src/mx
export HOMEBREW_NO_AUTO_UPDATE=1


# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
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
# Use vim cli mode
bindkey '^P' up-history
bindkey '^N' down-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward

#function zle-line-init zle-keymap-select {
#    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
#    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$EPS1"
#    zle reset-prompt
#}
#
#zle -N zle-line-init
#zle -N zle-keymap-select


# fzf keybindings
# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export NO_JAVA_PATH=$PATH

#Diff two strings 
function diff_strs {
    diff <(echo "$1") <(echo "$2")
}

#if which pyenv-virtualenv-init > /dev/null; then
#    eval "$(pyenv init -)";
#    eval "$(pyenv virtualenv-init -)";
#fi

function mysplit() {
    python -c "import sys; all=sys.stdin.read().split('$1'); print '\n'.join(str(p) for p in all)"
}

function fn_emacs {
	emacsclient "$1" --alternate-editor /Applications/Emacs.app/Contents/MacOS/Emacs 2>/dev/null &
}

function dkrRun {
  docker run -it --rm --entrypoint $1 $2
}


function javaBinLocation {
    export JAVA_BIN_LOCATION=
    if [[ "$(uname -s)" == "Darwin" ]]; then
        export JAVA_BIN_LOCATION=Contents/Home
    fi
}
#
#Chnages jdk for the current terminal session
#Relies on the $NO_JAVA_PATH env var
function changejdk {
  local newfile=~/bin/graalvm/`cd ~/bin/graalvm && ls |fzf`
  export JAVA_HOME=$newfile/$JAVA_BIN_LOCATION
  export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH
  java -version && native-image --version
}


#Sets up the jvmci jdk java home in order to build graal
function autojvmci {
    jdk11=$(ls -t ~/bin/graalvm | grep jvmci |grep 11|head -n 1)
    jdk8=$(ls -t ~/bin/graalvm | grep jvmci |grep 8|head -n 1)

    if [[ $1 == "8" ]] then
        export JAVA_HOME=~/bin/graalvm/$jdk8/$JAVA_BIN_LOCATION
        export EXTRA_JAVA_HOMES=~/bin/graalvm/$jdk11/$JAVA_BIN_LOCATION
    else
        export JAVA_HOME=~/bin/graalvm/$jdk11/$JAVA_BIN_LOCATION
        export EXTRA_JAVA_HOMES=~/bin/graalvm/$jdk8/$JAVA_BIN_LOCATION
    fi
    export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH

    echo JDK: $JAVA_HOME
    echo EXTRA: $EXTRA_JAVA_HOMES
    java -version
}

#Download latest jvmci from github
function dl-gb-jvmci {
    local jdk=$1
    if [[ "$1" == "11" ]]; then
        url=`curl --silent "https://api.github.com/repos/graalvm/labs-openjdk-11/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    else 
        url=`curl --silent "https://api.github.com/repos/graalvm/openjdk8-jvmci-builder/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    fi
    echo Downloading $url
    curl -L -s $url | tar -xvf - -C ~/bin/graalvm

}

#Downloads the latest graal from github
function dl-gb-graal {
    local url=`curl --silent "https://api.github.com/repos/graalvm/graalvm-ce-builds/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    echo Downloading $url
    curl -L -s $url | tar -xvf - -C ~/bin/graalvm
}


function graaldev {
    jdk=`{ ls -d ~/src/graal-workspace/graal/vm/latest_graalvm/* ; ls -d ~/src/graal-workspace2/graal/vm/latest_graalvm/* } | fzf`
    echo $jdk
    export JAVA_HOME=$jdk/$JAVA_BIN_LOCATION
    export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH
    export PATH=~/src/graal/substratevm/svmbuild/vm/bin:$PATH
    java -version && native-image --version
}

function mxgit {
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
    (
        while [ true ];
        do
            if [[ `pwd` = "/" ]]; then
                echo Can not find workspace root
                return
            fi
            if [[ -f .graalworkspace ]]; then
                break
            fi
            cd ../
        done

        root=`pwd`
        echo "$RED On workspace $root $NC"
        for repo in $(find `pwd` -depth 1 -type d)
        do
            cd $repo
            echo "$GREEN============`pwd`==================$NC"
            $@
        done

        #ls -1 |xargs -I% sh -c "cd % && echo === `pwd` === && $1"
    )
}


#Aliases
alias fbn="find . -name "
alias idiff="idea diff "
alias gw="./gradlew"
alias ownusr="sudo chown -R `whoami` /usr/local/bin && sudo chown -R `whoami` /usr/local/lib"
alias memacs="fn_emacs"
alias em="fn_emacs"
alias kct="kubectl"
javaBinLocation

#source not exposable functions
[ -f ~/.private.zshrc ] && source ~/.private.zshrc



test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

