#enable vi mode
set -o vi
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PATH=/usr/local/bin:$PATH
export PATH=$PATH:/Applications/android-sdk-macosx/tools
export PATH=$PATH:/Applications/android-sdk-macosx/platform-tools
export PATH=$PATH:~/bin

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=200



#alias
alias ll='ls -al'
alias l='ls'
alias clj='lein repl'

function parse_repo()
{
    git branch &>/dev/null && echo "{at`git branch|grep '*'|cut -d'*' -f2`}"
}

#Enable git propmpt
PS1='[\[\033[32m\]\w]\[\033[0m\]$(parse_repo)\n\[\033[1;36m\]\u\[\033[1;33m\]-> \[\033[0m\]'


function mountAndroid { hdiutil attach ~/android.dmg.sparseimage -mountpoint /Volumes/android; }
