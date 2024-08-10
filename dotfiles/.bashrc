#####################
# BASE .BASHRC FILE #
#####################
case $- in
    *i*) ;;
      *) return;;
esac
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi
unset color_prompt force_color_prompt
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

########
# PATH #
########
export PATH="$HOME/bin/git:$PATH"
export DENO_INSTALL="/home/jack/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

###################
# DEFAULT ALIASES #
###################
alias ll='ls -alF'
alias vs='psrun ./*.sln'
alias code='code .'
alias brc='source ~/.bashrc'
alias explore='explorer.exe .' 
alias psrun='powershell.exe'
alias bin='cd $HOME/bin'

#############################
# DEFAULT DIRECTORY ALIASES #
#############################
alias prj='cd "${prjDir}"'
alias usr='cd "${usrDir}"'
alias dsk='cd  "${usrDir}/Desktop"'
alias dwn='cd  "${usrDir}/Downloads"'
alias jgd='cd ~/.jgd.cfg'

####################
# DEFAULT env vars #
####################
usrName="319723"
usrDir="/mnt/c/Users/${usrName}"
prjDir="/mnt/d"

#################
# WORK env vars #
#################
wegDir="/mnt/d/wegmans"
sapDir="${wegDir}/sap"
disDir="${sapDir}/sap-disintegrator"
locDir="${sapDir}/locations-hub"
adminDir="${sapDir}/sap-integration-management"
elDir="${wegDir}/enterprise-library"
docsDir="${wegDir}/docs.wegmans.tech"
cloudDir="${wegDir}/cloud-events"

################
# WORK ALIASES #
################
alias el='cd "${elDir}"'
alias weg='cd "${wegDir}"'
alias cloud='cd "${cloudDir}"'
alias docs='cd "${docsDir}"'

# SAP Integration
alias sap='cd "${sapDir}"'
alias dis='export PROJECT_ROOT=$disDir; cd $PROJECT_ROOT'
alias loc='export PROJECT_ROOT=$locDir; cd $PROJECT_ROOT'
alias admin='export PROJECT_ROOT=$adminDir; cd $PROJECT_ROOT'

##########
# EDITOR #
##########
export EDITOR=vim

###################
# JSON Validation #
###################
jsonlint() {
  python -mjson.tool $1 > /dev/null
}

############
# NODE/NVM #
############
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

########
# TMUX #
########

# RUBY #
# for tmuxinator
# https://gorails.com/setup/ubuntu/18.04#ruby-rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# aliases for tmux sessions
alias start_main='tmux attach-session -t main || tmuxinator start main'

main() {
  if [[ $SHLVL != "2" ]]; then
    start_main
  fi
}

# custom TMUX alieases
alias ml='tmux ls'

ma() {
  tmux attach-session -t $1 || tmux new-session -s $1
}

md() {
  tmux kill-session -t $1
  ml
}

##############
# AAD Tokens #
##############
token() {
  tokenName=$1

  if [[ $tokenName == "dis" ]]; then
    az account get-access-token --resource "c8304276-f3c4-40eb-acfb-d2330f4578a9" --tenant "1318d57f-757b-45b3-b1b0-9b3c3842774f"
  elif [[ $tokenName = "disProd" ]]; then
    az account get-access-token --resource "b40ad62d-c014-4401-80aa-cab6adabb233" --tenant "1318d57f-757b-45b3-b1b0-9b3c3842774f"
  fi
}

#######
# SSH #
#######
alias sshme='eval `ssh-agent -s` && ssh-add ~/.ssh/*_rsa'
alias sshmekeygen='ssh-keygen -t rsa -b 4096 -C "319723@wegmans.com"'

##########
# PROMPT #
##########
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
export PROMPT_DIRTRIM=1

###########
# STARTUP #
###########
alias greeting='echo "Hello Jack!" && echo ""'

# run main tmux session at startup
main
