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
# temp - .net 10
export PATH="$HOME/dotnet:$PATH"

###################
# DEFAULT ALIASES #
###################
alias ll='ls -alF'
alias vs='psrun ./*.sln'
alias code='code .'
alias brc='source ~/.bashrc'
alias explore='explorer.exe .' 
alias bin='cd $HOME/bin'
alias psrun='powershell.exe'
alias copilot_env='psrun D:/wegmans/sap/sap-disintegrator/tools/Set-McpToken.ps1'
alias copilot_gh='copilot.exe'
alias copilot='copilot_env && copilot_gh'

#############################
# DEFAULT DIRECTORY ALIASES #
#############################
alias prj='cd "${prjDir}"'
alias usr='cd "${usrDir}"'
alias dsk='cd  "${usrDir}/Desktop"'
alias dwn='cd  "${usrDir}/Downloads"'
alias jgd='cd /mnt/d/.jgd.cfg'

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
costDir="${sapDir}/Cost"
bricksDir="${sapDir}/fps-databricks"

################
# WORK ALIASES #
################
alias el='cd "${elDir}"'
alias weg='cd "${wegDir}"'
alias cloud='cd "${cloudDir}"'
alias docs='cd "${docsDir}"'
alias cost='cd "${costDir}"'

# SAP Integration
alias sap='cd "${sapDir}"'
alias dis='export PROJECT_ROOT=$disDir; cd $PROJECT_ROOT'
alias loc='export PROJECT_ROOT=$locDir; cd $PROJECT_ROOT'
alias admin='export PROJECT_ROOT=$adminDir; cd $PROJECT_ROOT'
alias bricks='export PROJECT_ROOT=$bricksDir; cd $PROJECT_ROOT'

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
_set_git_prompt_line() {
  # Quick git dir check - exit early if not in git repo
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || {
    GIT_BRANCH=""
    GIT_MSG=""
    GIT_AUTHOR=""
    GIT_AHEAD_BEHIND=""
    GIT_STAGED_FILES=""
    return
  }

  # Get basic info with single git call for efficiency
  local git_info
  git_info=$(git log -1 --pretty="%H %h %an %s" 2>/dev/null)
  local full_commit="${git_info%% *}"
  local commit="${git_info#* }"; commit="${commit%% *}"
  local author="${git_info#* * }"; author="${author%% *}"
  local message="${git_info#* * * }"
  
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Single git status call for all file state info
  local git_status
  git_status=$(git status --porcelain 2>/dev/null)
  
  # Parse status efficiently
  local has_unstaged="" has_staged="" has_untracked="" staged_lines=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local x="${line:0:1}"
    local y="${line:1:1}"
    
    # Check staged (index) changes
    if [[ "$x" =~ [ADMRC] ]]; then
      has_staged=1
      local filename="${line:3}"
      case "$x" in
        "A") staged_lines+="        new file:   $filename"$'\n' ;;
        "M") staged_lines+="        modified:   $filename"$'\n' ;;
        "D") staged_lines+="        deleted:    $filename"$'\n' ;;
        "R") staged_lines+="        renamed:    $filename"$'\n' ;;
        "C") staged_lines+="        copied:     $filename"$'\n' ;;
      esac
    fi
    
    # Check unstaged (working tree) changes
    if [[ "$y" =~ [MD] ]] || [[ "$x$y" == "??" ]]; then
      if [[ "$x$y" == "??" ]]; then
        has_untracked=1
      else
        has_unstaged=1
      fi
    fi
  done <<< "$git_status"

  # Set status indicator
  local status_colored=""
  local show_staged_files=""
  if [[ -n "$has_unstaged" || -n "$has_untracked" ]]; then
    status_colored=$'\e[31m*\e[0m'  # Red * for unstaged/untracked
  elif [[ -n "$has_staged" ]]; then
    status_colored=$'\e[32m+\e[0m'  # Green + for staged only
    show_staged_files=1  # Only show staged files when clean except for staged
  fi

  # Ahead/behind counts (only if we have upstream)
  local ahead_behind=""
  if git rev-parse --verify @{u} >/dev/null 2>&1; then
    local counts
    counts=$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null)
    local behind="${counts%	*}"
    local ahead="${counts#*	}"
    if [[ "$ahead" -gt 0 || "$behind" -gt 0 ]]; then
      ahead_behind=$'     ↑'"${ahead}"'  ↓'"${behind}"
    fi
  fi

  # Set global variables
  GIT_BRANCH="(${branch}@${commit}${status_colored})"
  GIT_MSG="${message}"
  GIT_AUTHOR="<${author}>"
  GIT_AHEAD_BEHIND="${ahead_behind}"
  # Only show staged files if we have the green + (no unstaged/untracked changes)
  if [[ -n "$show_staged_files" ]]; then
    GIT_STAGED_FILES="${staged_lines:+$'\n\e[32m'}${staged_lines%$'\n'}${staged_lines:+$'\e[0m'}"
  else
    GIT_STAGED_FILES=""
  fi
}

PROMPT_COMMAND=_set_git_prompt_line
export PROMPT_DIRTRIM=2

# Line 1: user@path
# Line 2: branch@sha/status (yellow), commit msg (white), author (blue)
# Line 3 (optional): ahead/behind (purple) if present
# Line 4 (optional): staged files (green) if present
# Final line: $
export PS1='\u@\[\e[32m\]\w\[\e[0m\]\n     \[\e[33m\]${GIT_BRANCH}\[\e[37m\] ${GIT_MSG} \[\e[34m\]${GIT_AUTHOR}\[\e[0m\]${GIT_AHEAD_BEHIND:+\n\[\e[35m\]${GIT_AHEAD_BEHIND}\[\e[0m\]}${GIT_STAGED_FILES}\n\$ '

###########
# STARTUP #
###########
alias greeting='echo "Hello Jack!" && echo ""'

# run main tmux session at startup
main
