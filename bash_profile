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

# Editing
export EDITOR=vim
alias edd="$EDITOR"
alias edrc="$EDITOR ~/.bash_profile && . ~/.bash_profile"
alias edcrc="$EDITOR ~/conf/bash_profile && . ~/.bash_profile"
alias rebash='. ~/.bash_profile'

# Clojure
PATH="${PATH}:${HOME}/.cljr/bin"

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
PATH="/usr/local/sbin:/usr/local/bin:$PATH"
function chorme() {
  if [[ ! -w /usr/local ]] ; then sudo chown -R pdbartlett /usr/local; fi
} 
alias bh='brew home'
alias bi='chorme && brew install'
alias bs='brew search'
function buu() {
  chorme && brew update && brew outdated && brew upgrade
}

# Middleman
function mex() {
  local bem='bundle exec middleman'
  local clean=''
  local verbose=''
  while [ -n "$1" ]
  do
    case $1 in
      all)     shift; _mex_all "$@"; return ;;
      build)   $bem build $clean $verbose ;;
      clean)   clean='--clean' ;;
      deploy)  $bem deploy ;;
      gae)     dev_appserver.py gae ;;
      install) bundle install ;;
      server)  $bem server ;;
      verbose) verbose='--verbose' ;;
      *)       echo "Unrecognized command: $1"; return ;;
    esac
    shift
  done
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

# RVM
function rvm-check() {
  local stable=https://raw.github.com/wayneeseguin/rvm/master/VERSION
  local installed=/Users/pdbartlett/.rvm/VERSION
  if ( curl $stable | diff $installed - ); then
    echo "Already up-to-date."
  else
    rvm get stable
  fi
  more $installed
}

# Scala / SBT
export SBT_OPTS='-XX:MaxPermSize=128M -Xmx8192M'
alias kojo='nohup /Applications/Kojo2/bin/kojo >/dev/null 2>&1 &'

# Combined
function utd() {
  if [[ "$1" == "-g" ]]; then
    echo '** Github'
    g pullall
    echo
  fi
  echo '** Homebrew'; buu
  echo; echo '** RVM'; rvm-check
  echo; echo '** Ruby Gems'; sudo gem update
}

### Added by RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Tidy up path
PATH=$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')
