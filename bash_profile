# .bash_profile extract for common setup.
# vim: syn=sh

# Get aliases to a known, clean state before we start
unalias -a

# Set shell prompt to something pretty if terminal supports it
function updatePrompt {
  if [[ "${TERM}" == "dumb" ]]; then
    export PS1="[local] \w \$ "
  else
    export PS1="\[\033[0;37m\][local] \[\033[0;36m\]\w\[\033[0m\] \$ "
  fi
}
export PROMPT_COMMAND=updatePrompt

# Editing
export EDITOR=vim
alias edd="${EDITOR}"

# Shell config
export RCNAME=bash_profile
export RCPATH="${HOME}/.${RCNAME}"
alias edrc="${EDITOR} ${RCPATH} && source ${RCPATH}"
alias edcrc="${EDITOR} ${HOME}/conf/${RCNAME} && source ${RCPATH}"
alias rebash='source ${RCPATH}'

# Shell utils
alias df='df -h'
function md() {
  mkdir -p ${1} && cd ${1}
}
function witch() {
  if which -s ${1}; then ls -lhF $(which ${1}); fi
}

# Homebrew (first, so installed tools are visible)
if [[ -d "${HOME}/homebrew" ]]; then
  PATH="${HOME}/homebrew/bin:${PATH}"
else
  PATH="/usr/local/sbin:/usr/local/bin:${PATH}"
fi
if which -s brew; then
  alias bh='brew home'
  alias bi='brew install'
  alias br='brew remove'
  alias bs='brew search'
  function buu() {
    brew update && brew upgrade && brew cleanup && brew cask outdated
  }
  if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# "Alternatives"
if which -s exa; then
  alias l='exa -l --git --colour-scale'
  alias la='exa -al --git --colour-scale'
  alias ls='exa'
else
  alias l="ls -lhF"
  alias la="ls -alhF"
fi

# ABC
if which -s abc2midi; then
  if which -s m4; then
    function a4() {
      local stem=${1%\.abc4}
      local temp_abc=${stem}_gen.abc
      m4 $1 >$temp_abc
      abc $temp_abc ${2:-mid}
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
  if complete -p bazel >/dev/null 2>&1; then
    BLAZE_COMP=$(complete -p bazel | sed 's/bazel$/blaze/g') && ${BLAZE_COMP}
  fi
fi

# Git
if which -s git; then
  alias g='git'
  if complete -p git >/dev/null 2>&1; then
    G_COMP=$(complete -p git | sed 's/git$/g/g') && ${G_COMP}
  fi
fi

# Go
PATH="$PATH:${HOME}/homebrew/opt/go/libexec/bin:${HOME}/go/bin"

# iterm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Rbenv
if which -s rbenv; then
  eval "$(rbenv init -)"
fi

# Scala
if which -s scala; then export SBT_OPTS='-XX:MaxPermSize=128M -Xmx8192M'; fi

# Utilities
function utd() {
  if which -s brew; then
    echo '************'
    echo '* Homebrew *'
    echo '************'
    buu
  fi
  if which -s rbenv; then
    echo '*********'
    echo '* rbenv *'
    echo '*********'
    local oldrubies=/Users/pdbartlett/.rubies.old
    local newrubies=/Users/pdbartlett/.rubies.new
    rbenv install --list | grep '^\s*[0-9]' >${newrubies}
    if [[ -f ${oldrubies} ]]; then
      diff -s ${oldrubies} ${newrubies};
    fi
    mv -f ${newrubies} ${oldrubies}
    echo 'Installed:'
    rbenv versions
  fi
}

# Tidy up path
PATH="${PATH}:${HOME}/bin"
PATH=$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')
