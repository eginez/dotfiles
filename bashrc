#enable vi mode
set -o vi
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PATH=$PATH:/Applications/android-sdk-macosx/tools
export PATH=$PATH:~/bin/

#alias
alias ll='ls -al'
alias l='ls'
alias clj='lein repl'

#Enable git propmpt
if [ ! -f ~/.git-prompt.sh ]; then
    wget -O ~/.git-prompt.sh https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
fi

GIT_PS1_SHOWDIRTYSTATE=1
source ~/.git-prompt.sh
PS1="[\[\033[32m\]\w]\[\033[0m\]$(__git_ps1 " (%s)")\n\[\033[1;36m\]\u\[\033[1;33m\]-> \[\033[0m\]"


function mountAndroid { hdiutil attach ~/android.dmg.sparseimage -mountpoint /Volumes/android; }




