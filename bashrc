#!/bin/sh

# source
alias srcsh="source ~/.bashrc"

# ls
alias ll="ls -lFGh"
alias la="ls -aFGh"

# grep
alias grep="egrep --color=auto"
alias rgrep="egrep -r -n --color=auto"

# mysql
export PATH=/usr/local/mysql/bin:$PATH
#alias mysql=/usr/local/mysql/bin/mysql
#alias mysqladmin=/usr/local/mysql/bin/mysqladmin
#export DYLD_LIBRARY_PATH=/usr/local/mysql/lib/:$DYLD_LIBRARY_PATH
function my() {
  if [ "$1" == "" ] ; then
    mysql -u root
  else
    mysql -u root -D $1
  fi
}

# git
# Shortcut to show git status
alias gs="git status"
# Shortcut to show git status as well as what is in the git stash stack
function gss() {
  git status
  echo ' '
  echo '# git stash list'
  git --no-pager stash list
}
# Shortcut to show git log with pretty format
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local"
# Shortcut to do git add with -A option to also add those removals to staging index
alias ga="git add -v -A"
# Shortcut to do git commit with message
alias gc="git commit -m"
# Shortcut to do ammended git commit with message
alias gca="git commit --amend -m"
# Shortcut to do non-fast-forward git merge
alias gm="git merge --no-ff"
# Shortcut to do git pull
alias gpull="git pull"
# Shortcut to first stash working copy changes and do git pull and then pop and merge the stashed changes
function gpulls() {
  git stash
  git pull
  git stash pop
}
# Shortcut to do git push to correct remote branch
function gpush() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  git push origin $gitbranch
}
# Shortcut to do git diff and ignore whitespace differences
alias gdiff="git diff -w"
# Shortcut to show list of git-ignored files in working directory
alias gignored="git ls-files -o -i --exclude-standard"
# Shortcut to create new local branch to follow remote branch
function grb() {
  git fetch origin $1
  if [ $? -eq 0 ]; then
    git checkout -B $1 origin/$1
  fi
}
# Shortcut to switch current local branch based on search string
function gb() {
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
  	searchstr=master
  fi
  local newbranch=`git rev-parse --abbrev-ref --branches=${searchstr}* | head -1`
  if [ "$newbranch" == "" ] ; then
    newbranch=`git rev-parse --abbrev-ref --branches=*${searchstr}* | head -1`
  fi
  if [ "$newbranch" == "" ] ; then
  	echo Cannot find branch ${searchstr}
    git checkout master
  else
    git checkout $newbranch
  fi
}

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -iR"

# java
export JAVA_HOME=$(/usr/libexec/java_home)

# node.js
export NODE_PATH=/usr/local/lib/node_modules

# diffmerge
alias vdiff="/Applications/DiffMerge.app/Contents/MacOS/DiffMerge -nosplash"

# development-specific shortcuts
if [ -f ~/dev/dev_bashrc.sh ]; then
  source ~/dev/dev_bashrc.sh
fi

# ulimit
#ulimit -n 4096
