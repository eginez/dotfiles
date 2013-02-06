export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PATH=$PATH:/Applications/android-sdk-macosx/tools
export PATH=$PATH:~/bin/

#alias
alias ll='ls -al'
alias l='ls'

#Enable git propmpt
if [ -f ~/.git-prompt.sh ]; then
	source ~/.git-prompt.sh
	PS1="[\[\033[32m\]\w]\[\033[0m\]$(__git_ps1 " (%s)")\n\[\033[1;36m\]\u\[\033[1;33m\]-> \[\033[0m\]"
else
	PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\u[\033[1;33m\]-> \[\033[0m\]"

fi





