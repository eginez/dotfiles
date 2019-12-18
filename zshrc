# If you come from bash you might have to change your $PATH.
export GOPATH=/Users/eginez/repos/goland
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin
export NO_JAVA_PATH=$PATH


# Path to your oh-my-zsh installation.
export ZSH=/Users/eginez/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git python go)

source $ZSH/oh-my-zsh.sh

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
#set cdpath to a meaningful locations, this allows to access and autocomplete as if it was a root directory
#cdpath=($HOME/src)

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

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1


# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#


# fzf keybindings
# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

function mysplit() {
    python -c "import sys; all=sys.stdin.read().split('$1'); print '\n'.join(str(p) for p in all)"
}

function gohome() {
    export GOPATH=`pwd`
}

function fn_emacs {
	emacsclient "$1" --alternate-editor /Applications/Emacs.app/Contents/MacOS/Emacs 2>/dev/null &
}

function dkrRun {
  docker run -it --rm --entrypoint $1 $2
}

#Download latest jvmci
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

#Diff two strings 
function diff_strs {
    diff <(echo "$1") <(echo "$2")
}

if which pyenv-virtualenv-init > /dev/null; then
    eval "$(pyenv init -)";
    eval "$(pyenv virtualenv-init -)";
fi

#Aliases
alias fbn="find . -name "
alias idiff="idea diff "
alias gw="./gradlew"
alias ownusr="sudo chown -R `whoami` /usr/local/bin && sudo chown -R `whoami` /usr/local/lib"
alias memacs="fn_emacs"
alias em="fn_emacs"
alias kct="kubectl"

#source not exposable functions
[ -f ~/.private.zsh ] && source ~/.private.zsh



test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

