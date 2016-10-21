#!/bin/sh

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# prompt
export PROMPT_COMMAND='echo -ne "\033]0;${USER} ${PWD/#$HOME/~}\007"'

# history
export HISTTIMEFORMAT=`echo -ne "\033[0;33m[%m-%d-%Y %T] \033[0m"`

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

# cd
function _cd() {
  local destdir=$1
  local subdir=$2
  if [ -d "${destdir}" ]; then
    cd ${destdir}
    if [ -d "${subdir}" ]; then
      cd ${subdir}
    fi
  fi
  echo Current Directory: `pwd`
}

# ls
alias ll="ls -lFGh"
alias la="ls -aFGh"

# grep
alias grep="egrep --color=auto"
alias rgrep="egrep -r -n -I --color=auto"
alias hgrep="history | egrep --color=auto"
function cgrep() {
  egrep -r -n -I -c $* | grep -v ":0$"
}
function wgrep() {
  _openwin "grep watch" "19" "77" "{65535, 65535, 32767, 0}" "watch -n1 'grep $*'"
}
# Source repository greps
function sgrep() {
  local sgrep_opts="${@: 1:`expr $# - 1`}"
  local sgrep_dev_opts=${MY_DEV_GREP_OPTS}
  local sgrep_pattern="${@: -1}"
  egrep -r -n -I --color=always --exclude={.classpath,.project,*.pyc,*.class,*.min.js,*-min.js} --exclude-dir={.git,.idea,.svn,.settings,target,test-output} ${sgrep_opts} ${sgrep_dev_opts} "${sgrep_pattern}" . 2>&1 | egrep -v "Permission denied$"
}
function csgrep() {
  local sgrep_opts="${@: 1:`expr $# - 1`}"
  local sgrep_dev_opts=${MY_DEV_GREP_OPTS}
  local sgrep_pattern="${@: -1}"
  egrep -r -n -I -c --exclude={.classpath,.project,*.pyc,*.class,*.min.js,*-min.js} --exclude-dir={.git,.idea,.svn,.settings,target,test-output} ${sgrep_opts} ${sgrep_dev_opts} "${sgrep_pattern}" . 2>&1 | egrep -v "Permission denied$" | grep -v ":0$"
}
# Python greps
function pygrep() {
  sgrep --include=*.py "$@"
}
function pyygrep() {
  sgrep --include=*.py --exclude={*_test.py,*_tests.py} "$@"
}
function pytgrep() {
  sgrep --include={*_test.py,*_tests.py} "$@"
}
# Javascript greps
function jsgrep() {
  sgrep --include={*.js,*.jsx} --exclude={*.min.js,*-min.js} "$@"
}
function jstgrep() {
  sgrep --include={*_test.js,*_tests.js,*.spec.js} "$@"
}
function jssgrep() {
  sgrep --include={*.js,*.jsx} --exclude={*_test.js,*_tests.js,*.spec.js,*.min.js,*-min.js} "$@"
}
function njgrep() {
  sgrep --include={*.js,*.jsx} --exclude={*.min.js,*-min.js} --exclude-dir=node_modules "$@"
}
# HTML/CSS greps
function cssgrep() {
  sgrep --include=*.css "$@"
}
function htmgrep() {
  sgrep --include=*.htm* "$@"
}
# Java greps
function jgrep() {
  sgrep --include={*.java,*.jsp} "$@"
}
function jjgrep() {
  sgrep --include={*.java,*.jsp} --exclude={Test*.java,*Test.java} "$@"
}
function jspgrep() {
  sgrep --include=*.jsp "$@"
}
function jtgrep() {
  sgrep --include={Test*.java,*Test.java} "$@"
}
# XML greps
function xmlgrep() {
  sgrep --include=*.xml "$@"
}
# Maven greps
function pomgrep() {
  sgrep --include=*pom*.xml "$@"
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

# tr
alias trnl="tr '\n' ' '"

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
  -e "    do script \"osascript -e 'tell app \\\"Terminal\\\" to set custom title of window 1 to \\\"${winTitle}\\\"'; ${scriptCmd}\"" \
  -e "    set background color of first window to ${bgColor}" \
  -e "    set font size of first window to 10" \
  -e "    set number of rows of first window to ${numRows}" \
  -e "    set number of columns of first window to ${numCols}" \
  -e "  end if" \
  -e "end tell"
}
function _opentab() {
  local winTitle=$1
  local scriptCmd=$2
  osascript -e "tell application \"Terminal\"" \
  -e "  activate" \
  -e "  tell application \"System Events\" to keystroke \"t\" using command down" \
  -e "  repeat while contents of selected tab of window 1 starts with linefeed" \
  -e "    delay 0.01" \
  -e "  end repeat" \
  -e "  do script \"printf '\\\e]1;${winTitle}\\\a'; ${scriptCmd}\" in window 1" \
  -e "  delay 0.01" \
  -e "end tell"
}

# ntp
function ntpsync {
  sudo ntpupdate -u time.apple.com
}

# date/time math
function utcd {
  _utcdt "Local Time" $@
}
function utcu {
  _utcdt "UTC Time" -u $@
}
function _utcdt {
  local _opt=
  local _year=`date +%Y`
  local _month=`date +%m`
  local _dayofmonth=`date +%d`
  local _hour=`date +%H`
  local _minute=`date +%M`
  local _desc=${1}
  shift

  if [[ "${1}" =~ ^-[a-z]$ ]] ; then
    _opt=${1}
    shift
  fi

  if [[ "${1}" =~ ^[12][0-9][0-9][0-9]$ ]] ; then
    _year=${1}
    shift
  fi

  if [[ "${1}" =~ ^[0-9]$ || "${1}" =~ ^0[0-9]$ || "${1}" =~ ^1[0-2]$ ]] ; then
    if [[ "${1}" =~ ^[0-9]$ ]] ; then
      _month=0${1}
    else
      _month=${1}
    fi
    _hour=00
    _minute=00

    if [[ "${2}" =~ ^[0-9]$ || "${2}" =~ ^[0-2][0-9]$ || "${2}" =~ ^3[0-1]$ ]] ; then
      if [[ "${2}" =~ ^[0-9]$ ]] ; then
        _dayofmonth=0${2}
      else
        _dayofmonth=${2}
      fi

      if [[ "${3}" =~ ^[0-9]$ || "${3}" =~ ^[0-1][0-9]$ || "${3}" =~ ^2[0-3]$ ]] ; then
        if [[ "${3}" =~ ^[0-9]$ ]] ; then
          _hour=0${3}
        else
          _hour=${3}
        fi

        if [[ "${4}" =~ ^[0-9]$ || "${4}" =~ ^[0-5][0-9]$ ]] ; then
          if [[ "${4}" =~ ^[0-9]$ ]] ; then
            _minute=0${4}
          else
            _minute=${4}
          fi
        fi
      fi
    fi
  fi

  local result=`date ${_opt} -j ${_month}${_dayofmonth}${_hour}${_minute}${_year} +%s`
  local result_utc=`date -u -r ${result}`
  local result_local=`date -r ${result}`
  echo ""
  echo "${_desc}: ${_year}-${_month}-${_dayofmonth} ${_hour}:${_minute}:00"
  echo "  Current TZ: ${result_local}"
  echo "  UTC: ${result_utc}"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function utce {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=0
  fi
  _utcepoch ${input} "" ""
}
function utce2k {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=0
  fi
  _utcepoch ${input} "(Epoch 2000)" "-v+10957d"
}
function _utcepoch {
  local input=${1}
  local epochtype=${2}
  local adjust=${3}
  local val=${input}
  if [ "${val}" -gt 9999999999 ]; then
    val=`expr ${val} / 1000`
  fi
  local result_utc=`date ${adjust} -u -r ${val}`
  local result=`date ${adjust} -r ${val}`
  echo ""
  echo "From: ${input} ${epochtype}"
  echo "  Current TZ: ${result}"
  echo "  UTC: ${result_utc}"
  echo ""
}
function utcnow {
  local result_utc=`date -u`
  local result=`date +%s`
  local result_local=`date`
  echo ""
  echo "Time: Now"
  echo "  Current TZ: ${result_local}"
  echo "  UTC: ${result_utc}"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function _utcmath {
  local unit=${1}
  local unitname=${2}
  local offset=${3}

  if [ "${offset}" == "" ] ; then
    offset=+1
  elif [[ "${offset}" =~ ^-.* ]] ; then
    offset=${offset}
  elif [[ "${offset}" =~ ^\+.* ]] ; then
    offset=${offset}
  else
    offset=+${offset}
  fi
  local result=`date -v${offset}${unit} +%s`
  local result_utc=`date -v${offset}${unit} -u`
  local result_utc_iso=`date -v${offset}${unit} -u "+%Y-%m-%dT%H:%M:%S+00:00"`
  local result_local=`date -v${offset}${unit}`
  echo ""
  echo "Time: ${offset} ${unitname} from Now"
  echo "  Current TZ: ${result_local}"
  echo "  UTC: ${result_utc}"
  echo "  UTC ISO: ${result_utc_iso}"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}
function utcnm {
  _utcmath M Minutes ${1}
}
function utcnh {
  _utcmath H Hours ${1}
}
function utcnd {
  _utcmath d Days ${1}
}
function utcoffset {
  local result=`date +%z`
  echo ""
  echo "UTC Offset: ${result}"
  echo ""
}

# temperature conversion
function c2f() {
  local c0=$1
  echo "scale = 2; ${c0} * 9 / 500 + 32" | bc
}
function f2c() {
  local f0=$1
  echo "(${f0} - 32) * 500 / 9" | bc
}

# osx
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
# recursively remove all .DS_Store files
function rmds() {
  find . -name ".DS_Store" -exec rm -rf {} \;
}

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
function myclone() {
  local dbto=$1
  echo "drop database if exists ${dbto};" | mysql -u root
  echo "create database ${dbto};" | mysql -u root
  while [ ! "${2}" == "" ]; do
    local dbfrom=$2
    rm -f /tmp/${dbfrom}_schema.sql
    mysqldump -u root --no-data ${dbfrom} > /tmp/${dbfrom}_schema.sql
    mysql -u root -D ${dbto} < /tmp/${dbfrom}_schema.sql
    rm -f /tmp/${dbfrom}_schema.sql
    shift
  done
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
  svn diff --diff-cmd "/Users/tchan/dev/bin/svndiffmerge.sh" $*
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
# Shortcut to show git tags with pretty format
alias glt="git log --tags --no-walk --pretty=format:'%C(yellow)%h%Creset %Cred%D%Creset %Cgreen(%cd) %C(bold blue)<%an>%Creset' --date=local"
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
  shift
  git diff -w ${gitcommit}^1..${gitcommit} $*
}
# Shortcut to do git visual diff on a specific commit against the previous commit
function gvdiffc() {
  local gitcommit=$1
  # git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitcommit}^1..${gitcommit} 2> >(grep -v CoreText 1>&2)
  git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" ${gitcommit}^1..${gitcommit}
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
function gbnew() {
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
    #git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitbranch}..${newbranch} 2> >(grep -v CoreText 1>&2)
    #git difftool -d --no-symlinks -x "/Applications/PyCharm.app/Contents/MacOS/pycharm diff" ${gitbranch}..${newbranch}
    #git difftool -d --no-symlinks -x "/usr/local/bin/ksdiff" ${gitbranch}..${newbranch}
    git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" ${gitbranch}..${newbranch}
  fi
}
function gvdiff() {
  # git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" $* 2> >(grep -v CoreText 1>&2)
  git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" $*
}
# git whatchanged for a single commit
function gwhat() {
  local commitid=${1}
  git whatchanged ${commitid}^1..${commitid}
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

# bash-git-prompt
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Default
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

# xcode
function xcuse() {
  sudo xcode-select -s /Applications/Xcode${1}.app
}
function xcgo() {
  pushd /Applications/Xcode${1}.app/Contents/MacOS
  /Applications/Xcode${1}.app/Contents/MacOS/Xcode &
  popd
}

# android sdk
export ANDROID_HOME=~/dev/android-sdk-macosx
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
function avdnew() {
  # android create avd --force --name avd001 --target android-19
  android create avd --force --name avd001 --abi default/armeabi-v7a --target android-23
}
function avdclean() {
  rm -rf ~/.android/avd/*
}
function adevices() {
  adb devices -l
}
function ainstall() {
  local apk_file=${1}
  local device_id=${2}
  local not_ok=0
  if [ "${apk_file}" == "" ]; then
    echo "ERROR: missing apk_file"
    not_ok=1
  fi
  if [ "${device_id}" == "" ]; then
    device_id=`adb devices | head -2 | tail -1 | cut -f 1`
  fi
  if [ "${device_id}" == "" ]; then
    echo "ERROR: missing device_id"
    not_ok=1
  fi

  if [ "${not_ok}" == "1" ]; then
    echo "Usage: ainstall <apk_file> [<device_id>]"
  else
    adb -s ${device_id} install ${apk_file}
  fi
}

# java
export JAVA_VERSION=1.7
#export JAVA_VERSION=1.8
export JAVA_HOME=$(/usr/libexec/java_home -v ${JAVA_VERSION})

# maven
obsolete_maven_perm_gen_opt=""
if [ "${JAVA_VERSION}" == "1.7" ]; then
  obsolete_maven_perm_gen_opt="-XX:MaxPermSize=256m"
fi
export MAVEN_OPTS="-client -Duser.timezone=Etc/UTC -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss -Xmx512m ${obsolete_maven_perm_gen_opt}"

# python
# Ensure we use Python 2.7
python_version=$(python --version 2>&1)
if [ "${python_version:7:3}" != "2.7" ] && [ -f /Library/Frameworks/Python.framework/Versions/2.7/bin/python ]; then
  export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
fi
# recursively remove all *.pyc files
function rmpyc() {
  find . -name "*.pyc" -exec rm -rf {} \;
}
function pipsuper() {
  local packagename=$1
  local packagever=$2
  local installname=${packagename}
  if [ "$packagever" != "" ]; then
    installname=${packagename}==${packagever}
  fi
  pip install --allow-external=${packagename} ${installname}
}

# virtualenv
if [ "$MY_VENV_ROOT" == "" ]; then
  export MY_VENV_ROOT=~/dev/virtualenvs
fi
function veon() {
  local venv=$1
  if [ "$venv" == "" ]; then
    if [ "$MY_DEFAULT_VENV" == "" ]; then
      echo Cannot determine virtual env to use
    fi
    venv=${MY_DEFAULT_VENV}
  fi
  source ${MY_VENV_ROOT}/${venv}/bin/activate
}
function veoff() {
  deactivate
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

# visual diff
function vdiff() {
  # diffmerge
  # /Applications/DiffMerge.app/Contents/MacOS/DiffMerge -nosplash $* 2> >(grep -v CoreText 1>&2)
  # beyond compare
  /usr/local/bin/bcomp $* &
}

# docker toolbox
# shortcut to start docker toolbox vm if not running, and setup shell to use docker
export DOCKER_MACHINE_OPTS=
function _dtmachine() {
  local dtmachine=${1}
  if [ "$dtmachine" == "" ]; then
    dtmachine=${DOCKER_MACHINE_NAME}
  fi
  if [ "$dtmachine" == "" ]; then
    dtmachine=$(docker-machine ls -q | head -1)
  fi
  if [ "$dtmachine" == "" ]; then
    dtmachine=default
  fi
  echo $dtmachine
}
function dtrm() {
  local dtmachine=$(_dtmachine ${1})
  echo Removing Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
  docker-machine ${DOCKER_MACHINE_OPTS} rm $dtmachine
  echo Removing Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
}
function dtnew() {
  local dtmachine=$(_dtmachine ${1})
  local dtnewopts=
  if [ "$1" != "" ]; then
    shift
    dtnewopts=$*
  fi
  echo Creating Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
  docker-machine ${DOCKER_MACHINE_OPTS} create -d virtualbox --virtualbox-memory 3072 --virtualbox-disk-size 204800 --engine-insecure-registry images.ecofactor.com:5000 ${dtnewopts} $dtmachine
  echo Created Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
  dtgo $dtmachine
}
function dtgo() {
  local dtmachine_old=${DOCKER_MACHINE_NAME}
  local dtmachine=$(_dtmachine ${1})
  local dtstat=$(docker-machine ${DOCKER_MACHINE_OPTS} status $dtmachine)
  if [ "$dtstat" != "" ]; then
    if [ "$dtstat" != "Running" ]; then
      echo Starting Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
      docker-machine ${DOCKER_MACHINE_OPTS} start $dtmachine
      echo Started Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
    fi
    if [ "$dtmachine" != "$dtmachine_old" ]; then
      echo Configuring environment for Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
    fi
    dtswarmmaster=$(docker-machine ${DOCKER_MACHINE_OPTS} inspect -f "{{ .Driver.SwarmMaster }}" $dtmachine)
    dtenvopts=
    if [ "$dtswarmmaster" == "true" ]; then
      dtenvopts=--swarm
    fi
    eval $(docker-machine ${DOCKER_MACHINE_OPTS} env $dtenvopts --shell=bash $dtmachine)
  else
    echo Cannot find any Docker VM called $(tput setaf 4)${dtmachine}$(tput sgr0)
  fi
}
# shortcut to stop docker toolbox vm
function dtstop() {
  local dtmachine=$(_dtmachine ${1})
  local dtstat=$(docker-machine ${DOCKER_MACHINE_OPTS} status $dtmachine)
  if [ "$dtstat" != "Stopped" ]; then
    echo Stopping Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
    docker-machine ${DOCKER_MACHINE_OPTS} stop $dtmachine
    echo Stopped Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
  fi
}
# shortcut to upgrade docker toolbox vm memory
function dtsetmem() {
  local memsize=${1}
  local dtmachine=$(_dtmachine ${2})
  docker-machine stop $dtmachine
  VBoxManage modifyvm $dtmachine --memory $memsize
  docker-machine start $dtmachine
  docker-machine regenerate-certs $dtmachine
}
# shortcut to ssh into docker toolbox vm
function dtssh() {
  local dtmachine=$(_dtmachine ${1})
  _opentab "${dtmachine}" "docker-machine ${DOCKER_MACHINE_OPTS} ssh $dtmachine"
}
# shortcut to show the ip address of a docker toolbox vm
function dtip() {
  local dtmachine=$(_dtmachine ${1})
  echo IP address of Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) is:
  docker-machine ${DOCKER_MACHINE_OPTS} ip ${dtmachine}
}

# docker
# shortcut to show all containers
function dkps() {
  docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.RunningFor}}" $* | (read -r; printf "%s\n" "$REPLY"; sort)
}
# shortcut to show all images
function dkim() {
  docker images $* | (read -r; printf "%s\n" "$REPLY"; sort)
}
# shortcut to list all containers and their ip addresses
function dkips() {
  declare -a arr=($(docker ps -a -q))
  echo "Container ID   IP Address     Container Name"
  echo "-------------- -------------- --------------"
  for container_id in "${arr[@]}"; do
    container_ip=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${container_id})
    if [ "${container_ip}" == "" ]; then
      container_ip="-"
    fi
    container_name=$(docker inspect --format='{{ .Name }}' ${container_id})
    printf "%-14s %-14s %s\n" ${container_id} ${container_ip} ${container_name}
  done
}
# shortcut to show all runtime statistics of containers
function dkst() {
  docker stats --no-stream $(docker ps --format "{{.Names}}" | sort)
}
# shortcut to show the ip address of a container
function dkip() {
  local dkcontainer=$1
  if [ "$dkcontainer" == "" ]; then
    dkcontainer=`docker ps -laq`
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo IP address of docker container $(tput setaf 4)${dkname}$(tput sgr0) is:
  docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${dkcontainer}
}
# shortcut to show the exposed ports of a container
function dkport() {
  local dkcontainer=$1
  if [ "${dkcontainer}" == "" ] || [ "${dkcontainer:0:1}" == "-" ]; then
    dkcontainer=`docker ps -laq`
  else
    shift
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Ports of docker container $(tput setaf 4)${dkname}$(tput sgr0) include:
  docker port ${dkcontainer} $*
}
# shortcut to show logs from a container
function dkl() {
  local opts=""
  while true; do
    if [ "${1}" == "-f" ]; then
      opts="$opts -f"
      shift
    elif [ "${1}" == "-s" ]; then
      opts="$opts --since=`date +%s`"
      shift
    elif [ "${1}" == "" ]; then
      dkcontainer=`docker ps -laq`
      break
    else
      dkcontainer=${1}
      shift
      break
    fi
  done
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Logs from docker container $(tput setaf 4)${dkname}$(tput sgr0):
  docker logs ${opts} ${dkcontainer}
}
# shortcut to open an interactive shell in a container
function dksh() {
  local dkcontainer=$1
  if [ "${dkcontainer}" == "" ] || [ "${dkcontainer:0:1}" == "-" ]; then
    dkcontainer=`docker ps -laq`
  else
    shift
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Interactive shell into docker container $(tput setaf 4)${dkname}$(tput sgr0):
  docker exec -t -i ${dkcontainer} /bin/bash
}
# shortcut to delete all dangling images
function dkrmi0() {
  local dkimages=$(docker images -f "dangling=true" -q)
  if [ "$dkimages" != "" ]; then
    docker rmi $* $dkimages
  fi
}
# shortcut to delete all exited containers
function dkrm0() {
  local dkcontainers=$(docker ps -a -q -f status=exited)
  if [ "$dkcontainers" != "" ]; then
    docker rm -v $* $dkcontainers
  fi
}
# shortcut to delete all containers
function dkclean() {
  docker ps -a -q | xargs -n 1 -I {} docker rm {}
}
function _dktags() {
  local dkimage=$1
  local dkurl=https://registry.hub.docker.com/v2/repositories/library/${dkimage}/tags/
  while [ "$dkurl" != "" ] && [ "$dkurl" != "null" ]; do
    >&2 echo "Querying $(tput setaf 4)$dkurl$(tput sgr0) ..."
    curl -s -S $dkurl | jq -M '."results"[]["name"]'
    dkurl=$(curl -s -S $dkurl | jq -j -M '."next"')
  done
}
function dktags() {
  local dkimage=$1
  local jqinstalled=$(which jq)
  if [ "$jqinstalled" == "" ]; then
    echo Installing jq ...
    brew install jq
  fi
  _dktags $dkimage | sort
}
# shortcut to save images
function dkims() {
  local images_dir=${1:-/tmp/images}
  mkdir -p ${images_dir}
  declare -a arr=($(docker images -q -f "label=ecofactor.env=dev" | sort | uniq))
  for image_id in "${arr[@]}"; do
    image_repo_and_tag=$(docker inspect --format='{{with .RepoTags}}{{index . 0}}{{end}}' ${image_id})
    rm -f ${images_dir}/${image_id}.tar
    docker save -o ${images_dir}/${image_id}.tar ${image_repo_and_tag}
    echo Saved image $(tput setaf 4)${image_repo_and_tag}$(tput sgr0) to $(tput setaf 4)${images_dir}/${image_id}.tar$(tput sgr0)
  done
}
# shortcut to load images
function dkiml() {
  local images_dir=${1:-/tmp/images}
  for image_tar in ${images_dir}/*.tar; do
    echo Loading image from $(tput setaf 4)${image_tar}$(tput sgr0) ...
    docker load -i $image_tar
  done
}

# logstash
#function gologstash {
#  logstash agent -e 'input { log4j {port => 6678} } output { stdout {} }'
#}

# vagrant
#function vst() {
#  vagrant global-status
#}
#function vnew() {
#  local vhome=$1
#  if [ "$vhome" == "" ]; then
#    vhome=~/dev/vagrant
#  fi
#  _opentab "${vhome}" "cd ${vhome} && vagrant up"
#}
#function vkill() {
#  local vhome=$1
#  if [ "$vhome" == "" ]; then
#    vhome=~/dev/vagrant
#  fi
#  pushd . >/dev/null
#  cd ${vhome}
#  vagrant destroy -f
#  popd >/dev/null
#}
#function vssh() {
#  local vhome=$1
#  if [ "$vhome" == "" ]; then
#    vhome=~/dev/vagrant
#  fi
#  _opentab "${vhome}" "cd ${vhome} && vagrant ssh"
#}

# VirtualBox
# List running virtualboxes
function vbv {
  VBoxManage list runningvms
}
function vbst {
  local vmname=$1
  echo Starting VM "${vmname}" ...
  VBoxManage startvm "${vmname}" --type headless
  echo Ping VM "${vmname}" every 5 seconds ...
  ping -i 5 -o `VBoxManage guestproperty get ${vmname} /VirtualBox/GuestInfo/Net/1/V4/IP | cut -f 2 -d ' '`
}
function vbsh {
  local vmname=$1
  echo Stopping VM "${vmname}" ...
  VBoxManage controlvm "${vmname}" poweroff
}

# Nginx
if [ "$NGINX_HOME" == "" ]; then
  export NGINX_HOME=/usr/local/opt/nginx
fi
if [ "$NGINX_CONF_HOME" == "" ]; then
  export NGINX_CONF_HOME=/usr/local/etc/nginx
fi
function ntl() {
  pushd . >/dev/null
  _openwin "Nginx Server" "19" "77" "{57344, 65535, 57344, 0}" "tail -f ${NGINX_HOME}/logs/*.log"
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
  subl ${NGINX_CONF_HOME}/nginx.conf
}

# Redis
function rsh() {
  local pid=`ps a | grep redis-server | grep -v grep | sed 's/^ *//g' | cut -f 1 -d ' '`
  if [ "$pid" == "" ]; then
    echo Redis not running
  else
    kill $pid
    echo Redis stopped
  fi
  _closewin "Redis Server"
}
function rst() {
  _openwin "Redis Server" "19" "77" "{57344, 57344, 57344, 0}" "/usr/local/bin/redis-server /usr/local/etc/redis.conf"
}
function rflush() {
  /usr/local/bin/redis-cli flushall
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
function genrsa() {
  pushd ~ > /dev/null
  mkdir -p .ssh
  cd .ssh
  rm id_rsa
  rm id_rsa.pub
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -C "${MY_EMAIL}"
  ssh-add id_rsa
  touch authorized_keys
  cat id_rsa.pub > authorized_keys
  chmod 600 authorized_keys id_rsa
  popd >/dev/null
}
function rssh() {
  local sshhost=$1
  local sshuser=$2
  local sshport=$3
  local sshdomain=${MY_DOMAIN}
  if [ "$sshuser" == "" ]; then
    sshuser=$MY_SSH_USER
  fi
  if [ "$sshport" == "" ]; then
    sshport=$MY_SSH_PORT
  fi
  local sshportopt="-p ${sshport}"
  local certopt="-i ${MY_SSH_RSA}"
  if [ "$sshhost" != "" ]; then
    if [ "${sshhost/[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*}" == "" ]; then
      sshdomain=
      sshportopt=
      certopt=
    fi
  fi
  _opentab "${sshhost}" "ssh ${sshportopt} ${certopt} ${sshuser}@${sshhost}${sshdomain}"
}
# Example: rscp pjb1 /home/efdev/ecoapps/jboss-5.1.0.GA/server/all/log/gc.log ./gc.pjb1.log
function rscp() {
  local sshhost=$1
  local sshuser=$MY_SSH_USER
  local remotefilepath=$2
  local localfilepath=$3
  scp -P ${MY_SSH_PORT} -i ${MY_SSH_RSA} ${sshuser}@${sshhost}${MY_DOMAIN}:${remotefilepath} ${localfilepath}
}

# autoprefixer
function autoprefix {
  autoprefixer --no-cascade -b "> 5%, last 5 Chrome versions, IE >= 10, Firefox >= 24, ios >= 6, Android >= 4.0" $*
}

# imagemagick (brew install imagemagick)
function imginfo {
  identify -format "filename = %f; dimensions = %wx%h pixels; density = %xx%y; color = %[depth]-bit %[colorspace]\n" $*
}

# start eclipse from command line
function eclipse {
  "/Applications/Eclipse.app/Contents/MacOS/eclipse" $* 2>&1 &
}

# browsers
function _openchrome {
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" $* 2>&1 &
}

# Dev Path
if [ -f /Users/tchan/repo/Platform/deployment/tools/bin/buildAll ]; then
  export PATH=/Users/tchan/repo/Platform/deployment/tools/bin:$PATH
fi

# other development-specific bash setup
if [ -f ~/dev/dev_bashrc.sh ]; then
  source ~/dev/dev_bashrc.sh
fi

# ulimit
#ulimit -n 4096
