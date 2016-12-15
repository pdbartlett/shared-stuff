# .bash(rc|_profile) extract for common setup.

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
function witch() {
  if which -s $1; then ls -lhF $(which $1); fi
}

# Editing
export EDITOR=vim
alias edd="$EDITOR"
alias edrc="$EDITOR ~/.bash_profile && . ~/.bash_profile"
alias edcrc="$EDITOR ~/conf/bash_profile && . ~/.bash_profile"
alias rebash='. ~/.bash_profile'

# Homebrew (should be first)
if [[ -d "$HOME/homebrew" ]]; then
  PATH="$PATH:$HOME/homebrew/bin"
else
  PATH="$PATH:/usr/local/sbin:/usr/local/bin"
fi
if which -s brew; then
  alias bh='brew home'
  alias bi='brew install'
  alias bs='brew search'
  function buu() {
    brew update && echo '---' && brew outdated && brew upgrade --all && brew cleanup
  }
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# ABC
if which -s abc2midi; then
  if which -s m4; then
    function a4() {
      local stem=${1%\.abc4}
      local temp=${stem}_gen.abc
      m4 ${stem}.abc4 >$temp
      abc $temp ${2:-mid}
    }
  fi

  function abc() {
    local stem=${1%\.abc}
    local suffix=${2:-mid}
    case $suffix in
      mid) abc2midi $1 -o ${stem}.mid ;;
      pdf) abcm2ps  $1 -O - | ps2pdf -sPAPERSIZE=a4 - > ${stem}.pdf ;;
      ps)  abcm2ps  $1 -O ${stem}.ps ;;
    esac
  }
fi

# Bazel
if which -s bazel; then
  alias blaze='bazel'
  if complete -p bazel 2>/dev/null; then
    BLAZE_COMP=$(complete -p bazel | sed 's/bazel$/blaze/g') && $BLAZE_COMP
  fi
fi

# Git
if which -s git; then
  alias g='git'
  if complete -p git 2>/dev/null; then
    G_COMP=$(complete -p git | sed 's/git$/g/g') && $G_COMP
  fi
fi

# RVM
if [[ -d $HOME/.rvm ]]; then
  PATH="$PATH:$HOME/.rvm/bin"
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  function rvm-check() {
    local stable=https://raw.githubusercontent.com/wayneeseguin/rvm/master/VERSION
    local installed=/Users/pdbartlett/.rvm/VERSION
    if ( curl -s $stable | diff $installed - ); then
      echo "Already up-to-date."
    else
      rvm get stable
    fi
    more $installed
  }
fi

# Scala
if which -s scala; then export SBT_OPTS='-XX:MaxPermSize=128M -Xmx8192M'; fi

# Utilities
function utd() {
  sudo -v
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

# Switch to 'usual' Ruby/Gems
rvm 2.2.4@webdev

# Tidy up path
PATH=$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')
