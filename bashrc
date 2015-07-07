#!/bin/sh

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# prompt
export PROMPT_COMMAND='echo -ne "\033]0;${USER} ${PWD/#$HOME/~}\007"'

# source
alias srcs="source ~/.bashrc"

# development-specific bash environments
if [ -f ~/dev/dev_bashrc_env.sh ]; then
  source ~/dev/dev_bashrc_env.sh
fi

# clear
function clr() {
  clear
  clear
}

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
  find . -name ${1} -print 2> /dev/null
}
function fpw() {
  find . -name "*${1}*" -print 2> /dev/null
}

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -iR"

# Terminal
function _closewin() {
  local winTitle=$1
  osascript -e "tell app \"Terminal\"" \
  -e "  repeat with win in windows" \
  -e "    if (name of win as string) contains \"${winTitle}\" then" \
  -e "      tell win to close" \
  -e "      exit repeat" \
  -e "    end if" \
  -e "  end repeat" \
  -e "end tell"
#  osascript -e "tell app \"iTerm\"" \
#  -e "  activate" \
#  -e "  repeat with mytab in every tab" \
#  -e "    if (name of mytab) contains \"${winTitle}\" then" \
#  -e "      tell mytab to close" \
#  -e "      exit repeat" \
#  -e "    end if" \
#  -e "  end repeat" \
#  -e "end tell"
}
function _openwin() {
  local winTitle=$1
  local numRows=$2
  local numCols=$3
  local bgColor=$4
  local scriptCmd=$5
  if [ "$numRows" == "" ]; then
    numRows=50
  fi
  if [ "$numCols" == "" ]; then
    numCols=100
  fi
  if [ "$bgColor" == "" ]; then
    bgColor="{65535,65535,65535,0}"
  fi
  osascript -e "tell app \"Terminal\"" \
  -e "  set found to \"false\"" \
  -e "  set win_titles to name of every window" \
  -e "  repeat with win_title in win_titles" \
  -e "    if (win_title as string) contains \"${winTitle}\" then" \
  -e "      set found to \"true\"" \
  -e "      exit repeat" \
  -e "    end if" \
  -e "  end repeat" \
  -e "  if found = \"false\" then" \
  -e "    do script \"${scriptCmd}\"" \
  -e "    set background color of first window to ${bgColor}" \
  -e "    set font size of first window to 10" \
  -e "    set number of rows of first window to ${numRows}" \
  -e "    set number of columns of first window to ${numCols}" \
  -e "    set custom title of first window to \"${winTitle}\"" \
  -e "  end if" \
  -e "end tell"
}
function _opentab() {
  local scriptCmd=$1
  osascript -e "tell application \"Terminal\"" \
  -e "activate" \
  -e "tell application \"System Events\" to keystroke \"t\" using command down" \
  -e "repeat while contents of selected tab of window 1 starts with linefeed" \
  -e "    delay 0.01" \
  -e "end repeat" \
  -e "do script \"${scriptCmd}\" in window 1" \
  -e "end tell"
}

# date
function utce {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=0
  fi
  local result_utc=`date -u -r ${input}`
  local result=`date -r ${input}`
  echo ""
  echo "From: ${input}"
  echo "  UTC: ${result_utc}"
  echo "  Current TZ: ${result}"
  echo ""
}
function utcnow {
  local result=`date +%s`
  echo ""
  echo "Time: Now"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function utcnm {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=1
  fi
  local result=`date -v+${input}M +%s`
  echo ""
  echo "Time: ${input} Minutes from Now"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function utcnd {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=1
  fi
  local result=`date -v+${input}d +%s`
  echo ""
  echo "Time: ${input} Days from Now"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function utcoffset {
  local result=`date +%z`
  echo ""
  echo "UTC Offset: ${result}"
  echo ""
}

# osx
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
# recursively remove all .DS_Store files
function rmds() {
  find . -name ".DS_Store" -exec rm -rf {} \;
}

# maven
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=256m"

# mysql
if [ "$MYSQL_HOME" == "" ]; then
  export MYSQL_HOME=/usr/local/mysql
fi
export PATH=${MYSQL_HOME}/bin:$PATH
#alias mysql=${MYSQL_HOME}/bin/mysql
#alias mysqladmin=${MYSQL_HOME}/bin/mysqladmin
#export DYLD_LIBRARY_PATH=${MYSQL_HOME}/lib/:$DYLD_LIBRARY_PATH
function mystart() {
  pushd ${MYSQL_HOME}
  sudo ./bin/mysqld_safe &
  popd
}
function my() {
  if [ "$1" == "" ] ; then
    mysql -u root
  else
    mysql -u root -D $1
  fi
}
function mycfg() {
  subl ${MYSQL_HOME}/my.cnf
}

# sqllite
function sl() {
  sqlite3 -header -column $1
}

# svn
# Shortcut to show svn status
function svs() {
  local svntarget=${1}
  if [ "$svntarget" == "" ] ; then
    svntarget=.
  fi
  svn status ${svntarget} | less
}
# Shortcut to do svn update
function svu() {
  local svntarget=${1}
  if [ "$svntarget" == "" ] ; then
    svntarget=.
  fi
  svn update ${svntarget}
}
# Shortcut to do svn add
alias sva="svn add"
# Shortcut to do svn commit
alias svc="svn commit -m"
# Shortcut to do svn revert recursively
alias svrr="svn revert -R"
# Shortcut to show svn log from the last N days
function svln() {
  local svnlogdays=${1}
  local svntarget=${2}
  if [ "$svntarget" == "" ] ; then
    svntarget=.
  fi
  local ndaysago=`date -v-${svnlogdays}d "+%Y-%m-%d"`
  svn log -v -r HEAD:{$ndaysago} ${svntarget} | less
}
# Shortcut to show svn log from the last 7 days
function svl7() {
  svln 7 ${1}
}
# svn diff using DiffMerge
function svdiff() {
  svn diff --diff-cmd "/Users/tchan/dev/bin/svndiffmerge.sh" -x "-nosplash" $*
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
  git stash clear
  git stash
  git pull
  git stash pop
  git stash clear
}
# Shortcut to do git push to correct remote branch
function gpush() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  git push origin $gitbranch $*
}
# Shortcut to do set remote branch as upstream
function gbtrack() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  git branch --set-upstream-to=origin/$gitbranch $gitbranch $*
}
# Shortcut to do git diff and ignore whitespace differences
alias gdiff="git diff -w"
# Shortcut to do git diff on a specific commit against the previous commit
function gdiffc() {
  local gitcommit=$1
  git diff -w ${gitcommit}^1..${gitcommit}
}
# Shortcut to do git visual diff on a specific commit against the previous commit
function gvdiffc() {
  local gitcommit=$1
  git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitcommit}^1..${gitcommit} 2> >(grep -v CoreText 1>&2)
}
# Shortcut to show list of git-ignored files in working directory
alias gignored="git ls-files -o -i --exclude-standard"
# Shortcut to show remote branch details
alias grso="git remote show origin | grep -v 'stale '"
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
  git branch --set-upstream-to=origin/$gitbranch ${newbranchname}
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
    git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitbranch}..${newbranch} 2> >(grep -v CoreText 1>&2)
    #git difftool -d --no-symlinks -x "/Applications/PyCharm.app/Contents/MacOS/pycharm diff" ${gitbranch}..${newbranch}
    #git difftool -d --no-symlinks -x "/usr/local/bin/ksdiff" ${gitbranch}..${newbranch}
  fi
}
function gvdiff() {
  git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" $* 2> >(grep -v CoreText 1>&2)
}

# git flow
# Shortcut to start new feature branch from current local branch using git flow
function gffnew() {
  local featurebranchname=${1}
  echo Start feature ${featurebranchname}
  git flow feature start ${featurebranchname}
}
# Shortcut to finish feature branch using git flow
function gffend() {
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=`git rev-parse --abbrev-ref HEAD`
    if [ "${searchstr:0:8}" == "feature/" ] ; then
      searchstr=${searchstr:8}
    fi
  fi
  local foundbranch=`git rev-parse --abbrev-ref --branches=feature/*${searchstr}* | head -1`
  if [ "$foundbranch" == "" ] ; then
    echo Cannot find feature matching "*"${searchstr}"*"
  else
    echo Finish feature ${foundbranch:8}
    git flow feature finish ${foundbranch:8}
  fi
}
# Shortcut to publish a feature
function gffpub() {
  local searchstr=${1}
  local foundbranch=`git rev-parse --abbrev-ref --branches=feature/*${searchstr}* | head -1`
  if [ "$foundbranch" == "" ] ; then
    echo Cannot find feature matching "*"${searchstr}"*"
  else
    echo Publish feature ${foundbranch:8}
    git flow feature publish ${foundbranch:8}
  fi
}
# Shortcut to pull a feature
function gffget() {
  local featurebranchname=${1}
  echo Pull and track feature ${featurebranchname}
  git flow feature track ${featurebranchname}
}
# Shortcut to search a git commit based on a search string
function gcfind() {
  git show --name-only --oneline :/"$@"
}

# xcode
function xcuse() {
  sudo xcode-select -s /Applications/Xcode${1}.app
}
function xcrun() {
  pushd /Applications/Xcode${1}.app/Contents/MacOS
  /Applications/Xcode${1}.app/Contents/MacOS/Xcode &
  popd
}

# android sdk
export ANDROID_HOME=~/Developer/Library/Android
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
function avdnew() {
  android create avd --force --name avd001 --target android-19
}
function avdclean() {
  rm -rf ~/.android/avd/*
}

# java
# export JAVA_VERSION=1.6
export JAVA_VERSION=1.7
export JAVA_HOME=$(/usr/libexec/java_home -v ${JAVA_VERSION})

# python
# recursively remove all *.pyc files
function rmpyc() {
  find . -name "*.pyc" -exec rm -rf {} \;
}

# javascript
function jsc() {
  /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc $*
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
function vdiff() {
  /Applications/DiffMerge.app/Contents/MacOS/DiffMerge -nosplash $* 2> >(grep -v CoreText 1>&2)
}

# docker
# shortcut to delete all containers
function dkclean() {
  sudo docker ps -a -q | xargs -n 1 -I {} sudo docker rm {}
}
# shortcut to delete all un-tagged (or intermediate) images
function dkpurge() {
  sudo docker rmi $( sudo docker images | grep '&lt;none&gt;' | tr -s ' ' | cut -d ' ' -f 3)
}

# logstash
function gologstash {
  logstash agent -e 'input { log4j {port => 6678} } output { stdout {} }'
}

# vagrant
function vst() {
  vagrant global-status
}
function vnew() {
  local vhome=$1
  if [ "$vhome" == "" ]; then
    vhome=~/dev/vagrant
  fi
  _opentab "cd ${vhome} && vagrant up"
}
function vkill() {
  local vhome=$1
  if [ "$vhome" == "" ]; then
    vhome=~/dev/vagrant
  fi
  pushd . >/dev/null
  cd ${vhome}
  vagrant destroy -f
  popd >/dev/null
}
function vssh() {
  local vhome=$1
  if [ "$vhome" == "" ]; then
    vhome=~/dev/vagrant
  fi
  _opentab "cd ${vhome} && vagrant ssh"
}

# VirtualBox
# List running virtualboxes
function vbst {
  VBoxManage list runningvms
}

# Nginx
if [ "$NGINX_HOME" == "" ]; then
  export NGINX_HOME=/usr/local/opt/nginx
fi
function ntl() {
  pushd . >/dev/null
  _openwin "Nginx Server" "50" "100" "{57344, 65535, 57344, 0}" "tail -f ${NGINX_HOME}/logs/*.log"
  popd >/dev/null
}
function ncl() {
  if ls ${NGINX_HOME}/logs/*.log &> /dev/null; then
    rm -f ${NGINX_HOME}/logs/*.log
    echo Nginx logs cleaned
  else
    echo Nginx logs already cleaned
  fi
}
function nsh() {
  if [ -f /usr/local/var/run/nginx.pid ]; then
    sudo ${NGINX_HOME}/bin/nginx -s stop
    echo Nginx stopped
  else
    echo Nginx already stopped
  fi
  _closewin "Nginx Server"
}
function nst() {
  sudo ${NGINX_HOME}/bin/nginx
  echo Nginx started
  ntl
}
function ncfg() {
  subl ${NGINX_HOME}/nginx.conf
}

# ssh
if [ "$MY_SSH_RSA" == "" ]; then
  export MY_SSH_RSA=~/.ssh/`whoami`.rsa
fi
if [ "$MY_SSH_USER" == "" ]; then
  export MY_SSH_USER=root
fi
if [ "$MY_SSH_PORT" == "" ]; then
  export MY_SSH_PORT=19122
fi
function rssh() {
  local sshhost=$1
  local sshuser=$2
  if [ "$sshuser" == "" ]; then
    sshuser=$MY_SSH_USER
  fi
  _opentab "ssh -p ${MY_SSH_PORT} -i ${MY_SSH_RSA} ${sshuser}@${sshhost}${MY_DOMAIN}"
}

# autoprefixer
function autoprefix {
  autoprefixer --no-cascade -b "> 5%, last 5 Chrome versions, IE >= 10, Firefox >= 24, ios >= 6, Android >= 4.0" $*
}

# browsers
function _openchrome {
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" $* 2>&1 &
}

# other development-specific bash setup
if [ -f ~/dev/dev_bashrc.sh ]; then
  source ~/dev/dev_bashrc.sh
fi

# ulimit
#ulimit -n 4096
