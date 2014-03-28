#!/bin/sh

# source
alias srcsh="source ~/.bashrc"

# ls
alias ll="ls -lFGh"
alias la="ls -aFGh"

# grep
alias grep="egrep --color=auto"
alias rgrep="egrep -r -n -I --color=auto"
function cgrep() {
  egrep -r -n -I --color=auto -c $* | grep -v ":0$"
}

# find
function fp() {
  find . -name ${1} -print
}
function fpw() {
  find . -name "*${1}*" -print
}

# osx
# recursively remove all .DS_Store files
function rmds() {
  find . -name ".DS_Store" -exec rm -rf {} \;
}

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

# svn
function svnlog7() {
  local logtarget=${1}
  if [ "$logtarget" == "" ] ; then
    logtarget=.
  fi
  local sevendaysago=`date -v-7d "+%Y-%m-%d"`
  svn log -v -r HEAD:{$sevendaysago} ${logtarget} | less
}

# git
export GIT_DEFAULT_BRANCH=develop
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
# Shortcut to show remote branch details
alias grso="git remote show origin"
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
  	searchstr=${GIT_DEFAULT_BRANCH}
  fi
  local newbranch=`git rev-parse --abbrev-ref --branches=${searchstr}* | head -1`
  if [ "$newbranch" == "" ] ; then
    newbranch=`git rev-parse --abbrev-ref --branches=*${searchstr}* | head -1`
  fi
  if [ "$newbranch" == "" ] ; then
  	echo Cannot find branch ${searchstr}, switching to ${GIT_DEFAULT_BRANCH} instead
    git checkout ${GIT_DEFAULT_BRANCH}
  else
    git checkout $newbranch
  fi
}
# Shortcut to create new local branch from current local branch, and then push it as a new remote branch
function gbnb() {
  local newbranchname=${1}
  git checkout -b ${newbranchname}
  git push -u origin ${newbranchname}
}
# Shortcut to list all local branches
alias gbv="git branch -v"
# Shortcut to list all remote branches
alias gbvr="git branch -r"
# Shortcut to use git difftool to compare current branch with another branch
function gbc() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=${GIT_DEFAULT_BRANCH}
  fi
  local newbranch=`git rev-parse --abbrev-ref --branches=${searchstr}* | head -1`
  if [ "$newbranch" == "" ] ; then
    newbranch=`git rev-parse --abbrev-ref --branches=*${searchstr}* | head -1`
  fi
  if [ "$newbranch" == "" ] ; then
    echo Cannot find branch matching "*"${searchstr}"*"
  elif [ "${gitbranch}" == "${newbranch}" ] ; then
    echo Cannot compare ${gitbranch} branch to itself
  else
    echo Compare ${gitbranch}..${newbranch}
    git difftool -d -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitbranch}..${newbranch}
    #git difftool -d -x "/Applications/PyCharm.app/Contents/MacOS/pycharm diff" ${gitbranch}..${newbranch}
    #git difftool -d -x "/usr/local/bin/ksdiff" ${gitbranch}..${newbranch}
  fi
}
function gvdiff() {
  git difftool -d -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" $*
}

# git flow
# Shortcut to start new feature branch from current local branch using git flow
function gffst() {
  local featurebranchname=${1}
  git flow feature start ${featurebranchname}
}
# Shortcut to finish feature branch using git flow
function gffsh() {
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=`git rev-parse --abbrev-ref HEAD`
    if [ "${searchstr:0:8}" == "feature/" ] ; then
      searchstr=${searchstr:8}
    fi
  fi
  foundbranch=`git rev-parse --abbrev-ref --branches=feature/*${searchstr}* | head -1`
  if [ "$foundbranch" == "" ] ; then
    echo Cannot find feature matching "*"${searchstr}"*"
  else
    echo Finish feature ${foundbranch:8}
    git flow feature finish ${foundbranch:8}
  fi
}

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -iR"

# java 1.6
export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)

# python
# recursively remove all *.pyc files
function rmpyc() {
  find . -name "*.pyc" -exec rm -rf {} \;
}

# node.js
export NODE_PATH=/usr/local/lib/node_modules
function npmlsg() {
  npm -g ls --depth=0 2>/dev/null
}
function npmls() {
  npm ls --depth=0 2>/dev/null
}

# diffmerge
alias vdiff="/Applications/DiffMerge.app/Contents/MacOS/DiffMerge -nosplash"

# development-specific shortcuts
if [ -f ~/dev/dev_bashrc.sh ]; then
  source ~/dev/dev_bashrc.sh
fi

# ulimit
#ulimit -n 4096
