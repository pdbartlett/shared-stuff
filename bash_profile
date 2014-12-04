# Get aliases to a known, clean state before we start
unalias -a

# Set shell prompt to something pretty if terminal supports it
function updatePrompt {
  if [ "$TERM" == "dumb" ]; then
    export PS1="[local] \w \$ "
  else
    export PS1="\[\033[0;37m\][local] \[\033[0;36m\]\w\[\033[0m\] \$ "
  fi
}
export PROMPT_COMMAND=updatePrompt

# Shell utils
alias df='df -h'
alias l='ls -lhF'
alias la='ls -alhF'
function md() {
  mkdir $1 && cd $1
}
function qpopd() {
  popd "$@" >/dev/null
}
function qpushd() {
  pushd "$@" >/dev/null
}
function which() {
  if [ "$1" == "-s" ]; then
    /usr/bin/which "$@"
  else
    ls -lhF $(/usr/bin/which "$@")
  fi
}

# Editing
export EDITOR=vim
alias edd="$EDITOR"
alias edrc="$EDITOR ~/.bash_profile && . ~/.bash_profile"
alias edcrc="$EDITOR ~/conf/bash_profile && . ~/.bash_profile"
alias rebash='. ~/.bash_profile'

# User bin, Greenfoot and Clojure
PATH="${PATH}:${HOME}/bin:${HOME}/bin/greenfoot:${HOME}/.cljr/bin"

# ABC/M4
function a4() {
  local stem=${1%\.abc4}
  local temp=${stem}_gen.abc
  m4 ${stem}.abc4 >$temp
  local suffix=${2:-mid}
  case $suffix in
    mid) abc2midi $temp -o ${stem}.mid ;;
    pdf) abcm2ps  $temp -O - | ps2pdf -sPAPERSIZE=a4 - > ${stem}.pdf ;;
    ps)  abcm2ps  $temp -O ${stem}.ps ;;
  esac
}

# Git
function g() {
  case $1 in
    pullall)
      qpushd $HOME
      echo "conf..."; cd conf; g pull
      echo "src..."; cd ../src;  g pull
      qpopd ;;
    *) git "$@" ;;
  esac
}

# Homebrew
PATH="$PATH:/usr/local/sbin:/usr/local/bin"
function chorme() {
  if [[ ! -d /usr/local ]] ; then return 1; fi
  if [[ ! -w /usr/local ]] ; then sudo chown -R pdbartlett /usr/local; fi
} 
alias bh='brew home'
alias bi='chorme && brew install'
alias bs='brew search'
function buu() {
  chorme && brew update && echo '---' && brew outdated && brew upgrade
}

# Middleman
function mex() {
  local action=''
  local bem='bundle exec middleman'
  local bemflags=''
  local post=''
  while [ -n "$1" ]
  do
    case $1 in
      # Custom
      all)     shift; _mex_all "$@"; return ;;
      clean)   bemflags="$bemflags --clean" ;;
      deploy)  post="$bem deploy" ;;
      gae)     post='dev_appserver.py gae' ;;
      install) bundle install ;;
      server)  post="$bem server" ;;
      verbose) bemflags="$bemflags --verbose" ;;
      # Pass through to BEM
      build) action=$1 ;;
      # Unknown
      *) echo "Action $1 is not recognised"; return ;;
    esac
    shift
  done
  if [ -n "$action" ]; then $bem $action $bemflags || return; fi
  if [ -n "$post" ]; then $post; fi
}
function _mex_all() {
  if [ -z "$1" ]; then echo "No command specified to 'mex all'"; return; fi
  qpushd ~/src/web
  for f in */Gemfile
  do
    local p=$(dirname $f)
    echo "*** Processing $p ***"
    cd $p
    mex "$@"
    cd ..
  done
  qpopd
}

# R
alias rr='cd ~/rtmp; r --no-save; cd - >/dev/null'

# RVM
PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
function rvm-check() {
  local stable=https://raw.githubusercontent.com/wayneeseguin/rvm/master/VERSION
  local installed=/Users/pdbartlett/.rvm/VERSION
  if ( curl $stable | diff $installed - ); then
    echo "Already up-to-date."
  else
    rvm get stable
  fi
  more $installed
}

# Scala, etc.
export SBT_OPTS='-XX:MaxPermSize=128M -Xmx8192M'
alias kojo='nohup /Applications/Kojo2/bin/kojo >/dev/null 2>&1 &'

# Combined
function utd() {
  sudo -v
  if [[ "$1" == "-g" ]]; then
    echo '** Github'
    g pullall
    echo
  fi
  if which -s brew; then
    echo '** Homebrew'
    buu
  fi
  if which -s rvm; then
    echo; echo '** RVM'
    rvm-check
  fi
  if which -s gem; then
    echo; echo '** Ruby Gems'
    if which -s rvm; then
       gem update
    else
       sudo gem update
    fi
  fi
}

# Tidy up path
PATH=$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')
